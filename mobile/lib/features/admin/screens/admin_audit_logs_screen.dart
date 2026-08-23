import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/api_client.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  final AdminService _adminService = AdminService(apiClient: ApiClient());
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  String _dateRange = 'Last 7 Days';
  String _roleFilter = 'All Roles';

  static const List<String> _dateRangeOptions = [
    'Last 7 Days',
    'Last 30 Days',
    'All Time',
  ];
  static const List<String> _roleOptions = [
    'All Roles',
    'Admin',
    'Expert',
    'Extension Worker',
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await _adminService.getAuditLogs();
      if (mounted) {
        setState(() {
          _logs = logs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> log) async {
    final id = log['targetId'] as String?;
    if (id == null || id.isEmpty || id == 'admin') return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Delete user?'),
      content: Text('Permanently remove ${log['targetName'] ?? 'this user'}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
      ],
    ));
    if (confirmed != true) return;
    try {
      await _adminService.deleteUser(id);
      await _loadLogs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted permanently.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not delete user: $error')));
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    var results = List<Map<String, dynamic>>.from(_logs);

    if (_roleFilter != 'All Roles') {
      final role = _roleFilter == 'Expert'
          ? 'EXPERT'
          : _roleFilter.toUpperCase().replaceAll(' ', '_');
      results = results
          .where((l) => (l['targetRole'] ?? l['actorRole']) == role)
          .toList();
    }

    if (_dateRange != 'All Time') {
      final cutoff = DateTime.now().subtract(
        Duration(days: _dateRange == 'Last 7 Days' ? 7 : 30),
      );
      results = results
          .where(
            (l) =>
                DateTime.tryParse('${l['createdAt']}')?.isAfter(cutoff) ??
                false,
          )
          .toList();
    }

    return results;
  }

  String _friendlyRole(String? role) {
    switch (role) {
      case 'ADMIN':
        return 'Admin';
      case 'EXPERT':
        return 'Agronomy Expert';
      case 'EXTENSION_WORKER':
        return 'Extension Worker';
      case 'FARMER':
        return 'Farmer';
      default:
        return role ?? 'System';
    }
  }

  String _displayDate(dynamic value) {
    final date = DateTime.tryParse('$value')?.toLocal();
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) => status == 'APPROVED'
      ? Colors.green
      : status == 'REJECTED'
      ? Colors.red
      : Colors.blue;

  @override
  Widget build(BuildContext context) {
    final logs = _filteredLogs;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text('System Audit Logs')),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _dateRange,
                            decoration: const InputDecoration(
                              labelText: 'Date Range',
                            ),
                            items: _dateRangeOptions
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _dateRange = val);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _roleFilter,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                            ),
                            items: _roleOptions
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _roleFilter = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p16),

                    Expanded(
                      child: logs.isEmpty
                          ? const Center(
                              child: Text(
                                'No audit entries match your filters.',
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Phone No / Email')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: logs.map((log) {
                                  final status =
                                      log['status'] as String? ?? '-';
                                  final statusColor = _statusColor(status);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          log['targetName'] as String? ?? '-',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${log['targetPhone'] as String? ?? '-'} / ${log['targetEmail'] as String? ?? '-'}',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _friendlyRole(
                                            (log['targetRole'] ??
                                                    log['actorRole'])
                                                as String?,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(_displayDate(log['createdAt'])),
                                      ),
                                      DataCell(
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          tooltip: 'Delete user',
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _deleteUser(log),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
