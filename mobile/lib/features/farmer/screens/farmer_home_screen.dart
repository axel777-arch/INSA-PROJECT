import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/dashboard_widgets.dart';
import '../../../../core/widgets/dashboard_hero.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/messaging_service.dart';
import '../../../../services/weather_service.dart';

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
  String _locationName = 'Farm location';
  String _displayName = 'Farmer';
  WeatherConditions? _conditions;
  int _unreadAlerts = 0;
  Timer? _refreshTimer;
  final WeatherService _weatherService = WeatherService();
  final MessagingService _messagingService = MessagingService(apiClient: ApiClient());

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadIdentity();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadLiveData(silent: true));
  }

  Future<void> _loadLiveData({bool silent = false}) async {
    try {
      final results = await Future.wait([
        _weatherService.getCurrentConditions(latitude: _latitude, longitude: _longitude),
        _messagingService.getMessages(),
      ]);
      if (!mounted) return;
      final messages = results[1] as List<dynamic>;
      setState(() {
        _conditions = results[0] as WeatherConditions;
        _unreadAlerts = messages.where((message) => !message.isOutgoing && !message.read).length;
      });
    } catch (_) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live data is temporarily unavailable.')));
      }
    }
  }

  Future<void> _loadIdentity() async {
    final user = await AuthService(apiClient: ApiClient()).getMe();
    if (mounted && user != null) setState(() => _displayName = user.fullName);
  }

  Future<void> _loadLocation() async {
    try {
      var place = 'Ethiopia';
      try {
        final user = await AuthService(apiClient: ApiClient()).getMe();
        if (user != null) {
          final farmer = await ApiClient().get('/farmers/user/${user.id}') as Map<String, dynamic>;
          place = (farmer['region'] as String?)?.trim().isNotEmpty == true
              ? farmer['region'] as String
              : place;
        }
      } catch (_) {}
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent('$place, Ethiopia')}&format=json&limit=1',
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
        _locationName = (result['display_name'] as String?)?.split(',').take(2).join(', ') ?? 'Ethiopia';
      });
      await _loadLiveData(silent: true);
    } catch (_) {
      if (mounted) {
        setState(() => _locationUnavailable = true);
        await _loadLiveData(silent: true);
      }
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    await _loadLiveData();
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
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
                          onLogout: () {
                            AuthService(apiClient: ApiClient()).logout().then((
                              _,
                            ) {
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
                        DashboardWelcomeBanner(
                          greeting: 'Welcome back, $_displayName',
                          subtitle:
                              '$_locationName • Here is your farm overview.',
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
                              : _locationName,
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Image.network(
                          'https://tile.openstreetmap.org/6/37/31.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
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
                  description: _conditions == null
                      ? 'Loading live weather conditions...'
                      : '${_conditions!.temperature.round()}°C • Humidity ${_conditions!.humidity}% • Precipitation: ${_conditions!.precipitationLabel}',
                  accent: DashAccent.amber,
                  onTap: () => _loadLiveData(),
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
                  badgeLabel: _unreadAlerts == 0 ? null : '$_unreadAlerts New',
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
