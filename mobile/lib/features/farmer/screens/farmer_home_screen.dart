import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  bool _isSyncing = false;
  String _lastSynced = '5m ago';

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _lastSynced = 'Just now';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data synced successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeroSection(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSizes.p12,
                    bottom: AppSizes.p16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardAppHeader(
                        title: 'Agri-Insight Beacon',
                        isDark: isDark,
                        onToggleTheme: () {
                          MyApp.themeNotifier.value =
                              isDark ? ThemeMode.light : ThemeMode.dark;
                        },
                        onNotifications: () {
                          Navigator.pushNamed(context, '/alerts');
                        },
                      ),
                      const SizedBox(height: AppSizes.p24),
                      const DashboardWelcomeBanner(
                        greeting: 'Welcome back, David 👋',
                        subtitle:
                            'Nairobi County, Kenya • Here is your farm overview.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.p20),

              SyncDataBanner(
                isSyncing: _isSyncing,
                lastSyncedLabel: _lastSynced,
                onSync: _syncData,
              ),

              const SizedBox(height: AppSizes.p24),

              DashboardActionCard(
                icon: Icons.wb_sunny_outlined,
                title: 'Current Conditions',
                description: '28°C • Humidity 45% • Precipitation: Low',
                accent: DashAccent.amber,
                onTap: () {},
              ),

              DashboardActionCard(
                icon: Icons.article_outlined,
                title: 'Agricultural Information',
                description: 'Best practices, guides and crop advisories.',
                accent: DashAccent.green,
                onTap: () {
                  Navigator.pushNamed(context, '/content/list');
                },
              ),

              DashboardActionCard(
                icon: Icons.notifications_active_outlined,
                title: 'Alerts',
                description: 'Pest, weather and disease warnings near you.',
                badgeLabel: '2 New',
                accent: DashAccent.red,
                onTap: () {
                  Navigator.pushNamed(context, '/alerts');
                },
              ),

              DashboardActionCard(
                icon: Icons.sms_outlined,
                title: 'Messages',
                description: 'Simulate SMS outbox and alert logs.',
                accent: DashAccent.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/simulator/sms');
                },
              ),

              DashboardActionCard(
                icon: Icons.settings_phone_outlined,
                title: 'Voice Information',
                description: 'Simulate the IVR voice menu.',
                accent: DashAccent.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/simulator/ivr');
                },
              ),

              const SizedBox(height: AppSizes.p12),

              DashboardSectionHeader(
                title: 'Recent Activity',
                actionLabel: 'View all',
                onAction: () {},
              ),

              const SizedBox(height: AppSizes.p12),

              RecentActivityCard(
                children: [
                  RecentActivityRow(
                    icon: Icons.check_rounded,
                    title: 'Crop advisory viewed: Maize Fertilization',
                    subtitle: '1 hour ago • Agricultural Information',
                    pillLabel: 'Viewed',
                    accent: DashAccent.green,
                  ),
                  RecentActivityRow(
                    icon: Icons.priority_high_rounded,
                    title: 'Weather Alert: Heavy rainfall expected',
                    subtitle: '4 hours ago • Nairobi County',
                    pillLabel: 'Alert',
                    accent: DashAccent.red,
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.p24),
            ],
          ),
        ),
      ),
    ));
  }
}
