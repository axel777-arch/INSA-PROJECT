import 'package:flutter/material.dart';
import 'admin_audit_logs_screen.dart';
import 'admin_user_management_screen.dart';
import '../../simulator/screens/sms_simulator_screen.dart';
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../services/farmer_service.dart';
import '../../../../services/admin_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/auth_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final AdminService _adminService = AdminService(apiClient: ApiClient());

  bool _isLoading = true;
  bool _isSyncing = false;
  String _lastSynced = '1m ago';
  int _totalFarmers = 0;
  int _publishedCount = 0;
  int _inReviewCount = 0;
  int _draftCount = 0;
  int _extensionWorkerCount = 0;
  int _expertCount = 0;
  int _messageCount = 0;
  double _deliveryRate = 0;
  Map<String, dynamic> _regionCounts = {};
  List<Map<String, dynamic>> _activityLogs = [];

  String _friendlyActivity(Map<String, dynamic> log) {
    final action = log['action'] as String? ?? 'ACTIVITY';
    const labels = {
      'USER_APPROVED': 'approved',
      'USER_REJECTED': 'rejected',
      'USER_ENABLED': 'enabled',
      'USER_DISABLED': 'disabled',
    };
    final verb = labels[action] ?? action.replaceAll('_', ' ').toLowerCase();
    final role = switch (log['actorRole']) {
      'ADMIN' => 'Admin',
      'EXPERT' => 'Agronomy Expert',
      'EXTENSION_WORKER' => 'Extension Worker',
      'FARMER' => 'Farmer',
      _ => 'System',
    };
    return '${log['actorName'] ?? 'System'} ($role) $verb ${log['targetName'] ?? 'a user'}';
  }

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _adminService.getOverview(),
        _adminService.getAuditLogs(),
      ]);
      final overview = results[0] as Map<String, dynamic>;
      final activityLogs = results[1] as List<Map<String, dynamic>>;
      if (!mounted) return;
      setState(() {
        _totalFarmers = (overview['totalFarmers'] as num?)?.toInt() ?? 0;
        _publishedCount = (overview['publishedContent'] as num?)?.toInt() ?? 0;
        _inReviewCount = (overview['pendingApprovals'] as num?)?.toInt() ?? 0;
        _draftCount = (overview['draftContent'] as num?)?.toInt() ?? 0;
        _extensionWorkerCount =
            (overview['approved_extension_worker'] as num?)?.toInt() ?? 0;
        _expertCount = (overview['approved_expert'] as num?)?.toInt() ?? 0;
        _messageCount = (overview['totalMessages'] as num?)?.toInt() ?? 0;
        _deliveryRate = (overview['deliveryRate'] as num?)?.toDouble() ?? 0;
        _regionCounts = Map<String, dynamic>.from(
          overview['regionCounts'] as Map? ?? {},
        );
        _activityLogs = activityLogs.take(4).toList();
        _isLoading = false;
      });
      return;
    } catch (_) {
      // Keep the dashboard available while an older backend is being upgraded.
    }
    final farmers = await _farmerService.getFarmers();
    final published = await _contentService.getAdvisories(status: 'PUBLISHED');
    final inReview = await _contentService.getAdvisories(status: 'IN_REVIEW');
    final drafts = await _contentService.getAdvisories(status: 'DRAFT');
    if (!mounted) return;
    setState(() {
      _totalFarmers = farmers.length;
      _publishedCount = published.length;
      _inReviewCount = inReview.length;
      _draftCount = 20 + drafts.length;
      _isLoading = false;
    });
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    await _loadOverview();
    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _lastSynced = 'Just now';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadOverview,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSizes.p16),
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
                                title: 'AgriAdmin Portal',
                                logoIcon: Icons.admin_panel_settings_outlined,
                                isDark: isDark,
                                onToggleTheme: () {
                                  MyApp.themeNotifier.value = isDark
                                      ? ThemeMode.light
                                      : ThemeMode.dark;
                                },
                                onNotifications: () {
                                  Navigator.pushNamed(context, '/alerts');
                                },
                                onLogout: () {
                                  AuthService(
                                    apiClient: ApiClient(),
                                  ).logout().then((_) {
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: AppSizes.p24),
                              const DashboardWelcomeBanner(
                                greeting: 'System Overview',
                                subtitle:
                                    'Platform-wide activity and health metrics.',
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

                      DashboardSectionHeader(title: 'Key Metrics'),
                      const SizedBox(height: AppSizes.p12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSizes.p12,
                        mainAxisSpacing: AppSizes.p12,
                        childAspectRatio: 1.5,
                        children: [
                          _buildMetricCard(
                            'Total Farmers',
                            '$_totalFarmers',
                            Icons.people_outline_rounded,
                            DashAccent.green,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminUserManagementScreen(),
                              ),
                            ),
                          ),
                          _buildMetricCard(
                            'Extension Workers',
                            '$_extensionWorkerCount',
                            Icons.engineering_outlined,
                            DashAccent.amber,
                          ),
                          _buildMetricCard(
                            'Agronomy Experts',
                            '$_expertCount',
                            Icons.psychology_outlined,
                            DashAccent.blue,
                          ),
                          _buildMetricCard(
                            'Published Bulletins',
                            '$_publishedCount',
                            Icons.article_outlined,
                            DashAccent.blue,
                          ),
                          _buildMetricCard(
                            'Messages Sent',
                            '$_messageCount',
                            Icons.sms_outlined,
                            DashAccent.green,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SmsSimulatorScreen(),
                              ),
                            ),
                          ),
                          _buildMetricCard(
                            'Delivery Rate',
                            '${_deliveryRate.toStringAsFixed(1)}%',
                            Icons.check_circle_outline_rounded,
                            DashAccent.green,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminAuditLogsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.p24),

                      DashboardSectionHeader(title: 'Farmers by Region'),
                      const SizedBox(height: AppSizes.p12),
                      _panelCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _regionCounts.isEmpty
                              ? [const Text('No regional data available.')]
                              : _regionCounts.entries.map((entry) {
                                  final count = (entry.value as num).toInt();
                                  final maxCount = _regionCounts.values
                                      .map((value) => (value as num).toInt())
                                      .fold<int>(
                                        1,
                                        (max, value) =>
                                            value > max ? value : max,
                                      );
                                  return _buildRegionRow(
                                    entry.key,
                                    count,
                                    count / maxCount,
                                    AppColors.tintGreenFg,
                                  );
                                }).toList(),
                        ),
                      ),

                      const SizedBox(height: AppSizes.p24),

                      DashboardSectionHeader(title: 'Content Review Status'),
                      const SizedBox(height: AppSizes.p12),
                      _panelCard(
                        isDark: isDark,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPieMock(
                              'Published',
                              '$_publishedCount',
                              AppColors.tintGreenFg,
                            ),
                            _buildPieMock(
                              'In Review',
                              '$_inReviewCount',
                              AppColors.tintAmberFg,
                            ),
                            _buildPieMock(
                              'Drafts',
                              '$_draftCount',
                              AppColors.tintBlueFg,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.p24),

                      DashboardSectionHeader(
                        title: 'System Activity Log',
                        actionLabel: 'View all',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminAuditLogsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),

                      RecentActivityCard(
                        children: _activityLogs.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(AppSizes.p16),
                                  child: Text('No recent activity.'),
                                ),
                              ]
                            : _activityLogs.asMap().entries.map((entry) {
                                final log = entry.value;
                                final action =
                                    log['action'] as String? ?? 'ACTIVITY';
                                final accent =
                                    action.contains('REJECT') ||
                                        action.contains('DISABLE')
                                    ? DashAccent.red
                                    : action.contains('APPROVE') ||
                                          action.contains('ENABLE')
                                    ? DashAccent.green
                                    : DashAccent.blue;
                                return RecentActivityRow(
                                  icon: action.contains('SMS')
                                      ? Icons.sms_outlined
                                      : Icons.history_rounded,
                                  title: _friendlyActivity(log),
                                  subtitle: '${log['createdAt'] ?? ''}',
                                  pillLabel:
                                      log['actorRole'] as String? ?? 'System',
                                  accent: accent,
                                  showDivider:
                                      entry.key < _activityLogs.length - 1,
                                );
                              }).toList(),
                      ),

                      const SizedBox(height: AppSizes.p24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _panelCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(
          color: isDark ? AppColors.borderDarkTheme : AppColors.divider,
        ),
      ),
      child: child,
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    DashAccent accent, {
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final tint = accent == DashAccent.green
            ? (isDark ? AppColors.tintGreenFgDark : AppColors.tintGreenFg)
            : accent == DashAccent.amber
            ? (isDark ? AppColors.tintAmberFgDark : AppColors.tintAmberFg)
            : (isDark ? AppColors.tintBlueFgDark : AppColors.tintBlueFg);
        final tintBg = accent == DashAccent.green
            ? (isDark ? AppColors.tintGreenBgDark : AppColors.tintGreenBg)
            : accent == DashAccent.amber
            ? (isDark ? AppColors.tintAmberBgDark : AppColors.tintAmberBg)
            : (isDark ? AppColors.tintBlueBgDark : AppColors.tintBlueBg);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackgroundDarkTheme : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.r16),
              border: Border.all(
                color: isDark ? AppColors.borderDarkTheme : AppColors.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: tintBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: tint, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegionRow(String name, int count, double fraction, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(name, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPieMock(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 6),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
