import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class AdminUserApprovalsScreen extends StatefulWidget {
  const AdminUserApprovalsScreen({super.key});

  @override
  State<AdminUserApprovalsScreen> createState() => _AdminUserApprovalsScreenState();
}

class _AdminUserApprovalsScreenState extends State<AdminUserApprovalsScreen> {
  final List<Map<String, String>> _pending = [
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

  void _process(String id, String name, bool approved) {
    setState(() {
      _pending.removeWhere((user) => user['id'] == id);
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
    return Scaffold(
      appBar: AppBar(title: const Text('User Approvals')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pending Approvals Queue',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            Expanded(
              child: _pending.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: theme.primaryColor),
                          const SizedBox(height: 12),
                          const Text('All clean! No pending approvals.', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pending.length,
                      itemBuilder: (context, index) {
                        final user = _pending[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.p12),
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
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Chip(
                                      label: Text(user['role']!),
                                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Phone: ${user['phone']}'),
                                Text('Email: ${user['email']}'),
                                const Divider(height: AppSizes.p24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton.destructive(
                                        label: 'Reject',
                                        icon: Icons.close_rounded,
                                        onPressed: () => _process(user['id']!, user['name']!, false),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.p12),
                                    Expanded(
                                      child: AppButton(
                                        label: 'Approve',
                                        icon: Icons.check_rounded,
                                        onPressed: () => _process(user['id']!, user['name']!, true),
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
