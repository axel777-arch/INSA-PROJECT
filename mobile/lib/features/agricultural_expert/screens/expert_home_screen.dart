import 'dart:async'; // 🌟 Added for dynamic sync timer loops
import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/config/user_session.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ExpertHomeScreen extends StatefulWidget {
  const ExpertHomeScreen({super.key});

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());

  int _pendingReviewCount = 0;
  bool _isLoading = true;
  bool _isSyncing = false;

  // 🌟 Dynamic sync tracking state fields
  DateTime? _lastSyncedTime;
  String _lastSynced = 'Just now';
  Timer? _syncTrackerTimer;

  String _displayName = 'Expert';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCounts();

    // Set dynamic operational time bounds
    _lastSyncedTime = DateTime.now();
    _updateSyncString();

    // 🌟 Background interval timer to update strings and refresh indicators automatically
    _syncTrackerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _updateSyncString();
        _loadCountsSilent(); // Lively fetches updated counts behind the scenes
      }
    });
  }

  @override
  void dispose() {
    // 🌟 Protect against context/memory runtime memory leaks
    _syncTrackerTimer?.cancel();
    super.dispose();
  }

  // 🌟 Dynamic duration parser to update the last sync text
  void _updateSyncString() {
    if (_lastSyncedTime == null) {
      setState(() => _lastSynced = 'Never');
      return;
    }

    final difference = DateTime.now().difference(_lastSyncedTime!);
    
    setState(() {
      if (difference.inSeconds < 60) {
        _lastSynced = 'Just now';
      } else if (difference.inMinutes < 60) {
        _lastSynced = '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        _lastSynced = '${difference.inHours}h ago';
      } else {
        _lastSynced = '${difference.inDays}d ago';
      }
    });
  }

  Future<void> _loadUserName() async {
    final user = await UserSession.get();
    if (!mounted) return;
    setState(() => _displayName = user?.fullName ?? 'Expert');
  }

  Future<void> _loadCounts() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final pending = await _contentService.getAdvisories(status: 'IN_REVIEW');
      if (!mounted) return;
      setState(() {
        _pendingReviewCount = pending.length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _pendingReviewCount = 0; _isLoading = false; });
    }
  }

  // 🌟 Lively background loader that avoids screen blocking spinner indicators
  Future<void> _loadCountsSilent() async {
    if (_isSyncing) return;
    try {
      final pending = await _contentService.getAdvisories(status: 'IN_REVIEW');
      if (!mounted) return;
      setState(() {
        _pendingReviewCount = pending.length;
      });
    } catch (e) {
      debugPrint('Silent counts reload encountered error: $e');
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
      _lastSyncedTime = DateTime.now(); // 🌟 Stamp real sync baseline timestamp
    });
    
    _updateSyncString(); // 🌟 Recompute text string properties instantly

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
                          onNotifications: () => Navigator.pushNamed(context, '/alerts'),
                          onLogout: () => LogoutConfirmationDialog.show(context),
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

                const SizedBox(height: AppSizes.p12),

                // ==================================================
                // RECENT ACTIVITY
                // ==================================================
                DashboardSectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'View all',
                  onAction: () => Navigator.pushNamed(context, '/expert/review/list'),
                ),

                const SizedBox(height: AppSizes.p12),

                RecentActivityCard(
                  children: const [
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
