import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/config/user_session.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/live/live_sync_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../models/crop_calendar_model.dart';
import '../../../../models/farmer_case_model.dart';
import '../../../../models/market_price_model.dart';
import '../../../../models/notification_item_model.dart';
import '../../../../services/alerts_service.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../services/crop_calendar_service.dart';
import '../../../../services/farmer_case_service.dart';
import '../../../../services/farmer_service.dart';
import '../../../../services/market_service.dart';
import '../../../../services/offline_advisory_service.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final ApiClient _apiClient = ApiClient();
  late final ContentService _contentService;
  late final AlertsService _alertsService;
  late final FarmerService _farmerService;
  late final MarketService _marketService;
  late final CropCalendarService _calendarService;
  late final FarmerCaseService _caseService;
  late final OfflineAdvisoryService _offlineService;

  bool _isLoading = true;
  late final LiveSyncController _live;
  String _displayName = 'Farmer';
  final String _farmerRegion = 'Oromia / East Shewa';

  List<ContentModel> _publishedAdvisories = [];
  List<NotificationItemModel> _recentAlerts = [];
  List<String> _registeredCrops = [];
  List<MarketPriceModel> _marketPrices = [];
  List<CropCalendarModel> _upcomingTasks = [];
  List<FarmerCaseModel> _myCases = [];
  int _offlineSavedCount = 0;
  int _unreadAlertsCount = 0;

  @override
  void initState() {
    super.initState();
    _contentService = ContentService(apiClient: _apiClient);
    _alertsService = AlertsService(apiClient: _apiClient);
    _farmerService = FarmerService(apiClient: _apiClient);
    _marketService = MarketService(apiClient: _apiClient);
    _calendarService = CropCalendarService();
    _caseService = FarmerCaseService(apiClient: _apiClient);
    _offlineService = OfflineAdvisoryService();

    _live = LiveSyncController(
      storageKey: 'farmer_home',
      refresh: _loadDashboardData,
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

  /// Returns true on success so "last synced" only changes after a real sync.
  Future<bool> _loadDashboardData() async {
    try {
      final user = await UserSession.get();
      if (user != null) {
        _displayName = user.fullName;
      }

      // Fetch all farmer dashboard components in parallel
      final results = await Future.wait([
        _contentService.getAdvisories(status: 'PUBLISHED'),
        _alertsService.getAlerts(),
        _alertsService.getUnreadCount(),
        _marketService.getMarketPrices(),
        _calendarService.getCalendarEntries(),
        _caseService.getCases(),
        _offlineService.getSavedAdvisories(),
      ]);

      List<String> crops = ['Teff', 'Wheat', 'Maize'];
      if (user != null) {
        try {
          final farmer = await _farmerService.getFarmerByUserId(user.id);
          if (farmer != null) {
            final farmerCrops = await _farmerService.getFarmerCrops(farmer.id);
            if (farmerCrops.isNotEmpty) {
              crops = farmerCrops
                  .map((c) => (c['cropName'] ?? c['name'] ?? 'Crop').toString())
                  .toList();
            }
          }
        } catch (_) {}
      }

      if (!mounted) return false;
      setState(() {
        _publishedAdvisories = results[0] as List<ContentModel>;
        _recentAlerts = results[1] as List<NotificationItemModel>;
        _unreadAlertsCount = results[2] as int;
        _marketPrices = results[3] as List<MarketPriceModel>;
        _upcomingTasks = results[4] as List<CropCalendarModel>;
        _myCases = results[5] as List<FarmerCaseModel>;
        _offlineSavedCount = (results[6] as List).length;
        _registeredCrops = crops;
        _isLoading = false;
      });
      return true;
    } catch (e) {
      debugPrint('[FarmerHomeScreen] Dashboard data load notice: $e');
      if (!mounted) return false;
      setState(() => _isLoading = false);
      return false;
    }
  }

  Future<void> _syncData() async {
    await _live.syncNow();
    if (!mounted) return;
    final last = _live.lastSyncedAt;
    final ok = last != null && DateTime.now().difference(last).inSeconds < 5;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Farmer dashboard synced successfully.'
              : 'Could not sync. Check your connection.',
        ),
      ),
    );
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
                  onRefresh: _syncData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Header with theme & notification bell
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
                                  showNotificationDot: _unreadAlertsCount > 0,
                                  onToggleTheme: () {
                                    MyApp.themeNotifier.value = isDark
                                        ? ThemeMode.light
                                        : ThemeMode.dark;
                                  },
                                  onNotifications: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/alerts',
                                    ).then((_) => _live.syncNow(silent: true));
                                  },
                                ),
                                const SizedBox(height: AppSizes.p20),
                                DashboardWelcomeBanner(
                                  greeting: loc.welcomeBack(_displayName),
                                  subtitle:
                                      '${loc.farmerDashboard} • $_farmerRegion',
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSizes.p16),

                        // Sync Banner
                        SyncDataBanner(
                          isSyncing: _live.isSyncing,
                          lastSyncedLabel: _live.label,
                          label: loc.syncData,
                          onSync: _syncData,
                        ),

                        const SizedBox(height: AppSizes.p20),

                        // ── ACCESSIBILITY & VOICE-FIRST HERO BANNER ──────────
                        _buildAccessibilityVoiceBanner(theme, loc),

                        const SizedBox(height: AppSizes.p20),

                        // ── RECENT ALERTS PREVIEW (Part 2 Item 1 & 7) ────────
                        if (_recentAlerts.isNotEmpty) ...[
                          DashboardSectionHeader(
                            title: loc.alerts,
                            actionLabel: loc.viewAll,
                            onAction: () =>
                                Navigator.pushNamed(context, '/alerts'),
                          ),
                          const SizedBox(height: AppSizes.p12),
                          _buildRecentAlertsPreview(theme, loc),
                          const SizedBox(height: AppSizes.p20),
                        ],

                        // ── LARGE QUICK ACTION TILES (Part 2 Item 6) ────────
                        DashboardSectionHeader(title: loc.quickActions),
                        const SizedBox(height: AppSizes.p12),
                        _buildQuickActionCards(context, loc),

                        const SizedBox(height: AppSizes.p24),

                        // ── MARKET PRICES TICKER PREVIEW (Part 2 Item 2) ─────
                        DashboardSectionHeader(
                          title: loc.marketPricesTitle,
                          actionLabel: loc.viewAll,
                          onAction: () =>
                              Navigator.pushNamed(context, '/farmer/market'),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        _buildMarketPricePreview(theme, loc),

                        const SizedBox(height: AppSizes.p24),

                        // ── CROP CALENDAR REMINDERS (Part 2 Item 3) ──────────
                        DashboardSectionHeader(
                          title: loc.cropCalendar,
                          actionLabel: loc.viewAll,
                          onAction: () => Navigator.pushNamed(
                            context,
                            '/farmer/crop-calendar',
                          ),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        _buildCropCalendarPreview(theme, loc),

                        const SizedBox(height: AppSizes.p24),

                        // ── SUBMITTED CASES & QUESTIONS (Part 2 Item 7) ──────
                        DashboardSectionHeader(
                          title: loc.cases,
                          actionLabel: loc.viewAll,
                          onAction: () =>
                              Navigator.pushNamed(context, '/farmer/cases'),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        _buildCasesPreview(theme, loc),

                        const SizedBox(height: AppSizes.p24),

                        // ── PUBLISHED ADVISORIES (Part 2 Item 1 & 4) ─────────
                        DashboardSectionHeader(
                          title: loc.publishedAdvisories,
                          actionLabel: loc.viewAll,
                          onAction: () =>
                              Navigator.pushNamed(context, '/content/list'),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        _buildPublishedAdvisoriesList(theme, loc),

                        const SizedBox(height: AppSizes.p24),

                        // ── REGISTERED CROPS ────────────────────────────────
                        DashboardSectionHeader(title: loc.registeredCrops),
                        const SizedBox(height: AppSizes.p12),
                        _buildRegisteredCropsCard(theme),

                        const SizedBox(height: AppSizes.p32),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAccessibilityVoiceBanner(ThemeData theme, AppLocalizations loc) {
    return Card(
      color: theme.primaryColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(AppSizes.r12),
              ),
              child: const Icon(
                Icons.record_voice_over_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.voiceAssistant,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.voiceAssistantDesc,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/farmer/accessibility');
              },
              child: Text(appText('Open')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCards(BuildContext context, AppLocalizations loc) {
    return Column(
      children: [
        DashboardActionCard(
          icon: Icons.support_agent_rounded,
          title: loc.askExtensionWorker,
          description: loc.askWorkerDesc,
          accent: DashAccent.green,
          badgeLabel: 'Direct Support',
          onTap: () => Navigator.pushNamed(context, '/farmer/cases'),
        ),
        DashboardActionCard(
          icon: Icons.storefront_rounded,
          title: loc.marketPricesTitle,
          description: loc.marketPricesSubtitle,
          accent: DashAccent.amber,
          onTap: () => Navigator.pushNamed(context, '/farmer/market'),
        ),
        DashboardActionCard(
          icon: Icons.calendar_month_rounded,
          title: loc.cropCalendar,
          description: loc.cropCalendarSubtitle,
          accent: DashAccent.blue,
          onTap: () => Navigator.pushNamed(context, '/farmer/crop-calendar'),
        ),
        DashboardActionCard(
          icon: Icons.offline_pin_rounded,
          title: loc.offlineLibrary,
          description:
              'Access expert advisories without an internet connection.',
          accent: DashAccent.green,
          badgeLabel: '$_offlineSavedCount Saved',
          onTap: () => Navigator.pushNamed(
            context,
            '/farmer/offline-advisories',
          ).then((_) => _live.syncNow(silent: true)),
        ),
        DashboardActionCard(
          icon: Icons.notifications_active_outlined,
          title: loc.alerts,
          description:
              'Severe weather, pest alerts and commodity market spikes.',
          accent: DashAccent.red,
          badgeLabel: _unreadAlertsCount > 0 ? '$_unreadAlertsCount New' : null,
          onTap: () => Navigator.pushNamed(
            context,
            '/alerts',
          ).then((_) => _live.syncNow(silent: true)),
        ),
      ],
    );
  }

  Widget _buildMarketPricePreview(ThemeData theme, AppLocalizations loc) {
    if (_marketPrices.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Text(appText('No market price data available.')),
        ),
      );
    }

    final topItems = _marketPrices.take(3).toList();

    return Card(
      child: Column(
        children: topItems.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;

          return Column(
            children: [
              ListTile(
                title: Text(
                  item.commodity,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${item.market} • ${item.freshnessStatus}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.pricePerQuintal.toStringAsFixed(0)} ${item.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      loc.perQuintal,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                onTap: () => Navigator.pushNamed(context, '/farmer/market'),
              ),
              if (idx < topItems.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCropCalendarPreview(ThemeData theme, AppLocalizations loc) {
    if (_upcomingTasks.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Text(appText('No upcoming crop tasks scheduled.')),
        ),
      );
    }

    final tasks = _upcomingTasks.take(2).toList();

    return Column(
      children: tasks.map((task) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.p8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.event_note_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              '${task.cropName} — ${task.stage}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${task.timePeriod} • ${task.recommendedTask}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Icon(
              task.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: task.isCompleted ? AppColors.success : Colors.grey,
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/farmer/crop-calendar',
            ).then((_) => _live.syncNow(silent: true)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCasesPreview(ThemeData theme, AppLocalizations loc) {
    if (_myCases.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: Colors.grey),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Text(
                  appText('Have a crop problem? Ask your extension agent.'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/farmer/cases'),
                child: Text(appText('Ask Now')),
              ),
            ],
          ),
        ),
      );
    }

    final topCase = _myCases.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Case: #${topCase.id}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                StatusPill(
                  label: loc.caseStatusLabel(topCase.status),
                  accent: topCase.status == 'RESOLVED'
                      ? DashAccent.green
                      : DashAccent.amber,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              topCase.subject,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              topCase.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            if (topCase.responseNotes != null) ...[
              const SizedBox(height: AppSizes.p12),
              Container(
                padding: const EdgeInsets.all(AppSizes.p10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Response received: ${topCase.responseNotes!}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPublishedAdvisoriesList(ThemeData theme, AppLocalizations loc) {
    if (_publishedAdvisories.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Text(appText('No published advisories currently available.')),
        ),
      );
    }

    final items = _publishedAdvisories.take(3).toList();

    return Column(
      children: items.map((adv) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.p8),
          child: ListTile(
            title: Text(
              adv.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              adv.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/content/detail',
                arguments: adv.id,
              ).then((_) => _live.syncNow(silent: true));
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentAlertsPreview(ThemeData theme, AppLocalizations loc) {
    final topAlert = _recentAlerts.first;
    final isCritical = topAlert.severity.toUpperCase() == 'HIGH';

    return Card(
      color: isCritical
          ? AppColors.error.withValues(alpha: 0.08)
          : AppColors.warning.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
        side: BorderSide(
          color: isCritical
              ? AppColors.error.withValues(alpha: 0.4)
              : AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        leading: Icon(
          isCritical ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
          color: isCritical ? AppColors.error : AppColors.warning,
          size: 28,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                topAlert.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isCritical ? AppColors.error : AppColors.warning,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                topAlert.severity.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          topAlert.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/alerts',
          ).then((_) => _live.syncNow(silent: true));
        },
      ),
    );
  }

  Widget _buildRegisteredCropsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSizes.p8,
              runSpacing: AppSizes.p8,
              children: [
                ..._registeredCrops.map(
                  (crop) => Chip(
                    avatar: const Icon(Icons.grass_rounded, size: 16),
                    label: Text(crop),
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: Text(appText('Manage in Profile')),
                  onPressed: () {
                    Navigator.pushNamed(context, '/farmer/profile');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
