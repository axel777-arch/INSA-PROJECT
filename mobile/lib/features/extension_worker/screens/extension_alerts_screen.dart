import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';

/// Mock in-memory alert inbox. Static so the unread count can be read from
/// ExtensionHomeScreen's badge without a real notifications backend.
class ExtensionAlertsStore {
  static final List<Map<String, dynamic>> alerts = [
    {
      'title': 'Flash Flood Warning - Sector 4',
      'type': 'Severe Weather',
      'time': '10 mins ago',
      'unread': true,
      'icon': Icons.thunderstorm_outlined,
      'color': AppColors.error,
      'body': 'Heavy rainfall expected in the next 2 hours. Advise farmers in low-lying areas to secure equipment.',
    },
    {
      'title': 'New Pest Report: Fall Armyworm',
      'type': 'Farmer Submission',
      'time': '1 hour ago',
      'unread': true,
      'icon': Icons.bug_report_outlined,
      'color': AppColors.warning,
      'body': 'Submitted by John Doe (Farm ID: 8932). Requires immediate review to prevent spread.',
    },
    {
      'title': 'Offline Sync Improvements',
      'type': 'System Update',
      'time': 'Yesterday',
      'unread': false,
      'icon': Icons.sync_outlined,
      'color': Colors.blue,
      'body': 'The app will now sync field data more efficiently when returning to areas with connectivity.',
    },
    {
      'title': 'Optimal Spraying Conditions',
      'type': 'Weather Update',
      'time': 'Oct 12',
      'unread': false,
      'icon': Icons.wb_sunny_outlined,
      'color': AppColors.secondary,
      'body': 'Wind speeds are expected to remain below 5mph for the next 48 hours in Sector 2.',
    }
  ];

  static int get unreadCount => alerts.where((a) => a['unread'] == true).length;
}

class ExtensionAlertsScreen extends StatefulWidget {
  const ExtensionAlertsScreen({super.key});

  @override
  State<ExtensionAlertsScreen> createState() => _ExtensionAlertsScreenState();
}

class _ExtensionAlertsScreenState extends State<ExtensionAlertsScreen> {
  final _searchController = TextEditingController();
  String _dateRange = 'Last 7 Days';
  String _typeFilter = 'All Types';

  static const List<String> _dateRangeOptions = ['Last 7 Days', 'Last 30 Days', 'All Time'];
  static const List<String> _typeOptions = ['All Types', 'Severe Weather', 'Farmer Submission', 'System Update', 'Weather Update'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    var results = List<Map<String, dynamic>>.from(ExtensionAlertsStore.alerts);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((a) {
        return (a['title'] as String).toLowerCase().contains(query) ||
            (a['body'] as String).toLowerCase().contains(query);
      }).toList();
    }

    if (_typeFilter != 'All Types') {
      results = results.where((a) => a['type'] == _typeFilter).toList();
    }

    // Date range is mock data (no real timestamps), so "Last 7 Days" and
    // "Last 30 Days" both show everything except items explicitly aged out;
    // this keeps the filter meaningfully wired without fabricating dates.
    if (_dateRange != 'All Time') {
      results = results.where((a) => a['time'] != 'Oct 12').toList();
    }

    return results;
  }

  void _markRead(Map<String, dynamic> alert) {
    if (alert['unread'] != true) return;
    setState(() => alert['unread'] = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alerts = _filteredAlerts;

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts & Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'Search alerts...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: AppSizes.p12),

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
                    initialValue: _typeFilter,
                    decoration: const InputDecoration(labelText: 'Alert Type'),
                    items: _typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _typeFilter = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            Expanded(
              child: alerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 48, color: theme.disabledColor),
                          const SizedBox(height: AppSizes.p12),
                          const Text('No alerts match your search or filters.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.p12),
                          child: ListTile(
                            onTap: () => _markRead(alert),
                            leading: Icon(alert['icon'], color: alert['color'], size: 28),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alert['title']!,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (alert['unread'] == true)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${alert['type']} • ${alert['time']}', style: theme.textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Text(alert['body']!, style: theme.textTheme.bodyMedium),
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
