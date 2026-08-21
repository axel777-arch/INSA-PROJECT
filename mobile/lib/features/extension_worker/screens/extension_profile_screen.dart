import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/mock_api_client.dart';
import '../../../../services/farmer_service.dart';
import 'extension_alerts_screen.dart';
import '../../../../core/widgets/screen_backdrop.dart';

/// Mock persisted profile fields, kept static so edits survive navigating
/// away from and back to this screen, standing in for a real profile
/// endpoint.
class _MockProfileStore {
  static String employeeId = 'EXT-2049-A';
  static String assignedRegion = 'Northern Agricultural Zone';
  static String language = 'English';
}

class ExtensionProfileScreen extends StatefulWidget {
  const ExtensionProfileScreen({super.key});

  @override
  State<ExtensionProfileScreen> createState() => _ExtensionProfileScreenState();
}

class _ExtensionProfileScreenState extends State<ExtensionProfileScreen> {
  final FarmerService _farmerService = FarmerService(apiClient: MockApiClient());
  int _farmsVisited = 0;
  bool _isLoading = true;

  late String _employeeId;
  late String _assignedRegion;
  late String _language;

  @override
  void initState() {
    super.initState();
    _employeeId = _MockProfileStore.employeeId;
    _assignedRegion = _MockProfileStore.assignedRegion;
    _language = _MockProfileStore.language;
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    final farmers = await _farmerService.getFarmers();
    if (!mounted) return;
    setState(() {
      _farmsVisited = farmers.length;
      _isLoading = false;
    });
  }

  Future<void> _editProfileInfo() async {
    final regionController = TextEditingController(text: _assignedRegion);
    final idController = TextEditingController(text: _employeeId);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Employee ID', controller: idController),
            const SizedBox(height: AppSizes.p12),
            AppTextField(label: 'Assigned Region', controller: regionController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved == true) {
      setState(() {
        _employeeId = idController.text.trim().isEmpty ? _employeeId : idController.text.trim();
        _assignedRegion = regionController.text.trim().isEmpty ? _assignedRegion : regionController.text.trim();
      });
      _MockProfileStore.employeeId = _employeeId;
      _MockProfileStore.assignedRegion = _assignedRegion;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile information updated.')),
      );
    }
  }

  Future<void> _changeLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('App Language'),
        children: ['English', 'Amharic', 'Afaan Oromoo', 'Tigrinya'].map((lang) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, lang),
            child: Text(lang),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      setState(() => _language = selected);
      _MockProfileStore.language = selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertsResolved = ExtensionAlertsStore.alerts.where((a) => a['unread'] == false).length;

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          // Header Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.engineering_outlined, size: 40),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Text(
                    'Jane Doe',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Senior Extension Worker'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Approved',
                          style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // Employee Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Details',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: AppSizes.p24),
                  _buildDetailRow('Employee ID', _employeeId),
                  _buildDetailRow('Assigned Region', _assignedRegion),
                  _buildDetailRow('Joined Date', 'October 12, 2018'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // Activity Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Metrics',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: AppSizes.p24),
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(AppSizes.p12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric('$_farmsVisited', 'Farms Visited', theme.primaryColor),
                            _buildMetric('$alertsResolved', 'Alerts Resolved', theme.colorScheme.secondary),
                          ],
                        )
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: AppSizes.p24),
                  ListTile(
                    title: const Text('Edit Profile Information'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _editProfileInfo,
                  ),
                  ListTile(
                    title: const Text('Security & Password'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Security settings are not available in this mock build yet.')),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('App Language'),
                    trailing: Text(_language),
                    onTap: _changeLanguage,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          AppButton.destructive(
            label: 'Logout',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          )
        ],
      ),
    ));
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

  Widget _buildMetric(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
