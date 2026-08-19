import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

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
  final _nameController = TextEditingController(text: 'Agri-Insight Beacon');
  final _supportEmailController = TextEditingController(text: 'support@agri-insight.com');
  String _selectedLanguage = 'English';

  late bool _smsBroadcastEnabled;
  late bool _maintenanceMode;
  late double _autoEscalationHours;

  @override
  void initState() {
    super.initState();
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
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
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
                    'General Configuration',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
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
                    items: ['English', 'Amharic', 'Afaan Oromoo', 'Tigrinya'].map((l) {
                      return DropdownMenuItem(value: l, child: Text(l));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
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
            onPressed: _saveChanges,
          ),
          const SizedBox(height: AppSizes.p12),

          AppButton.destructive(
            label: 'Logout from System',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
