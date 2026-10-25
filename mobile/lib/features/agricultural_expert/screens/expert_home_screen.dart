import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/config/user_session.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/live/live_sync_controller.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/content_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ExpertHomeScreen extends StatefulWidget {
  const ExpertHomeScreen({super.key});

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final AuthService _authService = AuthService(apiClient: ApiClient());

  int _pendingReviewCount = 0;
  bool _isLoading = true;
  late final LiveSyncController _live;
  String _displayName = 'Expert';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _live = LiveSyncController(
      storageKey: 'expert_home',
      refresh: _loadCounts,
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
    _live.start();
  }

  @override
  void dispose() {
    _live.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = await UserSession.get();
    if (!mounted) return;
    setState(() => _displayName = user?.fullName ?? 'Expert');
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<bool> _loadCounts() async {
    try {
      final pending = await _contentService.getAdvisories(status: 'IN_REVIEW');
      if (!mounted) return false;
      setState(() {
        _pendingReviewCount = pending.length;
        _isLoading = false;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() => _isLoading = false);
      return false;
    }
  }

  Future<void> _syncData() async {
    await _live.syncNow();
    if (!mounted) return;
    final ok = _live.lastSyncedAt != null &&
        DateTime.now().difference(_live.lastSyncedAt!).inSeconds < 5;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Data synced successfully.' : 'Could not sync. Check your connection.',
        ),
      ),
    );
  }

  void _toggleTheme(bool isDark) {
    MyApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _live.syncNow(silent: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER + WELCOME (with decorative hero background)
                // ==================================================
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
                          onToggleTheme: () => _toggleTheme(isDark),
                          onNotifications: () {},
                          onLogout: _logout,
                        ),
                        const SizedBox(height: AppSizes.p24),
                        DashboardWelcomeBanner(
                          greeting: 'Welcome back, $_displayName',
                          subtitle: 'Here is your operational overview for today.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.p20),

                // ==================================================
                // SYNC BANNER
                // ==================================================
                SyncDataBanner(
                  isSyncing: _live.isSyncing,
                  lastSyncedLabel: _live.label,
                  onSync: _syncData,
                ),

                const SizedBox(height: AppSizes.p24),

                // ==================================================
                // QUICK ACTIONS
                // ==================================================
                DashboardActionCard(
                  icon: Icons.description_outlined,
                  title: 'Review Content',
                  description:
                      'Pending articles and field reports requiring validation.',
                  badgeLabel:
                      '${_isLoading ? _pendingReviewCount : _pendingReviewCount} Pending',
                  accent: DashAccent.green,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/expert/review/list',
                    );
                    if (mounted) _live.syncNow(silent: true);
                  },
                ),

                DashboardActionCard(
                  icon: Icons.biotech_outlined,
                  title: 'Review Cases',
                  description: 'Active pest and disease identification requests.',
                  accent: DashAccent.amber,
                  onTap: () {
                    Navigator.pushNamed(context, '/expert/case/detail');
                  },
                ),

                DashboardActionCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Expert Analytics',
                  description: 'Your review accuracy and throughput.',
                  accent: DashAccent.blue,
                  onTap: () {
                    Navigator.pushNamed(context, '/expert/analytics');
                  },
                ),

                // Analytics stat chips removed (use ExpertAnalyticsScreen for real data)


                const SizedBox(height: AppSizes.p12),

                // ==================================================
                // RECENT ACTIVITY
                // ==================================================
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
                      title: 'Approved field report: Soil Moisture',
                      subtitle: '2 hours ago • Submitted by Field Tech',
                      pillLabel: 'Approved',
                      accent: DashAccent.green,
                    ),
                    RecentActivityRow(
                      icon: Icons.priority_high_rounded,
                      title: 'Reviewed Case: Suspected Blight',
                      subtitle: '3 hours ago • Flagged for further observation',
                      pillLabel: 'Flagged',
                      accent: DashAccent.amber,
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
    ));
  }
}

