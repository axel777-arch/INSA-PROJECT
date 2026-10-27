import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/live/live_sync_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/config/user_session.dart';
import '../../../../core/routing/app_router.dart';
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
  String _displayName = 'Extension Worker';
  late final LiveSyncController _live;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _live = LiveSyncController(
      storageKey: 'extension_home',
      refresh: _loadRecentActivity,
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
    _live.start();
  }

  Future<void> _loadCurrentUser() async {
    final user = await UserSession.get();
    if (!mounted || user == null) return;
    setState(() => _displayName = user.fullName);
  }

  @override
  void dispose() {
    _live.dispose();
    super.dispose();
  }

  Future<bool> _loadRecentActivity() async {
    try {
      final farmers = await _farmerService.getFarmers();
      if (!mounted) return false;
      setState(() {
        _recentFarmers = farmers.take(2).toList();
        _isLoading = false;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() => _isLoading = false);
      return false;
    }
  }

  Future<void> _syncData() => _live.syncNow();

  @override
  Widget build(BuildContext context) {
    final unreadAlerts = ExtensionAlertsStore.unreadCount;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _live.syncNow(silent: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                            title: appText('Agri-Insight Beacon'),
                            isDark: isDark,
                            onToggleTheme: () {
                              MyApp.themeNotifier.value = isDark
                                  ? ThemeMode.light
                                  : ThemeMode.dark;
                            },
                            onNotifications: () {
                              Navigator.pushNamed(context, '/extension/alerts');
                            },
                            showNotificationDot: unreadAlerts > 0,
                          ),
                          const SizedBox(height: AppSizes.p24),
                          DashboardWelcomeBanner(
                            greeting: loc.welcomeBack(_displayName),
                            subtitle: loc.extensionWorkerRole,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.p20),

                  SyncDataBanner(
                    isSyncing: _live.isSyncing,
                    lastSyncedLabel: _live.label,
                    onSync: _syncData,
                  ),

                  const SizedBox(height: AppSizes.p24),

                  DashboardActionCard(
                    icon: Icons.person_add_alt_1_outlined,
                    title: appText('Register New Farmer'),
                    description: 'Onboard a new farmer into the system.',
                    accent: DashAccent.green,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/extension/farmer/register',
                      );
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.people_outline_rounded,
                    title: appText('Farmer Directory'),
                    description: 'Search and manage registered farmers.',
                    accent: DashAccent.green,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/extension/farmer/directory',
                      );
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.assignment_outlined,
                    title: loc.cases,
                    description: loc.casesDescription,
                    accent: DashAccent.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.extensionCases);
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.drafts_outlined,
                    title: appText('Advisory Drafts'),
                    description: appText(
                      'Save drafts and submit advisories for review.',
                    ),
                    accent: DashAccent.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.extensionDrafts);
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.event_available_outlined,
                    title: appText('Farmer Follow-ups'),
                    description: appText('Schedule and track farmer visits.'),
                    accent: DashAccent.amber,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.extensionFollowUps,
                      );
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.event_note_outlined,
                    title: appText('Schedule Follow-Up'),
                    description: 'Plan verification visits for farmers.',
                    accent: DashAccent.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/extension/follow-up/schedule');
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.eco_outlined,
                    title: appText('Crop Records'),
                    description: 'Manage crop cycles and recordings.',
                    accent: DashAccent.amber,
                    onTap: () {
                      Navigator.pushNamed(context, '/extension/crops');
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.grass_outlined,
                    title: appText('Register New Crop'),
                    description:
                        'Add a new crop variety to the central database.',
                    accent: DashAccent.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/extension/crops/add');
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.travel_explore_outlined,
                    title: appText('Field Observations'),
                    description: 'Log and review field visit observations.',
                    accent: DashAccent.amber,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/extension/field/observations',
                      );
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.note_add_outlined,
                    title: appText('Submit New Content'),
                    description: 'Create an article or advisory for review.',
                    accent: DashAccent.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/content/create');
                    },
                  ),

                  DashboardActionCard(
                    icon: Icons.notifications_active_outlined,
                    title: appText('Alerts'),
                    description: unreadAlerts == 1
                        ? '1 unread alert'
                        : '$unreadAlerts unread alerts',
                    badgeLabel: unreadAlerts > 0
                        ? '$unreadAlerts Unread'
                        : null,
                    accent: DashAccent.red,
                    onTap: () async {
                      await Navigator.pushNamed(context, '/extension/alerts');
                      _loadRecentActivity();
                    },
                  ),

                  const SizedBox(height: AppSizes.p12),

                  DashboardSectionHeader(
                    title: appText('Recent Activity'),
                    actionLabel: loc.viewAll,
                    onAction: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.extensionFarmerDirectory,
                      );
                    },
                  ),

                  const SizedBox(height: AppSizes.p12),

                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(AppSizes.p24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _recentFarmers.isEmpty
                      ? RecentActivityCard(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(AppSizes.p16),
                              child: Text(appText('No recent activity yet.')),
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
      ),
    );
  }
}
