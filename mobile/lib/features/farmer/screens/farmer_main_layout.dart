import 'package:flutter/material.dart';
import '../../alerts/screens/alerts_list_screen.dart';
import '../../content/screens/content_list_screen.dart';
import 'farmer_home_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerMainLayout extends StatefulWidget {
  const FarmerMainLayout({super.key});

  @override
  State<FarmerMainLayout> createState() => _FarmerMainLayoutState();
}

class _FarmerMainLayoutState extends State<FarmerMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FarmerHomeScreen(),
    ContentListScreen(),
    AlertsListScreen(),
    FarmerProfileScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Information'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
