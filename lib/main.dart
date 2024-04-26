import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:cryptography/cryptography.dart';
import 'package:openssh_ed25519/openssh_ed25519.dart';
import 'package:git/git.dart' as git;
import 'package:re/companies/companies.dart';
import 'package:re/experience/experience.dart';
import 'package:re/profile/profile.dart';
import 'package:re/skills/skills.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Re',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      home: const AppPage(),
    );
  }
}

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  List<Widget> _pages = [];

  Map<String, dynamic> _dataMap = {};
  bool _dataLoaded = false;

  String _privateKey = "";
  String _publicKey = "";

  String _repo = "";
  bool _hasGit = false;

  @override
  initState() {
    super.initState();
    _loadData().then((value) => setState(() {
          _dataLoaded = true;
        }));
    _loadGit();
  }

  _loadGit() async {
    var appDir = await getApplicationSupportDirectory();
    var workingDir = path.join(appDir.path, 'data');
    try {
      var result = await git.runGit(['remote', 'get-url', 'origin'],
          processWorkingDir: workingDir);
      setState(() {
        _repo = result.stdout;
        _hasGit = true;
        _loadKeys();
      });
    } catch (_) {
      setState(() {
        _hasGit = false;
      });
    }
  }

  _loadKeys() async {
    var appDir = await getApplicationSupportDirectory();
    var keyDir = Directory(path.join(appDir.path, 'keys'));
    var privateKeyFile = File(path.join(keyDir.path, 'key'));
    var publicKeyFile = File(path.join(keyDir.path, 'key.pub'));

    setState(() {
      if (privateKeyFile.existsSync() && publicKeyFile.existsSync()) {
        _privateKey = privateKeyFile.readAsStringSync();
        _publicKey = publicKeyFile.readAsStringSync();
      }
    });
  }

  _saveKeys() async {
    if (_privateKey.isEmpty || _publicKey.isEmpty) return;

    var appDir = await getApplicationSupportDirectory();
    var keyDir = Directory(path.join(appDir.path, 'keys'));
    var privateKeyFile = File(path.join(keyDir.path, 'key'));
    var publicKeyFile = File(path.join(keyDir.path, 'key.pub'));

    if (!privateKeyFile.existsSync()) {
      privateKeyFile.createSync(recursive: true);
    }
    if (!publicKeyFile.existsSync()) publicKeyFile.createSync(recursive: true);

    privateKeyFile.writeAsStringSync(_privateKey);
    publicKeyFile.writeAsStringSync(_publicKey);
  }

  _generateKeys() async {
    final keyPair = await Ed25519().newKeyPair();

    var privateBytes = await keyPair.extractPrivateKeyBytes();
    var public = await keyPair.extractPublicKey();
    var publicBytes = public.bytes;

    var publicStr = encodeEd25519Public(publicBytes);
    var privateStr = encodeEd25519Private(
      privateBytes: privateBytes,
      publicBytes: publicBytes,
    );

    setState(() {
      _privateKey = privateStr;
      _publicKey = publicStr;
      _saveKeys();
    });
  }

  _syncRepo() async {
    var appDir = await getApplicationSupportDirectory();
    var dataDir = Directory(path.join(appDir.path, 'data'));
    log(dataDir.path);
    var isGitEnabled = await git.GitDir.isGitDir(dataDir.path);
    if (!isGitEnabled) {
      await git.runGit(['init', '.'], processWorkingDir: dataDir.path);
      await git.runGit(['remote', 'add', 'origin', _repo],
          processWorkingDir: dataDir.path);
      await git
          .runGit(['branch', '-m', 'main'], processWorkingDir: dataDir.path);
    }
    await git.runGit(['add', '.'],
        throwOnError: false, processWorkingDir: dataDir.path);
    await git.runGit(
        ['commit', '-am', 'data updated - ${DateTime.timestamp()}'],
        throwOnError: false, processWorkingDir: dataDir.path);
    await git.runGit(['pull', '--merge', 'origin', 'main'],
        throwOnError: false, processWorkingDir: dataDir.path);
    await git.runGit(['push', 'origin', 'main'],
        throwOnError: false, processWorkingDir: dataDir.path);
  }

  _saveData() async {
    var appDir = await getApplicationSupportDirectory();
    var dataDir = Directory(path.join(appDir.path, 'data'));
    var dataFile = File(path.join(dataDir.path, 'data.json'));
    if (!dataFile.existsSync()) dataFile.createSync(recursive: true);
    dataFile.writeAsStringSync(jsonEncode(_dataMap));
    if (await git.GitDir.isGitDir(dataDir.path)) {
      _syncRepo();
    }
  }

  Future<bool> _loadData() async {
    var appDir = await getApplicationSupportDirectory();
    var dataDir = Directory(path.join(appDir.path, 'data'));
    if (await git.GitDir.isGitDir(dataDir.path)) {
      await _syncRepo();
    }
    var dataFile = File(path.join(dataDir.path, 'data.json'));
    if (dataFile.existsSync()) {
      setState(() {
        _dataMap = jsonDecode(dataFile.readAsStringSync());
        _pages = [
          ProfilePage(
            profile: _loadProfile(),
            callback: _saveProfile,
          ),
          SkillsPage(
            skills: _loadSkills(),
            callback: _saveSkills,
          ),
          CompaniesPage(
            companies: _loadCompanies(),
            callback: _saveCompanies,
          ),
          const ExperiencePage()
        ];
      });
    }
    return true;
  }

  _saveProfile(Profile profile) {
    setState(() {
      _dataMap['profile'] = profile.toMap();
      _saveData();
    });
  }

  Profile _loadProfile() {
    return _dataMap['profile'] != null
        ? Profile.fromMap(_dataMap['profile'])
        : Profile();
  }

  _saveSkills(List<Skill> skills) {
    setState(() {
      _dataMap['skills'] = skills.map((skill) => skill.toMap()).toList();
      _saveData();
    });
  }

  List<Skill> _loadSkills() {
    List<Skill> skills = [];
    if (_dataMap['skills'] != null) {
      for (Map<String, dynamic> skillData in _dataMap['skills']) {
        skills.add(Skill.fromMap(skillData));
      }
    }
    return skills;
  }

  _saveCompanies(List<Company> companies) {
    setState(() {
      _dataMap['companies'] =
          companies.map((company) => company.toMap()).toList();
      _saveData();
    });
  }

  List<Company> _loadCompanies() {
    List<Company> companies = [];
    if (_dataMap['companies'] != null) {
      for (Map<String, dynamic> companyData in _dataMap['companies']) {
        companies.add(Company.fromMap(companyData));
      }
    }
    return companies;
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    return _dataLoaded
        ? DefaultTabController(
            length: 4,
            child: Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                actions: [
                  IconButton(
                    onPressed: () {
                      scaffoldKey.currentState?.openEndDrawer();
                    },
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
                title: const Text('Re'),
                centerTitle: true,
                bottom: const TabBar(tabs: [
                  Tab(
                    icon: Icon(Icons.person_rounded),
                    text: 'Profile',
                  ),
                  Tab(
                    icon: Icon(Icons.bolt_rounded),
                    text: 'Skills',
                  ),
                  Tab(
                    icon: Icon(Icons.business_rounded),
                    text: 'Companies',
                  ),
                  Tab(
                    icon: Icon(Icons.radar_rounded),
                    text: 'Experience',
                  ),
                ]),
              ),
              endDrawer: Drawer(
                child: ListView(
                  children: [
                    ListTile(
                      title: TextButton.icon(
                        onPressed: () async {
                          var result = await FilePicker.platform.pickFiles(
                            dialogTitle: 'Import data',
                          );
                          log('result: $result');
                          if (result != null && result.xFiles.isNotEmpty) {
                            var appDir = await getApplicationSupportDirectory();
                            var dataDir =
                                Directory(path.join(appDir.path, 'data'));
                            var dataFile =
                                File(path.join(dataDir.path, 'data.json'));
                            if (!dataFile.existsSync()) {
                              dataFile.createSync(recursive: true);
                            }
                            dataFile.writeAsStringSync(
                                await result.xFiles.single.readAsString());
                            setState(() {
                              _loadData();
                            });
                          }
                        },
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Import'),
                      ),
                    ),
                    ListTile(
                      title: TextButton.icon(
                        onPressed: () async {
                          var exportPath = await FilePicker.platform.saveFile(
                              dialogTitle: 'Export data',
                              fileName: 're.export.json');
                          if (exportPath != null) {
                            File(exportPath)
                                .writeAsStringSync(jsonEncode(_dataMap));
                          }
                        },
                        icon: const Icon(Icons.sim_card_download_rounded),
                        label: const Text('Export'),
                      ),
                    ),
                    if (_hasGit) const Divider(),
                    if (_hasGit)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_repo.isNotEmpty)
                              Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Linked Git Repo'),
                                  ),
                                  Text(
                                    _repo,
                                    style: TextStyle(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      color: Theme.of(context).canvasColor,
                                    ),
                                  )
                                ],
                              ),
                            ListTile(
                              title: ElevatedButton.icon(
                                icon: const Icon(Icons.link_rounded),
                                label: const Text('Link to new Git Repo'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Theme.of(context).primaryColor),
                                  foregroundColor: MaterialStatePropertyAll(
                                      Theme.of(context).canvasColor),
                                  iconColor: MaterialStatePropertyAll(
                                      Theme.of(context).canvasColor),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      if (_publicKey.isEmpty) {
                                        _generateKeys();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Git Repo',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                initialValue: _repo,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _repo = value;
                                                  });
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Public Key',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge,
                                              ),
                                            ),
                                            if (_publicKey.isNotEmpty)
                                              Container(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                  child: Text(
                                                    _publicKey,
                                                    style: TextStyle(
                                                        color:
                                                            Theme.of(context)
                                                                .canvasColor),
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  TextButton.icon(
                                                      onPressed: () async {
                                                        await Clipboard
                                                            .setData(
                                                          ClipboardData(
                                                              text:
                                                                  _publicKey),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                          Icons.copy_rounded),
                                                      label: const Text(
                                                          'Copy Public Key')),
                                                  Expanded(
                                                      child: Container()),
                                                  ElevatedButton.icon(
                                                    onPressed: () async {
                                                      await _syncRepo();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    icon: const Icon(
                                                        Icons.link_rounded),
                                                    label: const Text(
                                                        'Link Git Repo'),
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                        foregroundColor:
                                                            MaterialStatePropertyAll(
                                                                Theme.of(
                                                                        context)
                                                                    .canvasColor)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TabBarView(
                  children: _pages,
                ),
              ),
            ),
          )
        : const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Loading data...'),
                  ),
                ],
              ),
            ),
          );
  }
}
