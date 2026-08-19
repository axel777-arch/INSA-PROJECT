import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/content_model.dart';
import '../../../services/api_client.dart';
import '../../../services/mock_api_client.dart';
import '../../../services/content_service.dart';
import 'advisory_approval_screen.dart';

class ContentReviewListScreen extends StatefulWidget {
  const ContentReviewListScreen({super.key});

  @override
  State<ContentReviewListScreen> createState() => _ContentReviewListScreenState();
}

class _ContentReviewListScreenState extends State<ContentReviewListScreen> {
  final ContentService _contentService = ContentService(apiClient: MockApiClient());
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
    final items = await _contentService.getAdvisories(status: 'IN_REVIEW');
    if (!mounted) return;
    setState(() {
      _allPending = items;
      _isLoading = false;
    });
    _applyFilter();
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _pendingItems = query.isEmpty
          ? _allPending
          : _allPending.where((item) {
              return item.title.toLowerCase().contains(query) ||
                  item.createdBy.toLowerCase().contains(query) ||
                  item.cropId.toLowerCase().contains(query);
            }).toList();
    });
  }

  Future<void> _openDetail(ContentModel item) async {
    final decided = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdvisoryApprovalScreen(contentId: item.id)),
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
                  AppTextField(
                    label: 'Search title, author, or crop...',
                    controller: _searchController,
                    prefixIcon: Icons.search_rounded,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _pendingItems.isEmpty
                            ? const Center(child: Text('No advisories awaiting review.'))
                            : ListView.builder(
                                itemCount: _pendingItems.length,
                                itemBuilder: (context, index) {
                                  final item = _pendingItems[index];
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
                                                label: Text(item.cropId),
                                                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
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
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: AppSizes.p4),
                                          Text('Submitted by: ${item.createdBy}', style: theme.textTheme.bodySmall),
                                          const Divider(height: AppSizes.p24),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              icon: const Icon(Icons.arrow_forward_rounded),
                                              label: const Text('View Details'),
                                              onPressed: () => _openDetail(item),
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
