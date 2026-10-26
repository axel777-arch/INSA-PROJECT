import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/live/live_sync_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../services/api_client.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/content_service.dart';
import '../../../../services/farmer_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';

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
  late final LiveSyncController _live;
  int _totalFarmers = 0;
  int _publishedCount = 0;
  int _inReviewCount = 0;
  int _draftCount = 0;
  List<AdminAuditLog> _activityLogs = [];

  @override
  void initState() {
    super.initState();
    _live = LiveSyncController(
      storageKey: 'admin_home',
      refresh: _loadOverview,
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

  /// Loads the metrics. Returns true on success so "last synced" is only
  /// updated by a real, successful sync.
  Future<bool> _loadOverview() async {
    try {
      final farmers = await _farmerService.getFarmers();
      final published = await _contentService.getAdvisories(
        status: 'PUBLISHED',
      );
      final inReview = await _contentService.getAdvisories(status: 'IN_REVIEW');
      final drafts = await _contentService.getAdvisories(status: 'DRAFT');
      final activityLogs = await _adminService.getAuditLogs(limit: 4);
      if (!mounted) return false;
      setState(() {
        _totalFarmers = farmers.length;
        _publishedCount = published.length;
        _inReviewCount = inReview.length;
        _draftCount = drafts.length;
        _activityLogs = activityLogs;
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

  String _actionLabel(String action, AppLocalizations loc) => switch (action) {
    'USER_APPROVED' => loc.approved,
    'USER_REJECTED' => loc.rejected,
    _ =>
      action
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' '),
  };

  String _roleLabel(String role, AppLocalizations loc) => switch (role) {
    'ADMIN' => loc.adminRole,
    'EXPERT' => loc.expertRole,
    'EXTENSION_WORKER' => loc.extensionWorkerRole,
    _ => loc.systemLabel,
  };

  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _live.syncNow(silent: true),
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
                                title: appText('AgriAdmin Portal'),
                                logoIcon: Icons.admin_panel_settings_outlined,
                                isDark: isDark,
                                onToggleTheme: () {
                                  MyApp.themeNotifier.value = isDark
                                      ? ThemeMode.light
                                      : ThemeMode.dark;
                                },
                                onNotifications: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.alertsList,
                                  );
                                },
                              ),
                              const SizedBox(height: AppSizes.p24),
                              DashboardWelcomeBanner(
                                greeting: loc.systemOverview,
                                subtitle: loc.platformActivitySubtitle,
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

                      DashboardSectionHeader(title: loc.keyMetrics),
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
                            loc.totalFarmers,
                            '$_totalFarmers',
                            Icons.people_outline_rounded,
                            DashAccent.green,
                          ),
                          _buildMetricCard(
                            loc.extensionWorkers,
                            '48',
                            Icons.engineering_outlined,
                            DashAccent.amber,
                          ),
                          _buildMetricCard(
                            loc.agronomyExperts,
                            '24',
                            Icons.psychology_outlined,
                            DashAccent.blue,
                          ),
                          _buildMetricCard(
                            loc.publishedBulletins,
                            '$_publishedCount',
                            Icons.article_outlined,
                            DashAccent.blue,
                          ),
                          _buildMetricCard(
                            loc.messagesSent,
                            '8,420',
                            Icons.sms_outlined,
                            DashAccent.green,
                          ),
                          _buildMetricCard(
                            loc.deliveryRate,
                            '94.8%',
                            Icons.check_circle_outline_rounded,
                            DashAccent.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.p24),

                      DashboardSectionHeader(title: loc.farmersByRegion),
                      const SizedBox(height: AppSizes.p12),
                      _panelCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRegionRow(
                              'Oromia',
                              520,
                              0.75,
                              AppColors.tintGreenFg,
                            ),
                            _buildRegionRow(
                              'Amhara',
                              340,
                              0.55,
                              AppColors.tintAmberFg,
                            ),
                            _buildRegionRow(
                              'SNNPR',
                              220,
                              0.35,
                              AppColors.tintBlueFg,
                            ),
                            _buildRegionRow(
                              'Tigray',
                              168,
                              0.25,
                              AppColors.tintRedFg,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.p24),

                      DashboardSectionHeader(title: loc.contentReviewStatus),
                      const SizedBox(height: AppSizes.p12),
                      _panelCard(
                        isDark: isDark,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPieMock(
                              loc.published,
                              '$_publishedCount',
                              AppColors.tintGreenFg,
                            ),
                            _buildPieMock(
                              loc.inReview,
                              '$_inReviewCount',
                              AppColors.tintAmberFg,
                            ),
                            _buildPieMock(
                              loc.drafts,
                              '$_draftCount',
                              AppColors.tintBlueFg,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.p24),

                      DashboardSectionHeader(
                        title: loc.systemActivityLog,
                        actionLabel: loc.viewAll,
                        onAction: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.adminAuditLogs,
                          );
                        },
                      ),
                      const SizedBox(height: AppSizes.p12),

                      RecentActivityCard(
                        children: _activityLogs.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(AppSizes.p16),
                                  child: Text(loc.noRecentActivity),
                                ),
                              ]
                            : [
                                for (int i = 0; i < _activityLogs.length; i++)
                                  RecentActivityRow(
                                    icon: Icons.history_rounded,
                                    title:
                                        '${_activityLogs[i].actorName}: ${_actionLabel(_activityLogs[i].action, loc)} — ${_activityLogs[i].target}',
                                    subtitle: _formatTimestamp(
                                      _activityLogs[i].timestamp,
                                    ),
                                    pillLabel: _roleLabel(
                                      _activityLogs[i].actorRole,
                                      loc,
                                    ),
                                    accent:
                                        _activityLogs[i].action.contains(
                                          'REJECT',
                                        )
                                        ? DashAccent.red
                                        : DashAccent.green,
                                    showDivider: i != _activityLogs.length - 1,
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
    DashAccent accent,
  ) {
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

        return Container(
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
