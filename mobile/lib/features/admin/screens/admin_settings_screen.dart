import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';

/// Mock persisted admin settings. Static so values survive navigating away
/// from and back to the settings screen, standing in for a real settings
/// endpoint/local storage layer.
class _MockSettingsStore {
  static bool smsBroadcastEnabled = true;
  static bool maintenanceMode = false;
  static double autoEscalationHours = 24;
}

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final AuthService _authService = AuthService(apiClient: ApiClient());
  final _nameController = TextEditingController(text: 'Agri-Insight Beacon');
  final _supportEmailController = TextEditingController(
    text: 'support@agri-insight.com',
  );
  late String _selectedLanguage;

  late bool _smsBroadcastEnabled;
  late bool _maintenanceMode;
  late double _autoEscalationHours;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = switch (LocaleProvider.instance.currentLanguage) {
      AppLanguage.english => 'English',
      AppLanguage.amharic => 'Amharic',
      AppLanguage.oromo => 'Afaan Oromoo',
    };
    // Hydrate local widget state from the mock storage state.
    _smsBroadcastEnabled = _MockSettingsStore.smsBroadcastEnabled;
    _maintenanceMode = _MockSettingsStore.maintenanceMode;
    _autoEscalationHours = _MockSettingsStore.autoEscalationHours;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _supportEmailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Persist toggles/slider back into the mock storage state.
    _MockSettingsStore.smsBroadcastEnabled = _smsBroadcastEnabled;
    _MockSettingsStore.maintenanceMode = _maintenanceMode;
    _MockSettingsStore.autoEscalationHours = _autoEscalationHours;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.current.settingsSaved)),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(loc.adminSettings)),
        body: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.generalConfiguration,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    AppTextField(
                      label: loc.platformInstanceName,
                      controller: _nameController,
                      prefixIcon: Icons.dns_outlined,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
                      decoration: InputDecoration(
                        labelText: loc.defaultLanguage,
                        prefixIcon: Icon(Icons.language_rounded),
                      ),
                      items: ['English', 'Amharic', 'Afaan Oromoo'].map((l) {
                        return DropdownMenuItem(value: l, child: Text(l));
                      }).toList(),
                      onChanged: (val) async {
                        if (val == null) return;
                        final language = switch (val) {
                          'Amharic' => AppLanguage.amharic,
                          'Afaan Oromoo' => AppLanguage.oromo,
                          _ => AppLanguage.english,
                        };
                        await LocaleProvider.instance.setLanguage(language);
                        if (mounted) setState(() => _selectedLanguage = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.supportContacts,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    AppTextField(
                      label: loc.supportEscalationEmail,
                      controller: _supportEmailController,
                      prefixIcon: Icons.contact_support_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.platformBehavior,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.smsBroadcastAlerts),
                      subtitle: Text(loc.smsBroadcastDescription),
                      value: _smsBroadcastEnabled,
                      onChanged: (val) =>
                          setState(() => _smsBroadcastEnabled = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.maintenanceMode),
                      subtitle: Text(loc.maintenanceDescription),
                      value: _maintenanceMode,
                      onChanged: (val) =>
                          setState(() => _maintenanceMode = val),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      '${loc.autoEscalationThreshold}: ${_autoEscalationHours.round()}h',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Slider(
                      value: _autoEscalationHours,
                      min: 1,
                      max: 72,
                      divisions: 71,
                      label: '${_autoEscalationHours.round()}h',
                      onChanged: (val) =>
                          setState(() => _autoEscalationHours = val),
                    ),
                    Text(
                      loc.autoEscalationDescription,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            AppButton(label: loc.saveConfiguration, onPressed: _saveChanges),
            const SizedBox(height: AppSizes.p12),

            AppButton.destructive(
              label: loc.logoutFromSystem,
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
