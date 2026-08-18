import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Mock registration requests waiting for approval
  final List<Map<String, String>> _pendingRegistrations = [
    {
      'id': '1',
      'name': 'Dr. Daniel Kassa',
      'role': 'Agricultural Expert',
      'phone': '+251911223344',
      'email': 'daniel@insa.gov.et',
    },
    {
      'id': '2',
      'name': 'Helen Worku',
      'role': 'Extension Worker',
      'phone': '+251912445566',
      'email': 'helen@extension.gov.et',
    }
  ];

  void _processApproval(String id, String name, bool approved) {
    setState(() {
      _pendingRegistrations.removeWhere((user) => user['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approved ? '$name approved successfully!' : '$name registration rejected.'),
        backgroundColor: approved ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Workspace'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              MyApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Stats
            Card(
              color: theme.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Administration',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p4),
                        const Text('Mock settings loaded via .env'),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p20),
            
            Text(
              'Pending Registrations (${_pendingRegistrations.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            
            Expanded(
              child: _pendingRegistrations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_add_rounded,
                            size: 64,
                            color: theme.primaryColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: AppSizes.p12),
                          const Text(
                            'No pending registration requests.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pendingRegistrations.length,
                      itemBuilder: (context, index) {
                        final user = _pendingRegistrations[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      user['name']!,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(user['role']!),
                                      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                      labelStyle: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.p8),
                                Text('Phone: ${user['phone']}'),
                                Text('Email: ${user['email']}'),
                                const Divider(height: AppSizes.p24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton.destructive(
                                        label: 'Reject',
                                        icon: Icons.close_rounded,
                                        onPressed: () => _processApproval(user['id']!, user['name']!, false),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.p12),
                                    Expanded(
                                      child: AppButton(
                                        label: 'Approve',
                                        icon: Icons.check_rounded,
                                        onPressed: () => _processApproval(user['id']!, user['name']!, true),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
