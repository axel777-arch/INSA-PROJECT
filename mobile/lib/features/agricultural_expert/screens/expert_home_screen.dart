import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../services/mock_api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ExpertHomeScreen extends StatefulWidget {
  const ExpertHomeScreen({super.key});

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> {
  final ContentService _contentService =
      ContentService(apiClient: MockApiClient());

  int _pendingReviewCount = 0;
  bool _isLoading = true;
  bool _isSyncing = false;
  String _lastSynced = '2m ago';

  // Temporary mock values. These can later come from the backend.
  final int _pendingCases = 8;
  final int _totalApprovals = 148;
  final int _totalRejections = 23;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final pending =
          await _contentService.getAdvisories(status: 'IN_REVIEW');
      if (!mounted) return;
      setState(() {
        _pendingReviewCount = pending.length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingReviewCount = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    await Future.delayed(const Duration(milliseconds: 800));
    await _loadCounts();

    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _lastSynced = 'Just now';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data synced successfully.')),
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
          onRefresh: _loadCounts,
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
                          onLogout: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                        const SizedBox(height: AppSizes.p24),
                        const DashboardWelcomeBanner(
                          greeting: 'Welcome back, Dr. Aris 👋',
                          subtitle:
                              'Here is your operational overview for today.',
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
                  isSyncing: _isSyncing,
                  lastSyncedLabel: _lastSynced,
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
                    if (mounted) _loadCounts();
                  },
                ),

                DashboardActionCard(
                  icon: Icons.biotech_outlined,
                  title: 'Review Cases',
                  description:
                      'Active pest and disease identification requests.',
                  badgeLabel: '$_pendingCases Pending',
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

                Padding(
                  padding: const EdgeInsets.only(
                    left: 68,
                    top: 4,
                    bottom: AppSizes.p12,
                  ),
                  child: Row(
                    children: [
                      InlineStatChip(
                        value: '$_totalApprovals',
                        label: 'Approvals',
                        accent: DashAccent.blue,
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Text('|', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: AppSizes.p12),
                      InlineStatChip(
                        value: '$_totalRejections',
                        label: 'Rejections',
                        accent: DashAccent.blue,
                      ),
                    ],
                  ),
                ),

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
