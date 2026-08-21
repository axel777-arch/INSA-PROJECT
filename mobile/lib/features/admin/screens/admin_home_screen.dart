import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../services/api_client.dart';
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

  bool _isLoading = true;
  bool _isSyncing = false;
  String _lastSynced = '1m ago';
  int _totalFarmers = 0;
  int _publishedCount = 0;
  int _inReviewCount = 0;
  int _draftCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() => _isLoading = true);
    final farmers = await _farmerService.getFarmers();
    final published = await _contentService.getAdvisories(status: 'PUBLISHED');
    final inReview = await _contentService.getAdvisories(status: 'IN_REVIEW');
    final drafts = await _contentService.getAdvisories(status: 'DRAFT');
    if (!mounted) return;
    setState(() {
      _totalFarmers = farmers.length;
      _publishedCount = 124 + published.length;
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

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
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
                                MyApp.themeNotifier.value =
                                    isDark ? ThemeMode.light : ThemeMode.dark;
                              },
                              onNotifications: () {},
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
                        _buildMetricCard('Total Farmers', '${1200 + _totalFarmers}',
                            Icons.people_outline_rounded, DashAccent.green),
                        _buildMetricCard('Extension Workers', '48',
                            Icons.engineering_outlined, DashAccent.amber),
                        _buildMetricCard('Agronomy Experts', '24',
                            Icons.psychology_outlined, DashAccent.blue),
                        _buildMetricCard('Published Bulletins', '$_publishedCount',
                            Icons.article_outlined, DashAccent.blue),
                        _buildMetricCard('Messages Sent', '8,420',
                            Icons.sms_outlined, DashAccent.green),
                        _buildMetricCard('Delivery Rate', '94.8%',
                            Icons.check_circle_outline_rounded, DashAccent.green),
                      ],
                    ),

                    const SizedBox(height: AppSizes.p24),

                    DashboardSectionHeader(title: 'Farmers by Region'),
                    const SizedBox(height: AppSizes.p12),
                    _panelCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRegionRow('Oromia', 520, 0.75, AppColors.tintGreenFg),
                          _buildRegionRow('Amhara', 340, 0.55, AppColors.tintAmberFg),
                          _buildRegionRow('SNNPR', 220, 0.35, AppColors.tintBlueFg),
                          _buildRegionRow('Tigray', 168, 0.25, AppColors.tintRedFg),
                        ],
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
                          _buildPieMock('Published', '$_publishedCount', AppColors.tintGreenFg),
                          _buildPieMock('In Review', '$_inReviewCount', AppColors.tintAmberFg),
                          _buildPieMock('Drafts', '$_draftCount', AppColors.tintBlueFg),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.p24),

                    DashboardSectionHeader(
                      title: 'System Activity Log',
                      actionLabel: 'View all',
                      onAction: () {},
                    ),
                    const SizedBox(height: AppSizes.p12),

                    RecentActivityCard(
                      children: const [
                        RecentActivityRow(
                          icon: Icons.person_add_alt_1_outlined,
                          title: 'Jane Doe (Extension) registered farmer John Smith',
                          subtitle: '2 mins ago',
                          pillLabel: 'New',
                          accent: DashAccent.green,
                        ),
                        RecentActivityRow(
                          icon: Icons.check_rounded,
                          title: 'Dr. Aris (Expert) approved Wheat Rust Alert bulletin',
                          subtitle: '15 mins ago',
                          pillLabel: 'Approved',
                          accent: DashAccent.green,
                        ),
                        RecentActivityRow(
                          icon: Icons.sms_outlined,
                          title: 'System dispatched 452 SMS alerts',
                          subtitle: '1 hour ago',
                          pillLabel: 'System',
                          accent: DashAccent.blue,
                        ),
                        RecentActivityRow(
                          icon: Icons.backup_outlined,
                          title: 'Database backup completed successfully',
                          subtitle: '4 hours ago',
                          pillLabel: 'System',
                          accent: DashAccent.blue,
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

  Widget _buildMetricCard(String label, String value, IconData icon, DashAccent accent) {
    return Builder(builder: (context) {
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
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: tintBg, shape: BoxShape.circle),
                  child: Icon(icon, color: tint, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      );
    });
  }

  Widget _buildRegionRow(String name, int count, double fraction, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(name, style: const TextStyle(fontSize: 12))),
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
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

