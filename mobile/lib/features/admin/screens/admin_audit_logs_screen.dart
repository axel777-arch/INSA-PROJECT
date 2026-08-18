import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

class AdminAuditLogsScreen extends StatelessWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> logs = [
      {
        'actor': 'Jane Doe',
        'role': 'Admin',
        'action': 'User Approved',
        'target': 'Expert Daniel Kassa',
        'time': 'Today, 09:14 AM',
        'color': AppColors.success,
      },
      {
        'actor': 'Mark Kim',
        'role': 'Expert',
        'action': 'Content Published',
        'target': 'Maize Advisory v2.1',
        'time': 'Yesterday, 02:45 PM',
        'color': Colors.blue,
      },
      {
        'actor': 'Sarah Lee',
        'role': 'Extension Worker',
        'action': 'Record Deleted',
        'target': 'Duplicate Form 1882',
        'time': 'Oct 23, 2023',
        'color': AppColors.error,
      }
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('System Audit Logs')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Date Range'),
                    items: ['Last 7 Days', 'Last 30 Days', 'All Time'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'All Roles'),
                    items: ['All Roles', 'Admin', 'Expert', 'Extension'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.p12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                log['actor']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(log['time']!, style: theme.textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: log['color'].withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  log['action']!,
                                  style: TextStyle(color: log['color'], fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Target: ${log['target']}', style: theme.textTheme.bodyMedium),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
