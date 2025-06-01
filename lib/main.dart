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
import 'package:share_plus/share_plus.dart';

import 'companies/model.dart';
import 'experience/model.dart';
import 'profile/model.dart';
import 'skills/model.dart';
import 'companies/companies.dart';
import 'experience/experience.dart';
import 'profile/profile.dart';
import 'skills/skills.dart';

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

  Future<void> _loadGit() async {
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
    } catch (e) {
      log('no git: $e');
      setState(() {
        _hasGit = false;
      });
    }
  }

  Future<void> _loadKeys() async {
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

  Future<void> _saveKeys() async {
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

  Future<void> _generateKeys() async {
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

  Future<void> _syncRepo() async {
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

  Future<void> _clearData() async {
    _dataMap = {};
    await _saveData();
    _loadData();
  }

  Future<void> _saveData() async {
    var appDir = await getApplicationSupportDirectory();
    var dataDir = Directory(path.join(appDir.path, 'data'));
    var dataFile = File(path.join(dataDir.path, 'data.json'));
    if (!dataFile.existsSync()) dataFile.createSync(recursive: true);
    dataFile.writeAsStringSync(jsonEncode(_dataMap));
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (await git.GitDir.isGitDir(dataDir.path)) {
        await _syncRepo();
      }
    }
    await _renderData();
  }

  Future<void> _loadData() async {
    var appDir = await getApplicationSupportDirectory();
    var dataDir = Directory(path.join(appDir.path, 'data'));
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
      setState(() {
        _dataMap = {};
        _saveData();
        return;
      });
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      if (await git.GitDir.isGitDir(dataDir.path)) {
        await _syncRepo();
      }
    }
    var dataFile = File(path.join(dataDir.path, 'data.json'));
    if (dataFile.existsSync()) {
      setState(() {
        _dataMap = jsonDecode(dataFile.readAsStringSync());
        _renderData();
      });
    }
  }

  Future<void> _renderData() async {
    setState(() {
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
        ExperiencePage(
          experiences: _loadExperiences(),
          skills: _loadSkills(),
          companies: _loadCompanies(),
          callback: _saveExperiences,
        )
      ];
    });
  }

  void _saveProfile(Profile profile) {
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

  void _saveSkills(List<Skill> skills) {
    setState(() {
      _dataMap['skills'] = (skills
            ..sort((a, b) =>
                a.name!.toLowerCase().compareTo(b.name!.toLowerCase())))
          .map((skill) => skill.toMap())
          .toList();
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

  void _saveCompanies(List<Company> companies) {
    setState(() {
      _dataMap['companies'] = (companies
            ..sort((a, b) =>
                a.name!.toLowerCase().compareTo(b.name!.toLowerCase())))
          .map((company) => company.toMap())
          .toList();
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

  void _saveExperiences(List<Experience> experiences) {
    setState(() {
      var em = experiences.map((e) => e.toMap());
      _dataMap['experiences'] = em.toList();
      _saveData();
    });
  }

  List<Experience> _loadExperiences() {
    List<Experience> experiences = [];
    if (_dataMap['experiences'] != null) {
      for (Map<String, dynamic> experienceData in _dataMap['experiences']) {
        experiences.add(Experience.fromMap(experienceData));
      }
    }
    return experiences;
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
                child: Column(
                  children: [
                    if (Platform.isIOS)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Container(),
                      ),
                    ListTile(
                      title: TextButton.icon(
                        onPressed: () async {
                          var result = await FilePicker.platform.pickFiles(
                            dialogTitle: 'Import data',
                          );
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
                          final navigator = Navigator.of(context);
                          if (Platform.isIOS || Platform.isMacOS) {
                            var size = MediaQuery.of(context).size;
                            await SharePlus.instance.share(
                              ShareParams(
                                files: [
                                  XFile.fromData(
                                    Uint8List.fromList(
                                        jsonEncode(_dataMap).codeUnits),
                                  ),
                                ],
                                sharePositionOrigin: Rect.fromLTWH(
                                    0, 0, size.width / 2 - 200, size.height),
                              ),
                            );
                            return;
                          }
                          var exportPath = await FilePicker.platform.saveFile(
                              dialogTitle: 'Export data',
                              fileName: 're.export.json');
                          if (exportPath != null) {
                            File(exportPath)
                                .writeAsStringSync(jsonEncode(_dataMap));
                          }
                          navigator.pop();
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
                              title: FilledButton.icon(
                                icon: const Icon(Icons.link_rounded),
                                label: const Text('Link to new Git Repo'),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _publicKey,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
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
                                                        await Clipboard.setData(
                                                          ClipboardData(
                                                              text: _publicKey),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                          Icons.copy_rounded),
                                                      label: const Text(
                                                          'Copy Public Key')),
                                                  Expanded(child: Container()),
                                                  FilledButton.icon(
                                                    onPressed: () async {
                                                      await _syncRepo();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    icon: const Icon(
                                                        Icons.link_rounded),
                                                    label: const Text(
                                                        'Link Git Repo'),
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
                      ),
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                    ListTile(
                      title: TextButton.icon(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            var message =
                                'Are you sure that you want to clear all of your data?';
                            var width = MediaQuery.of(context).size.width / 16;
                            var height =
                                MediaQuery.of(context).size.height / 2 -
                                    (message.length * 3);
                            bool choice = await showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  insetPadding: EdgeInsets.only(
                                    left: width,
                                    right: width,
                                    top: height,
                                    bottom: height,
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(child: Container()),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          message,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            TextButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                icon: const Icon(
                                                    Icons.cancel_rounded),
                                                label: const Text('Cancel')),
                                            Expanded(child: Container()),
                                            ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.check_rounded),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                label:
                                                    const Text('Delete Data'))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                            if (choice) {
                              await _clearData();
                            }
                          },
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text('Clear Data')),
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
