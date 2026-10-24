import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
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

  static const List<AppNavItem> _items = [
    AppNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppNavItem(
      icon: Icons.people_alt_outlined,
      selectedIcon: Icons.people_alt_rounded,
      label: 'Directory',
    ),
    AppNavItem(
      icon: Icons.notifications_none_rounded,
      selectedIcon: Icons.notifications_rounded,
      label: 'Alerts',
    ),
    AppNavItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: _items,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
