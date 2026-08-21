import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  double _latitude = 9.03;
  double _longitude = 38.74;
  bool _locationUnavailable = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=Ethiopia&format=json&limit=1',
        ),
        headers: {'User-Agent': 'agri-insight-beacon-demo'},
      );
      final result =
          (jsonDecode(response.body) as List<dynamic>).first
              as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _latitude = double.parse(result['lat'] as String);
        _longitude = double.parse(result['lon'] as String);
      });
    } catch (_) {
      if (mounted) setState(() => _locationUnavailable = true);
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _lastSynced = 'Just now';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data synced successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

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
                            MyApp.themeNotifier.value = isDark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                          },
                          onNotifications: () {
                            Navigator.pushNamed(context, '/alerts');
                          },
                        ),
                        const SizedBox(height: AppSizes.p24),
                        const DashboardWelcomeBanner(
                          greeting: 'Welcome back, David',
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

                const SizedBox(height: AppSizes.p20),

                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.map_outlined),
                        title: const Text('Farm Location'),
                        subtitle: Text(
                          _locationUnavailable
                              ? 'Location service unavailable'
                              : 'Remote OpenStreetMap data',
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Image.network(
                          'https://tile.openstreetmap.org/6/37/31.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text(
                              'Map unavailable. Check your connection.',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
      ),
    );
  }
}
