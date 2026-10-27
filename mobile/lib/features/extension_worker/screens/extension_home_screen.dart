import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../models/farmer_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_service.dart';
import 'extension_alerts_screen.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ExtensionHomeScreen extends StatefulWidget {
  const ExtensionHomeScreen({super.key});

  @override
  State<ExtensionHomeScreen> createState() => _ExtensionHomeScreenState();
}

class _ExtensionHomeScreenState extends State<ExtensionHomeScreen> {
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());
  List<FarmerModel> _recentFarmers = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String _lastSynced = '10m ago';

  @override
  void initState() {
    super.initState();
    _loadRecentActivity();
  }

  Future<void> _loadRecentActivity() async {
    setState(() => _isLoading = true);
    try {
      final farmers = await _farmerService.getFarmers();
      if (!mounted) return;
      setState(() {
        _recentFarmers = farmers.take(2).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _lastSynced = 'Just now';
      _isSyncing = false;
    });
    _loadRecentActivity();
  }

  @override
  Widget build(BuildContext context) {
    final unreadAlerts = ExtensionAlertsStore.unreadCount;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _syncData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          logoIcon: Icons.agriculture_rounded,
                          isDark: isDark,
                          showNotificationDot: unreadAlerts > 0,
                          onNotifications: () async {
                            await Navigator.pushNamed(context, '/extension/alerts');
                            if (mounted) setState(() {});
                          },
                        ),
                        const SizedBox(height: AppSizes.p20),
                        const DashboardWelcomeBanner(
                          greeting: 'Extension Portal',
                          subtitle: 'Manage assigned farmers & crop records',
                        ),
                        const SizedBox(height: AppSizes.p16),
                        SyncDataBanner(
                          isSyncing: _isSyncing,
                          lastSyncedLabel: 'Last synced $_lastSynced',
                          onSync: _syncData,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.p16),

                DashboardActionCard(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Register New Farmer',
                  description: 'Onboard a new farmer into the system.',
                  accent: DashAccent.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/extension/farmer/register');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.people_outline_rounded,
                  title: 'Farmer Directory',
                  description: 'Search and manage registered farmers.',
                  accent: DashAccent.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/extension/farmer/directory');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.eco_outlined,
                  title: 'Crop Records',
                  description: 'Manage crop cycles and recordings.',
                  accent: DashAccent.amber,
                  onTap: () {
                    Navigator.pushNamed(context, '/extension/crops');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.grass_outlined,
                  title: 'Register New Crop',
                  description: 'Add a new crop variety to the central database.',
                  accent: DashAccent.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/extension/crops/add');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.travel_explore_outlined,
                  title: 'Field Observations',
                  description: 'Log and review field visit observations.',
                  accent: DashAccent.amber,
                  onTap: () {
                    Navigator.pushNamed(context, '/extension/field/observations');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.event_note_outlined,
                  title: 'Schedule Follow-Up',
                  description: 'Plan verification visits for farmers.',
                  accent: DashAccent.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/extension/follow-up/schedule');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.note_add_outlined,
                  title: 'Submit New Content',
                  description: 'Create an article or advisory for review.',
                  accent: DashAccent.blue,
                  onTap: () {
                    Navigator.pushNamed(context, '/content/create');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.notifications_active_outlined,
                  title: 'Alerts',
                  description: unreadAlerts == 1
                      ? '1 unread alert'
                      : '$unreadAlerts unread alerts',
                  badgeLabel: unreadAlerts > 0 ? '$unreadAlerts Unread' : null,
                  accent: DashAccent.red,
                  onTap: () async {
                    await Navigator.pushNamed(context, '/extension/alerts');
                    _loadRecentActivity();
                  },
                ),

                const SizedBox(height: AppSizes.p12),

                DashboardSectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'View all',
                  onAction: () {},
                ),

                const SizedBox(height: AppSizes.p12),

                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSizes.p24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _recentFarmers.isEmpty
                        ? RecentActivityCard(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(AppSizes.p16),
                                child: Text('No recent activity yet.'),
                              ),
                            ],
                          )
                        : RecentActivityCard(
                            children: [
                              for (int i = 0; i < _recentFarmers.length; i++)
                                RecentActivityRow(
                                  icon: Icons.person_add_alt_1_outlined,
                                  title:
                                      'Registered Farmer: ${_recentFarmers[i].fullName}',
                                  subtitle:
                                      '${_recentFarmers[i].region}, ${_recentFarmers[i].woreda}',
                                  pillLabel: 'New',
                                  accent: DashAccent.green,
                                  showDivider: i != _recentFarmers.length - 1,
                                ),
                            ],
                          ),

                const SizedBox(height: AppSizes.p24),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
