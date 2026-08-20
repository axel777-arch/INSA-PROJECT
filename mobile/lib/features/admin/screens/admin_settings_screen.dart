import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _nameController = TextEditingController(text: 'Agri-Insight Beacon');
  final _supportEmailController = TextEditingController(text: 'support@agri-insight.com');
  String _selectedLanguage = 'English';

  @override
  void dispose() {
    _nameController.dispose();
    _supportEmailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
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
