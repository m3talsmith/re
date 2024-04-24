import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
  bool _loaded = false;

  @override
  initState() {
    super.initState();
    _loadData().then((value) => setState(() {
          _loaded = true;
        }));
  }

  _saveData() async {
    var appDir = await getApplicationSupportDirectory();
    var dataDir = Directory(path.join(appDir.path, 'data'));
    var dataFile = File(path.join(dataDir.path, 'data.json'));
    if (!dataFile.existsSync()) dataFile.createSync(recursive: true);
    dataFile.writeAsStringSync(jsonEncode(_dataMap));
  }

  Future<bool> _loadData() async {
    var appDir = await getApplicationSupportDirectory();
    var dataDir = Directory(path.join(appDir.path, 'data'));
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
          const CompaniesPage(),
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
      for(Map<String, dynamic> skillData in _dataMap['skills']) {
        skills.add(Skill.fromMap(skillData));
      }
    }
    return skills;
  }

  @override
  Widget build(BuildContext context) {
    return _loaded
        ? DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Re'),
                centerTitle: true,
                actions: [
                  (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
                      ? TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_file_rounded),
                          label: const Text('Import'),
                        )
                      : Container(),
                  (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
                      ? TextButton.icon(
                          onPressed: () {

                          },
                          icon: const Icon(Icons.sim_card_download_rounded),
                          label: const Text('Export'),
                        )
                      : Container(),
                  (Platform.isAndroid || Platform.isIOS)
                      ? IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_rounded),
                        )
                      : Container()
                ],
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
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TabBarView(
                  children: _pages,
                ),
              ),
            ),
          )
        : const Row(
            children: [
              CircularProgressIndicator(),
              Text('Loading data...'),
            ],
          );
  }
}
