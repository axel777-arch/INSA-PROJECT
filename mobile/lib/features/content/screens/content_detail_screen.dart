import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import 'content_form_screen.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  ContentModel? _content;
  List<ContentVersionModel> _versions = [];
  List<ContentReviewModel> _reviews = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await _contentService.getAdvisoryById(widget.contentId);
      final versions = await _contentService.getContentVersions(widget.contentId);
      final reviews = await _contentService.getContentReviews(widget.contentId);

      if (!mounted) return;
      setState(() {
        _content = content;
        _versions = versions;
        _reviews = reviews;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openEdit() async {
    if (_content == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ContentFormScreen(initialContent: _content),
      ),
    );

    if (updated == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Advisory Bulletin'),
          actions: [
            if (_content != null && (_content!.isDraft || _content!.isNeedsRevision))
              IconButton(
                icon: const Icon(Icons.edit_note_rounded),
                tooltip: 'Edit Advisory',
                onPressed: _openEdit,
              ),
          ],
        ),
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
                onPressed: _loadData,
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
          // Revision notice banner if needs revision
          if (content.isNeedsRevision) _buildNeedsRevisionAlert(theme),

          // Status & Version Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(content.statusLabel),
                backgroundColor: _statusColor(content.status).withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: _statusColor(content.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'v${content.version}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p12),

          // Title
          Text(
            content.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: AppSizes.p12),

          // Summary digest (if present)
          if (content.summary != null && content.summary!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Text(
                content.summary!,
                style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4, fontSize: 14),
              ),
            ),
            const SizedBox(height: AppSizes.p12),
          ],

          // Metadata row
          Wrap(
            spacing: AppSizes.p8,
            runSpacing: AppSizes.p8,
            children: [
              _metaChip(Icons.language_rounded, content.language.toUpperCase()),
              if (content.category != null) _metaChip(Icons.category_outlined, content.category!),
              _metaChip(Icons.flag_outlined, content.priority),
              _metaChip(Icons.place_outlined, content.locationDisplay),
              if (content.season != null) _metaChip(Icons.wb_sunny_outlined, content.season!),
              if (content.cropStage != null) _metaChip(Icons.grass_outlined, content.cropStage!),
              _metaChip(
                Icons.calendar_today_outlined,
                '${content.createdAt.year}-${content.createdAt.month.toString().padLeft(2, '0')}-${content.createdAt.day.toString().padLeft(2, '0')}',
              ),
            ],
          ),

          const Divider(height: AppSizes.p32),

          // Main body content
          Text(
            content.body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.7, fontSize: 15),
          ),

          // Scientific Source & References
          if (content.sourceInfo != null && content.sourceInfo!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.p20),
            Text(
              'Research Reference & Source',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(content.sourceInfo!, style: theme.textTheme.bodySmall),
          ],

          // Attachments
          if (content.attachments != null && content.attachments!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.p16),
            Text(
              'Supporting Attachments',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(content.attachments!, style: const TextStyle(color: Colors.blue, fontSize: 13)),
          ],

          // Verified banner if approved
          if (content.approvedBy != null || content.isPublished) ...[
            const SizedBox(height: AppSizes.p20),
            Card(
              color: AppColors.success.withValues(alpha: 0.08),
              child: const Padding(
                padding: EdgeInsets.all(AppSizes.p12),
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined, color: AppColors.success),
                    SizedBox(width: AppSizes.p8),
                    Expanded(
                      child: Text(
                        'Verified and approved by an agricultural domain expert.',
                        style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSizes.p20),

          // Edit/Revise button if in revision or draft
          if (content.isDraft || content.isNeedsRevision)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(content.isNeedsRevision ? 'Address Comments & Revise' : 'Edit Draft'),
                onPressed: _openEdit,
              ),
            ),

          const SizedBox(height: AppSizes.p16),

          // Version History
          if (_versions.isNotEmpty) _buildVersionHistory(),

          const SizedBox(height: AppSizes.p12),

          // Editorial Reviews
          if (_reviews.isNotEmpty) _buildReviewHistory(),
        ],
      ),
    );
  }

  Widget _buildNeedsRevisionAlert(ThemeData theme) {
    final latestReview = _reviews.firstOrNull;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_late_rounded, color: Colors.amber.shade900),
              const SizedBox(width: AppSizes.p8),
              const Text(
                'Changes Requested by Expert Reviewer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          if (latestReview?.comments != null && latestReview!.comments!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              latestReview.comments!,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVersionHistory() {
    return Card(
      elevation: 0,
      color: Colors.grey.withValues(alpha: 0.08),
      child: ExpansionTile(
        leading: const Icon(Icons.history_rounded),
        title: Text('Version History (${_versions.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: _versions.map((v) {
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 12,
              child: Text('v${v.versionNumber}', style: const TextStyle(fontSize: 10)),
            ),
            title: Text(v.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${v.statusAtVersion} • ${v.changeSummary ?? "Draft saved"} • '
              '${v.createdAt.year}-${v.createdAt.month.toString().padLeft(2, '0')}-${v.createdAt.day.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewHistory() {
    return Card(
      elevation: 0,
      color: Colors.grey.withValues(alpha: 0.08),
      child: ExpansionTile(
        leading: const Icon(Icons.rate_review_outlined),
        title: Text('Review Trail (${_reviews.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: _reviews.map((r) {
          return ListTile(
            dense: true,
            title: Text(
              '${r.status}: ${r.reviewerName ?? "Expert"}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.comments != null)
                  Text(r.comments!, style: const TextStyle(fontSize: 12)),
                Text(
                  '${r.reviewedAt.month}/${r.reviewedAt.day}/${r.reviewedAt.year} ${r.reviewedAt.hour}:${r.reviewedAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
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
          Icon(icon, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED': return AppColors.success;
      case 'IN_REVIEW':
      case 'PENDING_REVIEW': return Colors.orange;
      case 'NEEDS_REVISION': return Colors.amber.shade800;
      case 'APPROVED': return Colors.blue;
      case 'REJECTED': return AppColors.error;
      case 'ARCHIVED': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}
