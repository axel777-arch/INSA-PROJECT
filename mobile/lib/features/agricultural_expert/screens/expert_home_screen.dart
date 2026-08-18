import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';

class ExpertHomeScreen extends StatelessWidget {
  const ExpertHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri-Insight Beacon'),
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
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header
            Text(
              'Welcome back, Dr. Aris',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here is your operational overview for today.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.p12),
            OutlinedButton.icon(
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Sync Data'),
              onPressed: () {},
            ),
            const SizedBox(height: AppSizes.p20),

            // Review Content Card
            Card(
              child: ListTile(
                leading: Icon(Icons.rate_review_outlined, color: theme.primaryColor, size: 32),
                title: const Text('Review Content', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pending articles and field reports requiring validation.\n12 Pending'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pushNamed(context, '/expert/review/list');
                },
              ),
            ),
            const SizedBox(height: AppSizes.p12),

            // Review Cases Card
            Card(
              child: ListTile(
                leading: Icon(Icons.biotech_outlined, color: theme.colorScheme.secondary, size: 32),
                title: const Text('Review Cases', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Active pest and disease identification requests.\n8 Pending'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pushNamed(context, '/expert/case/detail');
                },
              ),
            ),
            const SizedBox(height: AppSizes.p12),

            // Expert Analytics Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics_outlined, color: Colors.blue, size: 32),
                title: const Text('Expert Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Your review accuracy and throughput.\n148 Total Approvals | 23 Rejections'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pushNamed(context, '/expert/analytics');
                },
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            Card(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.check_circle_outline, color: Colors.green)),
                    title: Text('Approved field report: Soil Moisture'),
                    subtitle: Text('2 hours ago • Submitted by Field Tech'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.error_outline, color: Colors.orange)),
                    title: Text('Reviewed Case: Suspected Blight'),
                    subtitle: Text('3 hours ago • Flagged for further observation'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
