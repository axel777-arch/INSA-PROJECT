import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/config/user_session.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';

import 'package:mobile/core/localization/app_localizations.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  bool _alertsEnabled = true;
  final List<String> _crops = [];
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService(apiClient: ApiClient());
  String? _farmerId;
  String _displayName = 'Farmer';
  String _phone = '';
  String _region = '';
  String _zone = '';
  String _woreda = '';
  String _kebele = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await UserSession.get();
    if (!mounted || user == null) return;
    setState(() {
      _displayName = user.fullName;
      _phone = user.phone;
    });
    // Load farmer-specific details
    try {
      final farmer =
          await _apiClient.get('/farmers/user/${user.id}')
              as Map<String, dynamic>?;
      if (farmer == null || !mounted) return;
      _farmerId = farmer['id'] as String?;
      setState(() {
        _region = farmer['region'] as String? ?? '';
        _zone = farmer['zone'] as String? ?? '';
        _woreda = farmer['woreda'] as String? ?? '';
        _kebele = farmer['kebele'] as String? ?? '';
        _alertsEnabled = farmer['alert_enabled'] as bool? ?? true;
      });
      final assigned =
          await _apiClient.get('/farmers/$_farmerId/crops') as List<dynamic>?;
      if (assigned != null && mounted) {
        setState(() {
          _crops.clear();
          _crops.addAll(
            assigned.map((item) => (item['cropName'] as String).toLowerCase()),
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(appText('My Profile'))),
        body: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            // Profile Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Text(
                      _displayName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(appText('Registered Farmer')),
                      backgroundColor: theme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      labelStyle: TextStyle(color: theme.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Farm Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appText('Farm Details'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    _buildDetailRow('Phone', _phone.isNotEmpty ? _phone : '—'),
                    _buildDetailRow(
                      'Region',
                      _region.isNotEmpty ? _region : '—',
                    ),
                    _buildDetailRow('Zone', _zone.isNotEmpty ? _zone : '—'),
                    _buildDetailRow(
                      'Woreda',
                      _woreda.isNotEmpty ? _woreda : '—',
                    ),
                    _buildDetailRow(
                      'Kebele',
                      _kebele.isNotEmpty ? _kebele : '—',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Registered Crops Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appText('Registered Crops'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    Wrap(
                      spacing: AppSizes.p8,
                      runSpacing: AppSizes.p8,
                      children: [
                        ..._crops.map(
                          (crop) => Chip(
                            label: Text(crop),
                            backgroundColor: theme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        ActionChip(
                          label: Text(appText('+ Add Crop')),
                          onPressed: () {
                            final controller = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(appText('Add Registered Crop')),
                                content: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: appText('Crop Name'),
                                    hintText: appText(
                                      'e.g., Coffee, Teff, Potato',
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(appText('Cancel')),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final text = controller.text.trim();
                                      _registerCrop(text, controller);
                                    },
                                    child: Text(appText('Add')),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Settings & Preferences Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appText('Settings & Preferences'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    SwitchListTile(
                      title: Text(appText('Enable Alerts')),
                      subtitle: Text(
                        appText('Receive SMS warnings and urgent bulletins'),
                      ),
                      value: _alertsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _alertsEnabled = val;
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.translate_rounded),
                      title: Text(appText('Change Language')),
                      subtitle: Text(
                        'Currently: ${LocaleProvider.instance.currentLanguage.englishName} (${LocaleProvider.instance.currentLanguage.nativeName})',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/choose-language',
                        ).then((_) => setState(() {}));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.accessibility_new_rounded),
                      title: Text(appText('Accessibility & Voice')),
                      subtitle: Text(
                        appText(
                          'High contrast, large buttons & audio readouts',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, '/farmer/accessibility');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.offline_pin_rounded),
                      title: Text(appText('Offline Saved Advisories')),
                      subtitle: Text(
                        appText('View and manage cached advisory bulletins'),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/farmer/offline-advisories',
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.support_agent_rounded),
                      title: Text(appText('My Questions & Inquiries')),
                      subtitle: Text(
                        appText('Track extension worker case responses'),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, '/farmer/cases');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            AppButton.destructive(label: appText('Logout'), onPressed: _logout),
          ],
        ),
      ),
    );
  }

  Future<void> _registerCrop(
    String value,
    TextEditingController controller,
  ) async {
    final name = value.trim().toLowerCase();
    if (name.isEmpty) return;
    if (_crops.any((crop) => crop.toLowerCase() == name)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appText('This crop is already registered.'))),
      );
      return;
    }
    try {
      final response = await _apiClient.get('/crops') as Map<String, dynamic>;
      final crops = (response['data'] as List<dynamic>).map(
        (item) => CropModel.fromJson(item as Map<String, dynamic>),
      );
      final crop = crops
          .where((item) => item.name.toLowerCase() == name)
          .firstOrNull;
      if (crop == null || _farmerId == null) {
        throw Exception('Crop is not available in the backend.');
      }
      await _apiClient.post('/farmers/$_farmerId/crops', {'cropId': crop.id});
      if (mounted) {
        setState(() => _crops.add(name));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name registered successfully.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
