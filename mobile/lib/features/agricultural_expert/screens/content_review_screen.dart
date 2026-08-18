import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class ContentReviewScreen extends StatelessWidget {
  const ContentReviewScreen({super.key});

  static const List<Map<String, String>> _queue = [
    {
      'id': '1',
      'title': 'Maize Stalk Borer Outbreak',
      'crop': 'Maize',
      'region': 'Amhara',
      'status': 'IN_REVIEW',
    },
    {
      'id': '2',
      'title': 'Irrigation Control Guidelines',
      'crop': 'Vegetables',
      'region': 'Tigray',
      'status': 'IN_REVIEW',
    },
    {
      'id': '3',
      'title': 'Teff Rust Prevention',
      'crop': 'Teff',
      'region': 'Oromia',
      'status': 'IN_REVIEW',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Content Review Queue')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _queue.length,
        itemBuilder: (context, index) {
          final item = _queue[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              leading: const Icon(Icons.rate_review_outlined, color: AppColors.warning),
              title: Text(item['title']!),
              subtitle: Text('Crop: ${item['crop']} | Region: ${item['region']}'),
              trailing: AppButton(
                label: 'Review',
                isFullWidth: false,
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/expert/content-review-details',
                  arguments: item['id'],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
