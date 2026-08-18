import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class ExpertHomeScreen extends StatefulWidget {
  const ExpertHomeScreen({super.key});

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> {
  final List<Map<String, dynamic>> _mockDrafts = [
    {
      'id': '1',
      'title': 'Maize Stalk Borer Outbreak',
      'crop': 'Maize',
      'region': 'Amhara',
      'body': 'Early symptoms of stalk borer infestation detected. Recommend application of organic neem oil extract or chemical treatments in designated zones...',
      'author': 'Extension Worker: Abebe',
    },
    {
      'id': '2',
      'title': 'Irrigation Control guidelines',
      'crop': 'Vegetables',
      'region': 'Tigray',
      'body': 'Dry season warning. Reduce surface water evaporation by applying crop mulching techniques and adjusting drip irrigation cycles to evening hours...',
      'author': 'Extension Worker: Almaz',
    }
  ];

  void _reviewContent(String id, bool approved) {
    setState(() {
      _mockDrafts.removeWhere((item) => item['id'] == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approved ? 'Advisory Approved & Published!' : 'Advisory Rejected.'),
        backgroundColor: approved ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Panel'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              MyApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Content Review Queue',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              'Validate agricultural advisory drafts submitted by field extension workers.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.p16),
            Expanded(
              child: _mockDrafts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 64,
                            color: theme.primaryColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSizes.p12),
                          const Text(
                            'All Clean! No Pending Reviews.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _mockDrafts.length,
                      itemBuilder: (context, index) {
                        final draft = _mockDrafts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.p16),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      draft['title'],
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(draft['crop']),
                                      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                      labelStyle: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.p4),
                                Text(
                                  'Submitted by: ${draft['author']} | Target: ${draft['region']}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const Divider(height: AppSizes.p24),
                                Text(
                                  draft['body'],
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSizes.p16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton.destructive(
                                        label: 'Reject',
                                        icon: Icons.close_rounded,
                                        onPressed: () => _reviewContent(draft['id'], false),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.p12),
                                    Expanded(
                                      child: AppButton(
                                        label: 'Approve',
                                        icon: Icons.check_rounded,
                                        onPressed: () => _reviewContent(draft['id'], true),
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
