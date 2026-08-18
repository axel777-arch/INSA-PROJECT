import 'package:flutter/material.dart';
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.group_add_rounded), label: 'Approvals'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Audit Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
