import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
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
  bool _isLoading = true;

  String _roleFilter = 'All Roles';
  static const List<String> _roleOptions = ['All Roles', 'ADMIN', 'EXPERT', 'EXTENSION_WORKER', 'FARMER'];

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoading = true);
    final logs = await _adminService.getAuditLogs();
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredLogs {
    var results = List<Map<String, dynamic>>.from(_logs);
    if (_roleFilter != 'All Roles') {
      results = results.where((l) => (l['actorRole'] ?? '').toString().toUpperCase() == _roleFilter).toList();
    }
    return results;
  }

  Color _getActionColor(String action) {
    if (action.contains('APPROVE') || action.contains('RESOLVE')) return AppColors.success;
    if (action.contains('REJECT') || action.contains('DELETE') || action.contains('DISABLE')) return AppColors.error;
    if (action.contains('PUBLISH') || action.contains('BROADCAST')) return Colors.blue;
    return Colors.amber.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredLogs;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('System Audit Logs')),
        body: RefreshIndicator(
          onRefresh: _loadAuditLogs,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _roleFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Actor Role',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _roleFilter = val);
                  },
                ),
                const SizedBox(height: AppSizes.p12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Security & Audit Trail (${filtered.length})',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_isLoading)
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
                const SizedBox(height: AppSizes.p8),
                Expanded(
                  child: _isLoading && _logs.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_toggle_off, size: 64, color: theme.disabledColor),
                                  const SizedBox(height: 12),
                                  const Text('No audit logs recorded for this criteria.'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final log = filtered[index];
                                final actor = (log['actorName'] ?? 'System') as String;
                                final role = (log['actorRole'] ?? 'SYSTEM') as String;
                                final action = (log['action'] ?? 'ACTION') as String;
                                final target = (log['target'] ?? '') as String;
                                final timeStr = (log['timestamp'] ?? '') as String;
                                final color = _getActionColor(action);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: AppSizes.p8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: color.withValues(alpha: 0.15),
                                      child: Icon(Icons.shield_outlined, color: color, size: 20),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            action,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                                          ),
                                        ),
                                        Text(
                                          timeStr.length > 16 ? timeStr.substring(0, 16).replaceAll('T', ' ') : timeStr,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '$actor ($role) → $target',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
