import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/user_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/farmer_service.dart';
import 'extension_alerts_screen.dart';

class ExtensionProfileScreen extends StatefulWidget {
  const ExtensionProfileScreen({super.key});

  @override
  State<ExtensionProfileScreen> createState() => _ExtensionProfileScreenState();
}

class _ExtensionProfileScreenState extends State<ExtensionProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());
  UserModel? _user;
  List<Map<String, dynamic>> _observations = [];
  int _farmsVisited = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await AuthService(apiClient: _apiClient).getMe();
      final farmers = await _farmerService.getFarmers();
      final response = await _apiClient.get('/field/observations');
      if (!mounted) return;
      setState(() {
        _user = user;
        _farmsVisited = farmers.length;
        _observations = (response as List<dynamic>).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedAlerts = ExtensionAlertsStore.alerts.where((item) => item['unread'] == false).length;
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('My Profile')),
        body: RefreshIndicator(
          onRefresh: _loadProfile,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.p16),
            children: [
              Card(child: Padding(padding: const EdgeInsets.all(AppSizes.p16), child: Column(children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.engineering_outlined, size: 40)),
                const SizedBox(height: AppSizes.p12),
                Text(_user?.fullName ?? 'Extension Worker', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(_user?.role ?? 'EXTENSION_WORKER'),
                Chip(label: const Text('Approved'), backgroundColor: AppColors.success.withValues(alpha: 0.1)),
              ]))),
              const SizedBox(height: AppSizes.p16),
              _sectionCard('Account Details', [_detailRow('Phone', _user?.phone ?? '-'), _detailRow('Email', _user?.email ?? '-'), _detailRow('User ID', _user?.id ?? '-')]),
              const SizedBox(height: AppSizes.p16),
              _sectionCard('Activity', [_isLoading ? const Center(child: CircularProgressIndicator()) : Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_metric('$_farmsVisited', 'Farmers', theme.primaryColor), _metric('${_observations.length}', 'Observations', theme.colorScheme.tertiary), _metric('$resolvedAlerts', 'Alerts Resolved', theme.colorScheme.secondary)])]),
              const SizedBox(height: AppSizes.p16),
              _sectionCard('Field Observations', _observations.isEmpty ? [const Text('No field observations submitted yet.')] : _observations.take(5).map((item) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.assignment_outlined), title: Text('${item['category']} - ${item['crop']}'), subtitle: Text('${item['location']}\n${item['notes']}'), isThreeLine: true)).toList()),
              const SizedBox(height: AppSizes.p16),
              _sectionCard('Account Settings', [ListTile(title: Text('Language: ${_user?.preferredLanguage ?? 'en'}'))]),
              const SizedBox(height: AppSizes.p24),
              AppButton.destructive(label: 'Logout', onPressed: () async { await AuthService(apiClient: _apiClient).logout(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) => Card(child: Padding(padding: const EdgeInsets.all(AppSizes.p16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Divider(height: AppSizes.p24), ...children])));

  Widget _detailRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: AppSizes.p8), child: Row(children: [SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)))]));

  Widget _metric(String value, String label, Color color) => Column(children: [Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(color: Colors.grey))]);
}