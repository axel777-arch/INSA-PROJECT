import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AdvisoryApprovalScreen extends StatefulWidget {
  /// Id of the bulletin to review. Defaults to the seeded demo advisory so
  /// the screen still renders when reached without arguments (e.g. via the
  /// named route from the router).
  final String contentId;

  const AdvisoryApprovalScreen({super.key, this.contentId = 'adv-1'});

  @override
  State<AdvisoryApprovalScreen> createState() => _AdvisoryApprovalScreenState();
}

class _AdvisoryApprovalScreenState extends State<AdvisoryApprovalScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());

  ContentModel? _content;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final content = await _contentService.getAdvisoryById(widget.contentId);
    if (!mounted) return;
    setState(() {
      _content = content;
      _isLoading = false;
    });
  }

  Future<void> _handleDecision({required bool approve}) async {
    if (_content == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    final success = approve
        ? await _contentService.approveAdvisory(_content!.id)
        : await _contentService.rejectAdvisory(_content!.id, 'Rejected by reviewing expert');

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Advisory Approved & Published!' : 'Advisory Rejected.'),
          backgroundColor: approve ? AppColors.success : AppColors.error,
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update this advisory. Please try again.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
        appBar: AppBar(title: const Text('Review Advisory')),
        body: const Center(child: CircularProgressIndicator()),
      ));
    }

    final content = _content;
    if (content == null) {
      return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
        appBar: AppBar(title: const Text('Review Advisory')),
        body: const Center(child: Text('This advisory could not be found.')),
      ));
    }

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
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
                      content.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Wrap(
                      spacing: AppSizes.p8,
                      children: [
                        Chip(label: Text('Crop: ${content.cropId}')),
                        Chip(label: Text('Language: ${content.language}')),
                        Chip(label: Text('Status: ${content.status}')),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Author: ${content.createdBy} • Submitted for final broadcast approval.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const Divider(height: AppSizes.p32),

                    Text(
                      'Abstract & Guidelines',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(content.body),
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
                      isLoading: _isProcessing,
                      onPressed: _isProcessing ? null : () => _handleDecision(approve: false),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: AppButton(
                      label: 'Approve',
                      icon: Icons.check_rounded,
                      isLoading: _isProcessing,
                      onPressed: _isProcessing ? null : () => _handleDecision(approve: true),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}

