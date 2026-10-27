import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/offline_advisory_service.dart';

class OfflineAdvisoriesScreen extends StatefulWidget {
  const OfflineAdvisoriesScreen({super.key});

  @override
  State<OfflineAdvisoriesScreen> createState() =>
      _OfflineAdvisoriesScreenState();
}

class _OfflineAdvisoriesScreenState extends State<OfflineAdvisoriesScreen> {
  final OfflineAdvisoryService _offlineService = OfflineAdvisoryService();
  List<SavedAdvisoryItem> _savedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    setState(() => _isLoading = true);
    final items = await _offlineService.getSavedAdvisories();
    if (!mounted) return;
    setState(() {
      _savedItems = items;
      _isLoading = false;
    });
  }

  Future<void> _removeItem(String id, String title) async {
    await _offlineService.removeAdvisory(id);
    await _loadSaved();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed "$title" from offline storage.')),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appText('Clear Offline Storage?')),
        content: Text(
          appText(
            'This will remove all locally saved advisories. You will need an internet connection to download them again.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(appText('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              appText('Clear All'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _offlineService.clearAll();
      await _loadSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.offlineLibrary),
          actions: [
            if (_savedItems.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: appText('Clear offline storage'),
                onPressed: _clearAll,
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedItems.isEmpty
            ? _buildEmptyState(theme, loc)
            : _buildList(theme, loc),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_done_rounded,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              appText('No Saved Advisories'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              appText(
                'You can save published advisories for offline reading when you have an internet connection. Only expert-approved published content can be saved.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: AppSizes.p20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/content/list');
              },
              icon: const Icon(Icons.explore_outlined),
              label: Text(appText('Browse Published Advisories')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme, AppLocalizations loc) {
    return Column(
      children: [
        // Status header
        Container(
          width: double.infinity,
          color: theme.primaryColor.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p16,
            vertical: AppSizes.p10,
          ),
          child: Row(
            children: [
              Icon(
                Icons.offline_pin_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppSizes.p8),
              Text(
                '${_savedItems.length} Cached Advisories Ready Offline',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: _savedItems.length,
            itemBuilder: (context, index) {
              final item = _savedItems[index];
              final advisory = item.advisory;
              final isStale = item.isStale;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.p12),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title and Delete icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              advisory.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () =>
                                _removeItem(advisory.id, advisory.title),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Snippet of body
                      Text(
                        advisory.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                      const Divider(height: AppSizes.p20),

                      // Footer: Cached time and stale indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Cached ${item.cachedAgo}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (isStale)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    appText('Stale (>14d)'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/content/detail',
                                arguments: advisory.id,
                              );
                            },
                            child: Text(appText('Read Full Body')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
