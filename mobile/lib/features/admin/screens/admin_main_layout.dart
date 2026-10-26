import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.current;
    final items = [
      AppNavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: loc.dashboard,
      ),
      AppNavItem(
        icon: Icons.group_add_outlined,
        selectedIcon: Icons.group_add_rounded,
        label: loc.approvals,
      ),
      AppNavItem(
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt_rounded,
        label: loc.users,
      ),
      AppNavItem(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: loc.auditLogs,
      ),
      AppNavItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: loc.settings,
      ),
    ];

    return Scaffold(
      // Only the selected tab is built, so each tab reloads its data every
      // time it is opened (an IndexedStack would load them only once).
      body: _screens[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: items,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
