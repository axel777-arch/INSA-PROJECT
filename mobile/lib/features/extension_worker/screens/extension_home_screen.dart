import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';

class ExtensionHomeScreen extends StatelessWidget {
  const ExtensionHomeScreen({super.key});

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
              'Welcome, Jane Doe',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Extension Worker • Northern District',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.p24),

            // Grid workspace options (6 buttons)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.p16,
              mainAxisSpacing: AppSizes.p16,
              childAspectRatio: 1.3,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Register',
                  subtitle: 'New Farmer',
                  route: '/extension/farmer/register',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.people_rounded,
                  title: 'Farmers',
                  subtitle: 'View Directory',
                  route: '/extension/farmer/directory',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.eco_rounded,
                  title: 'Crops',
                  subtitle: 'Manage Records',
                  route: '/extension/crops',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.travel_explore_rounded,
                  title: 'Field',
                  subtitle: 'Observations',
                  route: '/extension/field/observations',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.note_add_rounded,
                  title: 'Submit',
                  subtitle: 'New Content',
                  route: '/content/create',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.notifications_active_rounded,
                  title: 'Alerts',
                  subtitle: '3 Unread alerts',
                  route: '/extension/alerts',
                  badge: '3',
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p24),

            // Recent Activity Section
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
                    leading: CircleAvatar(child: Icon(Icons.person_add_alt_1_outlined)),
                    title: Text('Registered Farmer: John Smith'),
                    subtitle: Text('2 hours ago'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.edit_note_rounded)),
                    title: Text('Updated Crop Record: Field B'),
                    subtitle: Text('Yesterday'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
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
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: theme.primaryColor, size: 32),
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
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
