import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/config/user_session.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import 'advisory_approval_screen.dart';
import '../../../../core/widgets/screen_backdrop.dart';

import 'package:mobile/core/localization/app_localizations.dart';

class ContentReviewListScreen extends StatefulWidget {
  const ContentReviewListScreen({super.key});

  @override
  State<ContentReviewListScreen> createState() =>
      _ContentReviewListScreenState();
}

class _ContentReviewListScreenState extends State<ContentReviewListScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final _searchController = TextEditingController();

  List<ContentModel> _pendingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  List<ContentModel> _allPending = [];

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final items = await _contentService.getAdvisories(status: 'IN_REVIEW');
      if (!mounted) return;
      setState(() {
        _allPending = items;
        _isLoading = false;
      });
      _applyFilter();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _pendingItems = query.isEmpty
          ? _allPending
          : _allPending.where((item) {
              return item.title.toLowerCase().contains(query) ||
                  item.createdBy.toLowerCase().contains(query) ||
                  (item.cropId?.toLowerCase() ?? '').contains(query);
            }).toList();
    });
  }

  Future<void> _openDetail(ContentModel item) async {
    final decided = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdvisoryApprovalScreen(contentId: item.id),
      ),
    );
    // Approving or rejecting removes the item from the pending queue.
    if (decided == true) {
      _loadPending();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: ScreenBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            title: Text(appText('Content Review')),
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
                    AppTextField(
                      label: appText('Search title, author, or crop...'),
                      controller: _searchController,
                      prefixIcon: Icons.search_rounded,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _pendingItems.isEmpty
                          ? Center(
                              child: Text(
                                appText('No advisories awaiting review.'),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _pendingItems.length,
                              itemBuilder: (context, index) {
                                final item = _pendingItems[index];
                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSizes.p12,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSizes.p16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Chip(
                                              label: Text(
                                                item.cropId ?? 'Unknown',
                                              ),
                                              backgroundColor: theme
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                            ),
                                            Text(
                                              '${item.createdAt.month}/${item.createdAt.day}/${item.createdAt.year}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSizes.p8),
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: AppSizes.p4),
                                        Text(
                                          'Submitted by: ${item.createdBy}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        const Divider(height: AppSizes.p24),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                            ),
                                            label: Text(
                                              appText('View Details'),
                                            ),
                                            onPressed: () => _openDetail(item),
                                          ),
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
              // Drafts Tab
              const _ExpertDraftsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpertDraftsTab extends StatefulWidget {
  const _ExpertDraftsTab();

  @override
  State<_ExpertDraftsTab> createState() => _ExpertDraftsTabState();
}

class _ExpertDraftsTabState extends State<_ExpertDraftsTab> {
  final ContentService _service = ContentService(apiClient: ApiClient());
  List<ContentModel> _drafts = [];
  bool _loading = true;
  String? _error;
  String? _authorId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await UserSession.get();
      if (user == null) throw StateError('Sign in to view your drafts.');
      final drafts = await _service.getAdvisories(
        status: 'DRAFT',
        authorId: user.id,
      );
      if (!mounted) return;
      setState(() {
        _authorId = user.id;
        _drafts = drafts;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit(ContentModel draft) async {
    if (_authorId == null || draft.createdBy != _authorId) {
      _showError('Only the author can submit this draft for review.');
      return;
    }
    try {
      await _service.submitForReview(draft.id);
      await _load();
    } catch (error) {
      _showError('Draft could not be submitted: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            TextButton(onPressed: _load, child: Text(appText('Retry'))),
          ],
        ),
      );
    }
    if (_drafts.isEmpty) {
      return Center(child: Text(appText('No drafts available.')));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _drafts.length,
        itemBuilder: (context, index) {
          final draft = _drafts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              title: Text(draft.title),
              subtitle: Text(
                draft.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: appText('Submit for review'),
                icon: const Icon(Icons.send_outlined),
                onPressed: () => _submit(draft),
              ),
            ),
          );
        },
      ),
    );
  }
}
