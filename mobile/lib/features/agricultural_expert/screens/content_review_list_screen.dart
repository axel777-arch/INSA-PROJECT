import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_text_field.dart';

class ContentReviewListScreen extends StatelessWidget {
  const ContentReviewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, String>> items = [
      {
        'title': 'Optimizing Nitrogen Application for Winter Wheat Yields',
        'crop': 'Wheat',
        'date': 'Oct 24, 2023',
        'author': 'Dr. Robert Chen',
      },
      {
        'title': 'Early Detection of Sudden Death Syndrome in Soybean Crops',
        'crop': 'Soybeans',
        'date': 'Oct 23, 2023',
        'author': 'Amanda Martinez, Agronomist',
      },
      {
        'title': 'Assessing Drought Tolerance in New Corn Hybrids',
        'crop': 'Corn',
        'date': 'Oct 20, 2023',
        'author': 'Sarah Williams, PhD',
      },
      {
        'title': 'Integrating Cover Crops for Soil Health Improvement',
        'crop': 'General',
        'date': 'Oct 18, 2023',
        'author': 'Tom Kovac',
      }
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Review'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Review'),
              Tab(text: 'Drafts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Review Tab
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                children: [
                  const AppTextField(
                    label: 'Search title, author, or crop...',
                    prefixIcon: Icons.search_rounded,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
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
                                    Chip(
                                      label: Text(item['crop']!),
                                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                    ),
                                    Text(item['date']!, style: theme.textTheme.bodySmall),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.p8),
                                Text(
                                  item['title']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: AppSizes.p4),
                                Text('Submitted by: ${item['author']}', style: theme.textTheme.bodySmall),
                                const Divider(height: AppSizes.p24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.arrow_forward_rounded),
                                    label: const Text('View Details'),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/expert/review/detail');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            // Drafts Tab
            const Center(child: Text('No drafts available.')),
          ],
        ),
      ),
    );
  }
}
