import 'package:flutter/material.dart';
import 'package:re/profile/profile.dart';

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
  const AppPage({super.key,});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int _index = 0;
  final List<Widget> _pages = const [
    ProfilePage(),
    ProfilePage(),
    ProfilePage(),
    ProfilePage()
  ];

  _onNavigationBarTap(index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_index),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'Skills'),
          BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Companies'),
          BottomNavigationBarItem(icon: Icon(Icons.radar_rounded), label: 'Experience')
        ],
        onTap: _onNavigationBarTap,
      ),
    );
  }
}
