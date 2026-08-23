import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final AdminService _adminService = AdminService(apiClient: ApiClient());
  final _nameController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _alertController = TextEditingController();
  String _selectedLanguage = 'English';
  String _alertLocation = 'National';
  bool _loading = true;
  bool _saving = false;

  late bool _smsBroadcastEnabled;
  late bool _maintenanceMode;
  late double _autoEscalationHours;

  @override
  void initState() {
    super.initState();
    _smsBroadcastEnabled = true;
    _maintenanceMode = false;
    _autoEscalationHours = 24;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _adminService.getSettings();
      if (!mounted) return;
      setState(() {
        _nameController.text = settings['instanceName'] as String? ?? '';
        _supportEmailController.text =
            settings['supportEmail'] as String? ?? '';
        _selectedLanguage = settings['defaultLanguage'] as String? ?? 'English';
        _smsBroadcastEnabled = settings['smsBroadcastEnabled'] as bool? ?? true;
        _maintenanceMode = settings['maintenanceMode'] as bool? ?? false;
        _autoEscalationHours =
            (settings['autoEscalationHours'] as num?)?.toDouble() ?? 24;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      if (mounted) _showMessage('Could not load admin settings.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _supportEmailController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _adminService.updateSettings({
        'instanceName': _nameController.text,
        'defaultLanguage': _selectedLanguage,
        'supportEmail': _supportEmailController.text,
        'smsBroadcastEnabled': _smsBroadcastEnabled,
        'maintenanceMode': _maintenanceMode,
        'autoEscalationHours': _autoEscalationHours,
      });
      if (mounted) _showMessage('Settings saved successfully!');
    } catch (_) {
      if (mounted) _showMessage('Could not save admin settings.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendAlert() async {
    final body = _alertController.text.trim();
    if (body.isEmpty) {
      _showMessage('Enter an alert message first.');
      return;
    }
    try {
      final result = await _adminService.broadcastAlert(
        body: body,
        location: _alertLocation == 'National' ? null : _alertLocation,
      );
      _alertController.clear();
      if (mounted) _showMessage('Alert sent to ${result['recipientCount'] ?? 0} farmers.');
    } catch (error) {
      if (mounted) _showMessage('Could not send alert: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text('Admin Settings')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSizes.p16),
                children: [
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
                            items:
                                [
                                  'English',
                                  'Amharic',
                                  'Afaan Oromoo',
                                  'Tigrinya',
                                ].map((l) {
                                  return DropdownMenuItem(
                                    value: l,
                                    child: Text(l),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedLanguage = val);
                              }
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
                          Text('Send Farmer Alert', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Divider(height: AppSizes.p24),
                          AppTextField(label: 'Alert message', controller: _alertController, prefixIcon: Icons.warning_amber_rounded),
                          const SizedBox(height: AppSizes.p12),
                          DropdownButtonFormField<String>(
                            initialValue: _alertLocation,
                            decoration: const InputDecoration(labelText: 'Audience location'),
                            items: const ['National', 'Oromia', 'Amhara', 'SNNPR', 'Tigray'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _alertLocation = value);
                              }
                            },
                          ),
                          const SizedBox(height: AppSizes.p12),
                          AppButton(label: 'Send Alert', icon: Icons.send_rounded, onPressed: _sendAlert),
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
                            'Support & Contacts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Platform Behavior',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: AppSizes.p24),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('SMS Broadcast Alerts'),
                            subtitle: const Text(
                              'Send advisory broadcasts to farmers over SMS.',
                            ),
                            value: _smsBroadcastEnabled,
                            onChanged: (val) =>
                                setState(() => _smsBroadcastEnabled = val),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Maintenance Mode'),
                            subtitle: const Text(
                              'Temporarily block new sign-ins for all roles.',
                            ),
                            value: _maintenanceMode,
                            onChanged: (val) =>
                                setState(() => _maintenanceMode = val),
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
                            onChanged: (val) =>
                                setState(() => _autoEscalationHours = val),
                          ),
                          Text(
                            'Unresolved field cases auto-escalate to a senior expert after this many hours.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),

                  AppButton(
                    label: 'Save Configuration',
                    icon: Icons.save_outlined,
                    onPressed: _saving ? null : _saveChanges,
                  ),
                  const SizedBox(height: AppSizes.p12),

                  AppButton.destructive(
                    label: 'Logout from System',
                    onPressed: () async {
                      await AuthService(apiClient: ApiClient()).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
