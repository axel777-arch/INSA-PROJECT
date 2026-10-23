import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';

class AdvisoryApprovalScreen extends StatefulWidget {
  final String contentId;

  const AdvisoryApprovalScreen({super.key, this.contentId = ''});

  @override
  State<AdvisoryApprovalScreen> createState() => _AdvisoryApprovalScreenState();
}

class _AdvisoryApprovalScreenState extends State<AdvisoryApprovalScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());

  ContentModel? _content;
  List<ContentVersionModel> _versions = [];
  List<ContentReviewModel> _reviews = [];

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (widget.contentId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No content ID provided.';
      });
      return;
    }

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

  Future<void> _handleApprove() async {
    if (_content == null || _isProcessing) return;

    final commentController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Advisory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to approve this agronomic advisory for publication?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Validation notes / comments (optional)',
                hintText: 'e.g. Verified against EIAR guidelines',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve Advisory'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isProcessing = true);

    try {
      await _contentService.approveAdvisory(
        _content!.id,
        comment: commentController.text.trim().isNotEmpty ? commentController.text.trim() : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advisory Approved Successfully!'), backgroundColor: AppColors.success),
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

  Future<void> _handleRequestRevision() async {
    if (_content == null || _isProcessing) return;

    final commentController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Revisions / Additional Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify the exact technical modifications or missing information the author must provide before this advisory can be approved:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Expert Comments / Requirements *',
                hintText: 'e.g. Specify chemical application rates per hectare...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade800),
            onPressed: () {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Comments are required for revision requests.')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Request Revision'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isProcessing = true);

    try {
      await _contentService.requestRevision(_content!.id, commentController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft returned to author for revision.'),
          backgroundColor: Colors.amber,
        ),
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

    final commentController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Advisory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This advisory will be permanently rejected from publication. Please state the justification for audit compliance:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection *',
                hintText: 'e.g. Inaccurate agronomic treatment contradicted by research...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Rejection reason is mandatory.')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Confirm Rejection'),
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

  Future<void> _handlePublish() async {
    if (_content == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _contentService.publishAdvisory(_content!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Advisory published and queued for farmer delivery!'),
          backgroundColor: AppColors.success,
        ),
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

  Future<void> _handleArchive() async {
    if (_content == null || _isProcessing) return;
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Advisory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Archived advisories remain accessible for historical reference, but will not be delivered to farmers.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for archiving (optional)',
                hintText: 'e.g. End of seasonal validity window',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isProcessing = true);

    try {
      await _contentService.archiveAdvisory(_content!.id, reason: reasonController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advisory moved to Archive.'), backgroundColor: Colors.blueGrey),
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
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSizes.p12),
                  Text(_error ?? 'Advisory not found.', textAlign: TextAlign.center),
                  const SizedBox(height: AppSizes.p16),
                  ElevatedButton.icon(
                    onPressed: _loadAll,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final content = _content!;
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Review: ${content.title}'),
          actions: [
            if (content.isApproved)
              IconButton(
                icon: const Icon(Icons.send_rounded),
                tooltip: 'Publish Advisory',
                onPressed: _isProcessing ? null : _handlePublish,
              ),
            if (content.isApproved || content.isPublished)
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                tooltip: 'Archive Advisory',
                onPressed: _isProcessing ? null : _handleArchive,
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  children: [
                    // Header Status & Version Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(content.statusLabel),
                          backgroundColor: _statusColor(content.status).withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: _statusColor(content.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Version ${content.version}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p12),

                    // Advisory Title
                    Text(
                      content.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),

                    // Summary Block
                    if (content.summary != null && content.summary!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          content.summary!,
                          style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                    ],

                    // Metadata Badges Wrap
                    Wrap(
                      spacing: AppSizes.p8,
                      runSpacing: AppSizes.p8,
                      children: [
                        _infoChip(Icons.language_rounded, content.language.toUpperCase()),
                        if (content.category != null) _infoChip(Icons.category_outlined, content.category!),
                        _infoChip(Icons.flag_outlined, 'Priority: ${content.priority}'),
                        if (content.region != null) _infoChip(Icons.place_outlined, content.locationDisplay),
                        if (content.season != null) _infoChip(Icons.wb_sunny_outlined, content.season!),
                        if (content.cropStage != null) _infoChip(Icons.grass_outlined, content.cropStage!),
                      ],
                    ),
                    const Divider(height: AppSizes.p24),

                    // Technical Content Body
                    Text(
                      'Technical Instructions & Content',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        content.body,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.6, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),

                    // Reference & Source Information
                    if (content.sourceInfo != null && content.sourceInfo!.isNotEmpty) ...[
                      Text(
                        'Scientific Reference & Attribution',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(content.sourceInfo!, style: theme.textTheme.bodySmall),
                      const SizedBox(height: AppSizes.p16),
                    ],

                    // Attachments Link
                    if (content.attachments != null && content.attachments!.isNotEmpty) ...[
                      Text(
                        'Supporting Attachments / Documents',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(content.attachments!, style: const TextStyle(color: Colors.blue, fontSize: 13)),
                      const SizedBox(height: AppSizes.p16),
                    ],

                    // Version History Expansion Tile
                    _buildVersionHistorySection(theme),
                    const SizedBox(height: AppSizes.p12),

                    // Editorial Review History
                    _buildReviewHistorySection(theme),
                  ],
                ),
              ),

              // Action Toolbar
              if (content.isPendingReview)
                Container(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                          ),
                          onPressed: _isProcessing ? null : _handleReject,
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber.shade900,
                            side: BorderSide(color: Colors.amber.shade800),
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                          ),
                          onPressed: _isProcessing ? null : _handleRequestRevision,
                          child: const Text('Request Revision'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Expanded(
                        child: AppButton(
                          label: 'Approve',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: _isProcessing,
                          onPressed: _isProcessing ? null : _handleApprove,
                        ),
                      ),
                    ],
                  ),
                )
              else if (content.isApproved)
                Container(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  color: Colors.white,
                  child: AppButton(
                    label: 'Publish Advisory to Farmers',
                    icon: Icons.send_rounded,
                    isLoading: _isProcessing,
                    onPressed: _isProcessing ? null : _handlePublish,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildVersionHistorySection(ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.7),
      child: ExpansionTile(
        leading: const Icon(Icons.history_rounded),
        title: Text('Version History (${_versions.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Inspect previously reviewed iterations', style: TextStyle(fontSize: 12)),
        children: [
          if (_versions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSizes.p16),
              child: Text('No previous versions recorded.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _versions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final v = _versions[idx];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    child: Text('v${v.versionNumber}', style: TextStyle(fontSize: 11, color: theme.primaryColor)),
                  ),
                  title: Text(v.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${v.statusAtVersion} • ${v.changeSummary ?? "Revision snapshot"} • '
                    '${v.createdAt.month}/${v.createdAt.day}/${v.createdAt.year}',
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewHistorySection(ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.7),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.rate_review_outlined),
        title: Text('Review Decisions & Notes (${_reviews.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          if (_reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSizes.p16),
              child: Text('No formal review decisions recorded yet.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final r = _reviews[idx];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    r.status == 'APPROVED'
                        ? Icons.check_circle_outline
                        : (r.status == 'NEEDS_REVISION' ? Icons.assignment_late_outlined : Icons.cancel_outlined),
                    color: _statusColor(r.status),
                  ),
                  title: Text(
                    '${r.status}: ${r.reviewerName ?? "Expert"} (${r.reviewerRole ?? "EXPERT"})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (r.comments != null && r.comments!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(r.comments!, style: const TextStyle(fontSize: 12)),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          '${r.reviewedAt.month}/${r.reviewedAt.day}/${r.reviewedAt.year} at ${r.reviewedAt.hour}:${r.reviewedAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED': return AppColors.success;
      case 'APPROVED': return Colors.blue;
      case 'IN_REVIEW':
      case 'PENDING_REVIEW': return Colors.orange;
      case 'NEEDS_REVISION': return Colors.amber.shade800;
      case 'REJECTED': return AppColors.error;
      case 'ARCHIVED': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}
