import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class AdvisoryApprovalScreen extends StatelessWidget {
  const AdvisoryApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Review Advisory')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Optimal Irrigation Scheduling for Winter Wheat under Drought Stress',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Wrap(
                      spacing: AppSizes.p8,
                      children: const [
                        Chip(label: Text('Crop: Winter Wheat')),
                        Chip(label: Text('Language: English')),
                        Chip(label: Text('Region: Arid Southwest')),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Author: Dr. Elena Rostova • Submitted for final broadcast approval.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const Divider(height: AppSizes.p32),
                    
                    Text(
                      'Abstract & Guidelines',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    const Text(
                      'Recent meteorological data indicates a sustained 60-day dry spell across the southwestern quadrants. Traditional calendar-based irrigation will result in critical yield losses during the booting and anthesis stages of winter wheat.',
                    ),
                    const SizedBox(height: AppSizes.p16),

                    Card(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                            const SizedBox(width: AppSizes.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Key Directive',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'If soil moisture tension at a 30cm depth exceeds 80 kPa, an emergency application of 25mm irrigation is required within 48 hours to prevent irreversible floret abortion.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    
                    // Moisture chart placeholder card
                    Card(
                      child: Container(
                        height: 150,
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 48, color: theme.primaryColor),
                            const SizedBox(height: AppSizes.p8),
                            const Text('Moisture Trends Diagram (Chart Asset)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // Bottom Action buttons
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.destructive(
                      label: 'Reject',
                      icon: Icons.close_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Advisory Rejected.'), backgroundColor: AppColors.error),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: AppButton(
                      label: 'Approve',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Advisory Approved & Published!'), backgroundColor: AppColors.success),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
