import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/change_password_dialog.dart';
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _nameController = TextEditingController(text: 'Agri-Insight Beacon');
  final _supportEmailController = TextEditingController(text: 'support@agri-insight.et');
  String _selectedLanguage = 'en';

  bool _smsBroadcastEnabled = true;
  bool _maintenanceMode = false;
  double _autoEscalationHours = 24;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('platform_name') ?? 'Agri-Insight Beacon';
      _supportEmailController.text = prefs.getString('support_email') ?? 'support@agri-insight.et';
      _smsBroadcastEnabled = prefs.getBool('sms_broadcast_enabled') ?? true;
      _maintenanceMode = prefs.getBool('maintenance_mode') ?? false;
      _autoEscalationHours = prefs.getDouble('auto_escalation_hours') ?? 24.0;
      _selectedLanguage = AppLocale.instance.currentLanguage;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _supportEmailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('platform_name', _nameController.text.trim());
    await prefs.setString('support_email', _supportEmailController.text.trim());
    await prefs.setBool('sms_broadcast_enabled', _smsBroadcastEnabled);
    await prefs.setBool('maintenance_mode', _maintenanceMode);
    await prefs.setDouble('auto_escalation_hours', _autoEscalationHours);

    await AppLocale.instance.setLanguage(_selectedLanguage);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully to storage!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const ScreenBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Admin Settings')),
        body: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            // General Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'General Configuration',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    AppTextField(
                      label: 'Platform Instance Name',
                      controller: _nameController,
                      prefixIcon: Icons.dns_outlined,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Default Language',
                        prefixIcon: Icon(Icons.language_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'am', child: Text('Amharic (አማርኛ)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                          AppLocale.instance.setLanguage(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Security & Password Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Security & Credentials',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_reset_rounded, color: Colors.blueGrey),
                      title: const Text('Change Password'),
                      subtitle: const Text('Update administrator account credentials via backend.'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => ChangePasswordDialog.show(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Support & Contacts Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Support & Contacts',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: AppSizes.p24),
                    AppTextField(
                      label: 'Support Escalation Email Address',
                      controller: _supportEmailController,
                      prefixIcon: Icons.contact_support_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Platform Behavior Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Platform Behavior',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: AppSizes.p24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('SMS Broadcast Alerts'),
                      subtitle: const Text('Send advisory broadcasts to farmers over SMS.'),
                      value: _smsBroadcastEnabled,
                      onChanged: (val) => setState(() => _smsBroadcastEnabled = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Maintenance Mode'),
                      subtitle: const Text('Temporarily block new sign-ins for all roles.'),
                      value: _maintenanceMode,
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Auto-Escalation Threshold: ${_autoEscalationHours.round()}h',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Slider(
                      value: _autoEscalationHours,
                      min: 1,
                      max: 72,
                      divisions: 71,
                      label: '${_autoEscalationHours.round()}h',
                      onChanged: (val) => setState(() => _autoEscalationHours = val),
                    ),
                    Text(
                      'Unresolved field cases auto-escalate to an agronomy expert after this period.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            AppButton(
              label: 'Save Configuration',
              onPressed: _saveChanges,
            ),
            const SizedBox(height: AppSizes.p12),

            AppButton.destructive(
              label: 'Logout from System',
              onPressed: () => LogoutConfirmationDialog.show(context),
            ),
          ],
        ),
      ),
    );
  }
}
