import 'package:flutter/material.dart';
import 'package:gn_account_manager/settings.dart';

import 'clientscreen.dart';
import 'home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;

            // Navigate to SettingsPage when "Settings" is selected
            // if (index == 0) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => HomeScreen()),
            //   );
            // }
            // if (index == 1) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => Dashboard()),
            //   );
            // }
            // if (index == 2) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => SettingsPage()),
            //   );
            // }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Client Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),

      body: _selectedIndex == 0
          ? HomeScreen()
          : _selectedIndex == 1
          ? Dashboard()
          : SettingsPage(),
    );
  }
}
