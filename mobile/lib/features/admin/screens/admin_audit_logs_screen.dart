import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
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
  List<AdminAuditLog> _logs = [];
  bool _isLoading = true;
  String? _error;
  String _dateRange = 'LAST_7_DAYS';
  String _roleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final logs = await _adminService.getAuditLogs();
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  List<AdminAuditLog> _filteredLogs() {
    final cutoff = switch (_dateRange) {
      'LAST_7_DAYS' => DateTime.now().subtract(const Duration(days: 7)),
      'LAST_30_DAYS' => DateTime.now().subtract(const Duration(days: 30)),
      _ => null,
    };
    return _logs.where((log) {
      final matchesRole = _roleFilter == 'ALL' || log.actorRole == _roleFilter;
      final matchesDate = cutoff == null || !log.timestamp.isBefore(cutoff);
      return matchesRole && matchesDate;
    }).toList();
  }

  String _roleLabel(String role, AppLocalizations loc) => switch (role) {
    'ADMIN' => loc.adminRole,
    'EXPERT' => loc.expertRole,
    'EXTENSION_WORKER' => loc.extensionWorkerRole,
    _ => role,
  };

  String _actionLabel(String action, AppLocalizations loc) => switch (action) {
    'USER_APPROVED' => loc.approved,
    'USER_REJECTED' => loc.rejected,
    _ =>
      action
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' '),
  };

  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;
    final logs = _filteredLogs();

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.systemAuditLogs),
          actions: [
            IconButton(
              tooltip: loc.refresh,
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
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
                      decoration: InputDecoration(labelText: loc.dateRange),
                      items: [
                        DropdownMenuItem(
                          value: 'LAST_7_DAYS',
                          child: Text(loc.last7Days),
                        ),
                        DropdownMenuItem(
                          value: 'LAST_30_DAYS',
                          child: Text(loc.last30Days),
                        ),
                        DropdownMenuItem(
                          value: 'ALL_TIME',
                          child: Text(loc.allTime),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _dateRange = value);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _roleFilter,
                      decoration: InputDecoration(labelText: loc.role),
                      items: [
                        DropdownMenuItem(
                          value: 'ALL',
                          child: Text(loc.allRoles),
                        ),
                        DropdownMenuItem(
                          value: 'ADMIN',
                          child: Text(loc.adminRole),
                        ),
                        DropdownMenuItem(
                          value: 'EXPERT',
                          child: Text(loc.expertRole),
                        ),
                        DropdownMenuItem(
                          value: 'EXTENSION_WORKER',
                          child: Text(loc.extensionWorkerRole),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _roleFilter = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: AppSizes.p16),
                            ElevatedButton.icon(
                              onPressed: _loadLogs,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(loc.retry),
                            ),
                          ],
                        ),
                      )
                    : logs.isEmpty
                    ? Center(child: Text(loc.noAuditEntries))
                    : ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final color = log.action.contains('REJECT')
                              ? AppColors.error
                              : AppColors.success;
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSizes.p12),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.p16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          log.actorName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSizes.p8),
                                      Text(
                                        _formatTimestamp(log.timestamp),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.p8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          _actionLabel(log.action, loc),
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _roleLabel(log.actorRole, loc),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.p8),
                                  Text(
                                    '${loc.target}: ${log.target}',
                                    style: theme.textTheme.bodyMedium,
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
      ),
    );
  }
}
