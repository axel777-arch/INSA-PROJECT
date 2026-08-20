import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';

class ExtensionAlertsScreen extends StatelessWidget {
  const ExtensionAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Map<String, dynamic>> alerts = [
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

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts & Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            const AppTextField(
              label: 'Search alerts...',
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: AppSizes.p12),

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
                    decoration: const InputDecoration(labelText: 'Alert Type'),
                    items: ['All Types', 'Severe Weather', 'Farmer Submission', 'System Update'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            Expanded(
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.p12),
                    child: ListTile(
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
                          if (alert['unread'])
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
