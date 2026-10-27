import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import 'extension_alerts_screen.dart';
import 'extension_cases_screen.dart';
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
    ExtensionCasesScreen(),
    FarmerManagementScreen(),
    ExtensionAlertsScreen(),
    ExtensionProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.current;
    final items = [
      AppNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: loc.home,
      ),
      AppNavItem(
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment_rounded,
        label: loc.cases,
      ),
      AppNavItem(
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt_rounded,
        label: appText('Directory'),
      ),
      AppNavItem(
        icon: Icons.notifications_none_rounded,
        selectedIcon: Icons.notifications_rounded,
        label: loc.alerts,
      ),
      AppNavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: loc.profile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: items,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
