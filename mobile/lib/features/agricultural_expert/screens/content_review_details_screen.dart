import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ContentReviewDetailsScreen extends StatefulWidget {
  final String contentId;

  const ContentReviewDetailsScreen({super.key, required this.contentId});

  @override
  State<ContentReviewDetailsScreen> createState() => _ContentReviewDetailsScreenState();
}

class _ContentReviewDetailsScreenState extends State<ContentReviewDetailsScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitDecision(bool approved) {
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? 'Content approved and published!' : 'Content rejected.'),
          backgroundColor: approved ? AppColors.success : AppColors.error,
        ),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('Review Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maize Stalk Borer Outbreak',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Row(
                    children: [
                      Chip(
                        label: const Text('Maize'),
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      const Text('Region: Amhara'),
                    ],
                  ),
                  const Divider(height: AppSizes.p24),
                  Text(
                    'Early symptoms of stalk borer infestation detected. Recommend application of organic neem oil extract or chemical treatments in designated zones. Monitor weekly and report back to extension worker.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    'Submitted by: Extension Worker Abebe',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          AppTextField(
            label: 'Review Comment (optional)',
            controller: _commentController,
            prefixIcon: Icons.comment_outlined,
          ),
          const SizedBox(height: AppSizes.p24),
          Row(
            children: [
              Expanded(
                child: AppButton.destructive(
                  label: 'Reject',
                  icon: Icons.close_rounded,
                  isLoading: _isSubmitting,
                  onPressed: () => _submitDecision(false),
                ),
              ),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: AppButton(
                  label: 'Approve',
                  icon: Icons.check_rounded,
                  isLoading: _isSubmitting,
                  onPressed: () => _submitDecision(true),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
