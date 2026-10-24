import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import 'admin_audit_logs_screen.dart';
import 'admin_home_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_user_approvals_screen.dart';
import 'admin_user_management_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminHomeScreen(),
    AdminUserApprovalsScreen(),
    AdminUserManagementScreen(),
    AdminAuditLogsScreen(),
    AdminSettingsScreen(),
  ];

  static const List<AppNavItem> _items = [
    AppNavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    AppNavItem(
      icon: Icons.group_add_outlined,
      selectedIcon: Icons.group_add_rounded,
      label: 'Approvals',
    ),
    AppNavItem(
      icon: Icons.people_alt_outlined,
      selectedIcon: Icons.people_alt_rounded,
      label: 'Users',
    ),
    AppNavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      label: 'Audit Logs',
    ),
    AppNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
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
