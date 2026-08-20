import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ContentDetailScreen extends StatelessWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(
        title: const Text('Article Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image Placeholder
            Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 180,
                color: theme.primaryColor.withValues(alpha: 0.1),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 48, color: theme.primaryColor),
                    const SizedBox(height: 8),
                    const Text('Optimizing Winter Wheat Yields Banner', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            Text(
              'Optimizing Winter Wheat Yields',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: AppSizes.p12),

            // Author Badge
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: AppSizes.p12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. Sarah Jenkins',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Senior Agronomist • Mid-West Region',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            AppButton(
              label: 'Share Insight',
              icon: Icons.share_rounded,
              onPressed: () {},
            ),
            const Divider(height: AppSizes.p32),

            // Article body
            const Text(
              'As we approach the critical tillering phase for winter wheat across the central plains, environmental data suggests a heightened need for precise nitrogen application. Recent fluctuations in soil moisture, driven by unseasonal precipitation, have created localized zones of nutrient leaching that require immediate attention.',
            ),
            const SizedBox(height: AppSizes.p20),

            // Key Observations
            Text(
              'Key Observations',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            _buildObservationRow(
              'Soil Temperature',
              'Consistently hovering around 45°F (7°C), ideal for root development but slow for nutrient mineralization.',
            ),
            _buildObservationRow(
              'Moisture Levels',
              'Saturated in low-lying areas, causing potential anaerobic conditions near the root zone.',
            ),
            const SizedBox(height: AppSizes.p20),

            // Expert Recommendation Card
            Card(
              color: theme.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_outlined, color: theme.primaryColor),
                        const SizedBox(width: AppSizes.p8),
                        Text(
                          'Expert Recommendation',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: AppSizes.p16),
                    const Text(
                      'Implement a split nitrogen application strategy. Apply 40% of the total projected N requirement immediately to support tillering, reserving the remaining 60% for the jointing stage when crop uptake is maximized.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p20),

            // Related Resources
            Text(
              'Related Resources',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.error),
                title: const Text('Soil Sampling Best Practices'),
                subtitle: const Text('PDF Guide • 2.4 MB'),
                trailing: const Icon(Icons.download_rounded),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.map_outlined, color: Colors.blue),
                title: const Text('Regional Weather Forecast'),
                subtitle: const Text('Interactive Map'),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildObservationRow(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
