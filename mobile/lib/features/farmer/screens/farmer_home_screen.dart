import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri-Insight'),
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
              'Welcome, David',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Nairobi County, Kenya | Swahili',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.p16),

            // Weather Card
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
                          'Current Conditions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p4),
                        const Text('Humidity: 45% | Precipitation: Low'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 36),
                        const SizedBox(width: AppSizes.p8),
                        Text(
                          '28°C',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // Quick Access Grid
            Text(
              'Quick Access',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.p12,
              mainAxisSpacing: AppSizes.p12,
              childAspectRatio: 1.3,
              children: [
                _buildGridTile(
                  context,
                  icon: Icons.article_outlined,
                  title: 'Agricultural Info',
                  subtitle: 'Access best practices & guides',
                  route: '/content/list',
                ),
                _buildGridTile(
                  context,
                  icon: Icons.notifications_active_outlined,
                  title: 'Alerts',
                  subtitle: '2 New alerts',
                  route: '/alerts',
                  badge: '2',
                ),
                _buildGridTile(
                  context,
                  icon: Icons.sms_outlined,
                  title: 'Messages',
                  subtitle: 'Simulate outbox alert logs',
                  route: '/simulator/sms',
                ),
                _buildGridTile(
                  context,
                  icon: Icons.settings_phone_outlined,
                  title: 'Voice Info',
                  subtitle: 'Simulate voice menu',
                  route: '/simulator/ivr',
                ),
                _buildGridTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  subtitle: 'Manage farm & crops',
                  route: '/farmer/profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    String? badge,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: theme.primaryColor, size: 28),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                ],
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
