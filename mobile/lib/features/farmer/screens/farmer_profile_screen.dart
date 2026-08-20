import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  bool _alertsEnabled = true;
  final List<String> _crops = ['Wheat', 'Soybeans'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
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
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: AppSizes.p24),
                  Wrap(
                    spacing: AppSizes.p8,
                    runSpacing: AppSizes.p8,
                    children: [
                      ..._crops.map((crop) => Chip(
                        label: Text(crop),
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      )),
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
                                    if (text.isNotEmpty) {
                                      setState(() {
                                        if (!_crops.contains(text)) {
                                          _crops.add(text);
                                        }
                                      });
                                    }
                                    Navigator.pop(context);
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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
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
}
