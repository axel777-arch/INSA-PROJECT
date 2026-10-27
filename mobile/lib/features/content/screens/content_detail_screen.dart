import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../services/offline_advisory_service.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  final OfflineAdvisoryService _offlineService = OfflineAdvisoryService();

  ContentModel? _content;
  bool _isLoading = true;
  String? _error;
  bool _isOfflineCopy = false;
  bool _isSavedOffline = false;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await _contentService.getAdvisoryById(widget.contentId);
      final isSaved = await _offlineService.isSaved(widget.contentId);

      if (!mounted) return;
      setState(() {
        _content = content;
        _isSavedOffline = isSaved;
        _isLoading = false;
        _isOfflineCopy = false;
      });
    } catch (e) {
      // Check offline cache if network failed
      final offlineItems = await _offlineService.getSavedAdvisories();
      final cached = offlineItems
          .where((i) => i.advisory.id == widget.contentId)
          .firstOrNull;

      if (!mounted) return;
      if (cached != null) {
        setState(() {
          _content = cached.advisory;
          _isSavedOffline = true;
          _isOfflineCopy = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _toggleSaveOffline() async {
    if (_content == null) return;

    if (_content!.status.toUpperCase() != 'PUBLISHED') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appText(
              'Only expert-approved PUBLISHED advisories can be cached offline.',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isSavedOffline) {
      await _offlineService.removeAdvisory(_content!.id);
      if (!mounted) return;
      setState(() => _isSavedOffline = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appText('Removed advisory from offline storage.')),
        ),
      );
    } else {
      await _offlineService.saveAdvisory(_content!);
      if (!mounted) return;
      setState(() => _isSavedOffline = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appText('Advisory saved for offline access!')),
          backgroundColor: AppColors.success,
        ),
      );
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
          title: Text(loc.information),
          actions: [
            if (_content != null &&
                _content!.status.toUpperCase() == 'PUBLISHED')
              IconButton(
                icon: Icon(
                  _isSavedOffline
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _isSavedOffline ? theme.primaryColor : null,
                ),
                tooltip: _isSavedOffline
                    ? loc.savedOffline
                    : loc.saveForOffline,
                onPressed: _toggleSaveOffline,
              ),
          ],
        ),
        body: _buildBody(theme, loc),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations loc) {
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
                label: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_content == null) {
      return Center(child: Text(appText('Advisory not found.')));
    }

    final content = _content!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline banner if loaded from local cache
          if (_isOfflineCopy)
            Container(
              margin: const EdgeInsets.only(bottom: AppSizes.p12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.offline_pin_rounded, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    appText('Reading Saved Offline Copy'),
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Status chip + Offline Save button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(content.statusLabel),
                backgroundColor: _statusColor(
                  content.status,
                ).withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: _statusColor(content.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              if (content.status.toUpperCase() == 'PUBLISHED')
                TextButton.icon(
                  onPressed: _toggleSaveOffline,
                  icon: Icon(
                    _isSavedOffline
                        ? Icons.check_circle_rounded
                        : Icons.download_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _isSavedOffline ? loc.savedOffline : loc.saveForOffline,
                  ),
                ),
            ],
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
                _metaChip(
                  Icons.language_rounded,
                  content.language.toUpperCase(),
                ),
              _metaChip(
                Icons.calendar_today_outlined,
                '${content.createdAt.year}-${content.createdAt.month.toString().padLeft(2, '0')}-${content.createdAt.day.toString().padLeft(2, '0')}',
              ),
            ],
          ),
          const Divider(height: AppSizes.p24),

          // Simulated Audio Readout Player
          Card(
            color: theme.primaryColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p12),
              child: Row(
                children: [
                  IconButton.filled(
                    icon: Icon(
                      _isPlayingAudio
                          ? Icons.pause_rounded
                          : Icons.volume_up_rounded,
                    ),
                    onPressed: () {
                      setState(() => _isPlayingAudio = !_isPlayingAudio);
                    },
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.readAloud,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _isPlayingAudio
                              ? 'Simulating audio readout...'
                              : 'Listen in your chosen language',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // Body text
          Text(
            content.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: 15,
            ),
          ),

          if (content.approvedBy != null) ...[
            const SizedBox(height: AppSizes.p24),
            Card(
              color: AppColors.success.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSizes.p8),
                    Expanded(
                      child: Text(
                        appText(
                          'Reviewed and approved by an agricultural expert.',
                        ),
                        style: TextStyle(
                          color: AppColors.success.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
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
      case 'PUBLISHED':
        return AppColors.success;
      case 'IN_REVIEW':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'REJECTED':
        return AppColors.error;
      case 'ARCHIVED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
