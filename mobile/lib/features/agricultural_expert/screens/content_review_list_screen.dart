import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import 'advisory_approval_screen.dart';

class ContentReviewListScreen extends StatefulWidget {
  const ContentReviewListScreen({super.key});

  @override
  State<ContentReviewListScreen> createState() => _ContentReviewListScreenState();
}

class _ContentReviewListScreenState extends State<ContentReviewListScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final _searchController = TextEditingController();

  List<ContentModel> _pendingItems = [];
  List<ContentModel> _revisionItems = [];
  List<ContentModel> _approvedItems = [];
  List<ContentModel> _archivedItems = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQueues();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQueues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pending = await _contentService.getAdvisories(status: 'PENDING_REVIEW');
      final revision = await _contentService.getAdvisories(status: 'NEEDS_REVISION');
      final approved = await _contentService.getAdvisories(status: 'APPROVED');
      final published = await _contentService.getAdvisories(status: 'PUBLISHED');
      final archived = await _contentService.getAdvisories(status: 'ARCHIVED', includeArchived: true);

      if (!mounted) return;
      setState(() {
        _pendingItems = pending;
        _revisionItems = revision;
        _approvedItems = [...approved, ...published];
        _archivedItems = archived;
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

  List<ContentModel> _filter(List<ContentModel> list) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((item) {
      return item.title.toLowerCase().contains(q) ||
          (item.summary?.toLowerCase().contains(q) ?? false) ||
          item.createdBy.toLowerCase().contains(q) ||
          (item.cropId?.toLowerCase().contains(q) ?? false) ||
          (item.category?.toLowerCase().contains(q) ?? false) ||
          (item.region?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _openDetail(ContentModel item) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdvisoryApprovalScreen(contentId: item.id)),
    );
    if (changed == true) {
      _loadQueues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: ScreenBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Expert Review Queues'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadQueues,
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Pending (${_pendingItems.length})'),
                Tab(text: 'Revision Queue (${_revisionItems.length})'),
                Tab(text: 'Approved (${_approvedItems.length})'),
                Tab(text: 'Archived (${_archivedItems.length})'),
              ],
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: AppTextField(
                  label: 'Search title, topic, author, crop, or region...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.p24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                  const SizedBox(height: AppSizes.p12),
                                  Text(_error!, textAlign: TextAlign.center),
                                  const SizedBox(height: AppSizes.p16),
                                  ElevatedButton.icon(
                                    onPressed: _loadQueues,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : TabBarView(
                            children: [
                              _buildQueueList(_filter(_pendingItems), 'No advisories awaiting expert review.'),
                              _buildQueueList(_filter(_revisionItems), 'No advisories currently in author revision.'),
                              _buildQueueList(_filter(_approvedItems), 'No approved or published advisories.'),
                              _buildQueueList(_filter(_archivedItems), 'No archived advisories.'),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueList(List<ContentModel> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: AppSizes.p12),
              Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQueues,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final theme = Theme.of(context);

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
                      Wrap(
                        spacing: 6,
                        children: [
                          Chip(
                            label: Text(item.statusLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            backgroundColor: _statusColor(item.status).withValues(alpha: 0.15),
                            padding: EdgeInsets.zero,
                          ),
                          if (item.category != null)
                            Chip(
                              label: Text(item.category!, style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.grey.withValues(alpha: 0.12),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                      Text(
                        'v${item.version} • ${item.createdAt.month}/${item.createdAt.day}/${item.createdAt.year}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (item.summary != null && item.summary!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Scope: ${item.locationDisplay} • Lang: ${item.language.toUpperCase()} • Priority: ${item.priority}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const Divider(height: AppSizes.p20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Inspect & Review'),
                      onPressed: () => _openDetail(item),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED': return Colors.green;
      case 'APPROVED': return Colors.blue;
      case 'IN_REVIEW':
      case 'PENDING_REVIEW': return Colors.orange;
      case 'NEEDS_REVISION': return Colors.amber.shade800;
      case 'REJECTED': return Colors.red;
      case 'ARCHIVED': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}
