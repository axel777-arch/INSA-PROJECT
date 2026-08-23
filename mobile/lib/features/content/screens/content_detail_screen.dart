import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  ContentModel? _content;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final content = await _contentService.getAdvisoryById(widget.contentId);
      if (!mounted) return;
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.message; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Article Detail')),
        body: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.p12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p16),
              ElevatedButton.icon(
                onPressed: _loadContent,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_content == null) {
      return const Center(child: Text('Advisory not found.'));
    }

    final content = _content!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chip
          Chip(
            label: Text(content.statusLabel),
            backgroundColor: _statusColor(content.status).withValues(alpha: 0.15),
            labelStyle: TextStyle(color: _statusColor(content.status), fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: AppSizes.p12),

          Text(
            content.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: AppSizes.p12),

          // Metadata row
          Wrap(
            spacing: AppSizes.p8,
            runSpacing: AppSizes.p8,
            children: [
              if (content.language.isNotEmpty)
                _metaChip(Icons.language_rounded, content.language.toUpperCase()),
              _metaChip(
                Icons.calendar_today_outlined,
                '${content.createdAt.year}-${content.createdAt.month.toString().padLeft(2, '0')}-${content.createdAt.day.toString().padLeft(2, '0')}',
              ),
            ],
          ),

          const Divider(height: AppSizes.p32),

          Text(
            content.body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),

          if (content.approvedBy != null) ...[
            const SizedBox(height: AppSizes.p20),
            Card(
              color: AppColors.success.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: AppColors.success),
                    const SizedBox(width: AppSizes.p8),
                    Expanded(
                      child: Text(
                        'Reviewed and approved by an agricultural expert.',
                        style: TextStyle(color: AppColors.success.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED': return AppColors.success;
      case 'IN_REVIEW': return Colors.orange;
      case 'APPROVED': return Colors.blue;
      case 'REJECTED': return AppColors.error;
      case 'ARCHIVED': return Colors.grey;
      default: return Colors.grey;
    }
  }
}
