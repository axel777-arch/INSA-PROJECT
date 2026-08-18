import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

class ContentDetailScreen extends StatelessWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bulletin Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wheat Rust Pest Prevention Guidelines',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Row(
              children: [
                Chip(
                  label: const Text('Wheat'),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                ),
                const SizedBox(width: AppSizes.p8),
                const Text('Published: Just now'),
              ],
            ),
            const Divider(height: AppSizes.p32),
            Text(
              'Detailed agricultural instructions will render here. Fungal rust control recommendation includes treating wheat crops early in the morning and monitoring moisture levels consistently...',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
