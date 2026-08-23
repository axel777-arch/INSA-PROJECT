import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AdvisoryApprovalScreen extends StatefulWidget {
  /// Id of the content item to review.
  final String contentId;

  const AdvisoryApprovalScreen({super.key, this.contentId = ''});

  @override
  State<AdvisoryApprovalScreen> createState() => _AdvisoryApprovalScreenState();
}

class _AdvisoryApprovalScreenState extends State<AdvisoryApprovalScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());

  ContentModel? _content;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    if (widget.contentId.isEmpty) {
      setState(() { _isLoading = false; _error = 'No content ID provided.'; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final content = await _contentService.getAdvisoryById(widget.contentId);
      if (!mounted) return;
      setState(() { _content = content; _isLoading = false; });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.message; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _handleApprove() async {
    if (_content == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _contentService.approveAdvisory(_content!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advisory Approved!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleReject() async {
    if (_content == null || _isProcessing) return;
    // Ask for rejection reason
    final commentController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Advisory'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection *',
            hintText: 'Provide a clear explanation...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (commentController.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isProcessing = true);
    try {
      await _contentService.rejectAdvisory(_content!.id, commentController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advisory Rejected.'), backgroundColor: AppColors.error),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return ScreenBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Review Advisory')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null || _content == null) {
      return ScreenBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Review Advisory')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppSizes.p12),
                Text(_error ?? 'This advisory could not be found.', textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.p16),
                ElevatedButton.icon(onPressed: _loadContent, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final content = _content!;
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Wrap(
                        spacing: AppSizes.p8,
                        children: [
                          Chip(label: Text('Lang: ${content.language.toUpperCase()}')),
                          Chip(label: Text('Status: ${content.statusLabel}')),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        'Submitted for expert review.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Divider(height: AppSizes.p32),
                      Text('Content', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSizes.p8),
                      Text(content.body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
                    ],
                  ),
                ),
              ),
              // Action buttons — only show if status is IN_REVIEW
              if (content.status == 'IN_REVIEW')
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton.destructive(
                          label: 'Reject',
                          icon: Icons.close_rounded,
                          isLoading: _isProcessing,
                          onPressed: _isProcessing ? null : _handleReject,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: AppButton(
                          label: 'Approve',
                          icon: Icons.check_rounded,
                          isLoading: _isProcessing,
                          onPressed: _isProcessing ? null : _handleApprove,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This advisory has already been ${content.statusLabel.toLowerCase()}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
