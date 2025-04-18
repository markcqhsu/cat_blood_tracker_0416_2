import 'package:flutter/material.dart';
import '../entry/entry_screen.dart';
import '../history/history_screen.dart';
import '../chart/chart_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    EntryScreen(),
    HistoryScreen(),
    ChartScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _pages[_selectedIndex]),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Record'),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Chart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
