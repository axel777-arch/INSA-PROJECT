import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/crop_model.dart';
import '../../../../services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  bool _alertsEnabled = true;
  final List<String> _crops = [];
  final ApiClient _apiClient = ApiClient();
  String? _farmerId;

  @override
  void initState() {
    super.initState();
    _loadRegisteredCrops();
  }

  Future<void> _loadRegisteredCrops() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final userJson = preferences.getString('user');
      if (userJson == null) return;
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      final farmer =
          await _apiClient.get('/farmers/user/${user['id']}')
              as Map<String, dynamic>;
      _farmerId = farmer['id'] as String?;
      final assigned =
          await _apiClient.get('/farmers/$_farmerId/crops') as List<dynamic>;
      if (mounted)
        setState(
          () => _crops
            ..clear()
            ..addAll(
              assigned.map(
                (item) => (item['cropName'] as String).toLowerCase(),
              ),
            ),
        );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text('My Profile')),
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
                      'David',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: const Text('Registered Farmer'),
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
                      'Farm Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    _buildDetailRow('Phone', '+254 712 345 678'),
                    _buildDetailRow('Region', 'Nairobi'),
                    _buildDetailRow('Zone', 'Central'),
                    _buildDetailRow('Woreda', 'Westlands'),
                    _buildDetailRow('Kebele', 'Kitisuru'),
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
                      'Registered Crops',
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
                          label: const Text('+ Add Crop'),
                          onPressed: () {
                            final controller = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Add Registered Crop'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Crop Name',
                                    hintText: 'e.g., Coffee, Teff, Potato',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final text = controller.text.trim();
                                      _registerCrop(text, controller);
                                    },
                                    child: const Text('Add'),
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
                      'Settings & Preferences',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: AppSizes.p24),
                    SwitchListTile(
                      title: const Text('Enable Alerts'),
                      subtitle: const Text('Receive SMS warnings'),
                      value: _alertsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _alertsEnabled = val;
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Change Language'),
                      subtitle: const Text('Currently English'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, '/choose-language');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            AppButton.destructive(
              label: 'Logout',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
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
        const SnackBar(content: Text('This crop is already registered.')),
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
      if (crop == null || _farmerId == null)
        throw Exception('Crop is not available in the backend.');
      await _apiClient.post('/farmers/$_farmerId/crops', {'cropId': crop.id});
      if (mounted) {
        setState(() => _crops.add(name));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name registered successfully.')),
        );
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
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
