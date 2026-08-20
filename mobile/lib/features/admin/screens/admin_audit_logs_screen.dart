import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  static final List<Map<String, dynamic>> _logs = [
    {
      'actor': 'Jane Doe',
      'role': 'Admin',
      'action': 'User Approved',
      'target': 'Expert Daniel Kassa',
      'time': 'Today, 09:14 AM',
      'recent': true,
      'color': AppColors.success,
    },
    {
      'actor': 'Mark Kim',
      'role': 'Expert',
      'action': 'Content Published',
      'target': 'Maize Advisory v2.1',
      'time': 'Yesterday, 02:45 PM',
      'recent': true,
      'color': Colors.blue,
    },
    {
      'actor': 'Sarah Lee',
      'role': 'Extension Worker',
      'action': 'Record Deleted',
      'target': 'Duplicate Form 1882',
      'time': 'Oct 23, 2023',
      'recent': false,
      'color': AppColors.error,
    },
  ];

  String _dateRange = 'Last 7 Days';
  String _roleFilter = 'All Roles';

  static const List<String> _dateRangeOptions = ['Last 7 Days', 'Last 30 Days', 'All Time'];
  static const List<String> _roleOptions = ['All Roles', 'Admin', 'Expert', 'Extension Worker'];

  List<Map<String, dynamic>> get _filteredLogs {
    var results = List<Map<String, dynamic>>.from(_logs);

    if (_roleFilter != 'All Roles') {
      results = results.where((l) => l['role'] == _roleFilter).toList();
    }

    if (_dateRange != 'All Time') {
      results = results.where((l) => l['recent'] == true).toList();
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logs = _filteredLogs;

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
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
                    initialValue: _dateRange,
                    decoration: const InputDecoration(labelText: 'Date Range'),
                    items: _dateRangeOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _dateRange = val);
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _roleFilter,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: _roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _roleFilter = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            Expanded(
              child: logs.isEmpty
                  ? const Center(child: Text('No audit entries match your filters.'))
                  : ListView.builder(
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
                                        color: (log['color'] as Color).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        log['action']!,
                                        style: TextStyle(color: log['color'], fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Target: ${log['target']}', style: theme.textTheme.bodyMedium),
                                    ),
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
    ));
  }
}
