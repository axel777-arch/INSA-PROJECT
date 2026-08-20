import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class FarmerManagementScreen extends StatefulWidget {
  const FarmerManagementScreen({super.key});

  @override
  State<FarmerManagementScreen> createState() => _FarmerManagementScreenState();
}

class _FarmerManagementScreenState extends State<FarmerManagementScreen> {
  final List<Map<String, dynamic>> _farmers = [
    {
      'id': '1',
      'name': 'Elias Thorne',
      'crop': 'Wheat',
      'location': 'Midwest Valley',
      'active': true,
    },
    {
      'id': '2',
      'name': 'Sarah Jenkins',
      'crop': 'Corn',
      'location': 'Northern Plains',
      'active': true,
    },
    {
      'id': '3',
      'name': 'Marcus Reyes',
      'crop': 'Soybeans',
      'location': 'Southern Delta',
      'active': false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Management')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            // Search Input
            const AppTextField(
              label: 'Search farmers...',
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: AppSizes.p12),

            // Filter chips row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Crop'),
                    items: ['All', 'Wheat', 'Corn', 'Soybeans'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Region'),
                    items: ['All', 'Valley', 'Plains', 'Delta'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            // List of Farmers
            Expanded(
              child: ListView.builder(
                itemCount: _farmers.length,
                itemBuilder: (context, index) {
                  final farmer = _farmers[index];
                  final isActive = farmer['active'] as bool;
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.p12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                farmer['name']!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive 
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: isActive ? AppColors.success : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Crop: ${farmer['crop']}'),
                          Text('Location: ${farmer['location']}'),
                          const Divider(height: AppSizes.p24),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton.outlined(
                                  label: 'View',
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: AppSizes.p12),
                              Expanded(
                                child: AppButton(
                                  label: 'Edit',
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
