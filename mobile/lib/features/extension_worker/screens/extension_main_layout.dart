import 'package:flutter/material.dart';
import 'extension_alerts_screen.dart';
import 'extension_home_screen.dart';
import 'extension_profile_screen.dart';
import 'farmer_management_screen.dart';

class ExtensionMainLayout extends StatefulWidget {
  const ExtensionMainLayout({super.key});

  @override
  State<ExtensionMainLayout> createState() => _ExtensionMainLayoutState();
}

class _ExtensionMainLayoutState extends State<ExtensionMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ExtensionHomeScreen(),
    FarmerManagementScreen(),
    ExtensionAlertsScreen(),
    ExtensionProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Directory'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
