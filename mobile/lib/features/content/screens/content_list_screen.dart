import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';

class ContentListScreen extends StatefulWidget {
  const ContentListScreen({super.key});

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final _searchController = TextEditingController();

  List<ContentModel> _allItems = [];
  List<ContentModel> _filteredItems = [];
  String? _selectedCategory;
  bool _isLoading = true;
  bool _isOffline = false;
  String? _error;

  static const List<String> _categories = [
    'All Topics',
    'Agronomy Advisory',
    'Pest & Disease Control',
    'Irrigation & Water',
    'Soil Health & Fertility',
    'Weather Alert',
    'Harvest & Storage',
  ];

  @override
  void initState() {
    super.initState();
    _loadContent();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isOffline = false;
    });

    try {
      // Active farmer bulletin feed shows published advisories
      final items = await _contentService.getAdvisories(status: 'PUBLISHED');
      if (!mounted) return;
      setState(() {
        _allItems = items;
        _isLoading = false;
      });
      _applyFilter();
    } on ApiException catch (e) {
      if (!mounted) return;
      final offline = _isNetworkError(e);
      setState(() {
        _isLoading = false;
        _isOffline = offline;
        _error = offline ? null : e.message;
      });
    } catch (e) {
      if (!mounted) return;
      final offline = _isNetworkError(e);
      setState(() {
        _isLoading = false;
        _isOffline = offline;
        _error = offline ? null : e.toString();
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesQuery = query.isEmpty ||
            item.title.toLowerCase().contains(query) ||
            (item.summary?.toLowerCase().contains(query) ?? false) ||
            item.body.toLowerCase().contains(query) ||
            (item.region?.toLowerCase().contains(query) ?? false);

        final matchesCat = _selectedCategory == null ||
            _selectedCategory == 'All Topics' ||
            item.category == _selectedCategory;

        return matchesQuery && matchesCat;
      }).toList();
    });
  }

  bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('backend down');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Agricultural Bulletins'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadContent,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p12, AppSizes.p16, 0),
              child: AppTextField(
                label: 'Search agricultural advisories...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            // Category filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSelected = (_selectedCategory ?? 'All Topics') == cat;
                  return FilterChip(
                    label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                    selected: isSelected,
                    selectedColor: theme.primaryColor,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat == 'All Topics' ? null : cat;
                      });
                      _applyFilter();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isOffline) {
      return _buildOffline();
    }

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

    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: theme.disabledColor),
            const SizedBox(height: AppSizes.p12),
            const Text('No published advisories match your filter.'),
            const SizedBox(height: AppSizes.p16),
            TextButton.icon(
              onPressed: _loadContent,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/content/detail',
                  arguments: item.id,
                );
              },
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
                            if (item.category != null)
                              Chip(
                                label: Text(item.category!, style: const TextStyle(fontSize: 10)),
                                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                padding: EdgeInsets.zero,
                              ),
                            if (item.priority == 'HIGH' || item.priority == 'URGENT')
                              Chip(
                                label: Text(item.priority, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                backgroundColor: item.priority == 'URGENT' ? Colors.red : Colors.orange,
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        Text(
                          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.summary != null && item.summary!.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        item.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item.locationDisplay,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        const Text(
                          'Read Advisory',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffline() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 72, color: Colors.grey),
            const SizedBox(height: AppSizes.p16),
            const Text(
              'You are Offline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            const Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: AppSizes.p24),
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
}
