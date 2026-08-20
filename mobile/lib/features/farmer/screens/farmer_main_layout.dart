import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
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

  static const List<AppNavItem> _items = [
    AppNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppNavItem(
      icon: Icons.article_outlined,
      selectedIcon: Icons.article_rounded,
      label: 'Information',
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
