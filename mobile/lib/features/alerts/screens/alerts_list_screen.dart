import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/notification_item_model.dart';
import '../../../../services/alerts_service.dart';
import '../../../../services/api_client.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  final AlertsService _alertsService = AlertsService(apiClient: ApiClient());
  List<NotificationItemModel> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'WEATHER',
    'PEST_DISEASE',
    'MARKET',
    'ADVISORY',
  ];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _alertsService.getAlerts(
        category: _selectedCategory == 'ALL' ? null : _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _alerts = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationItemModel item) async {
    setState(() => item.isRead = true);
    await _alertsService.markAsRead(item.id);
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (final a in _alerts) {
        a.isRead = true;
      }
    });
    await _alertsService.markAllAsRead();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appText('All alerts marked as read.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.alerts),
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              tooltip: appText('Mark all as read'),
              onPressed: _alerts.any((a) => !a.isRead) ? _markAllAsRead : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: loc.refresh,
              onPressed: _loadAlerts,
            ),
          ],
        ),
        body: Column(
          children: [
            // Category filter chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.p8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(_categoryLabel(cat)),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                      _loadAlerts();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p8),

            // Content
            Expanded(child: _buildBody(theme, loc)),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'ALL':
        return 'All Alerts';
      case 'WEATHER':
        return 'Weather';
      case 'PEST_DISEASE':
        return 'Pests & Diseases';
      case 'MARKET':
        return 'Market Alerts';
      case 'ADVISORY':
        return 'Advisories';
      default:
        return cat;
    }
  }

  Widget _buildBody(ThemeData theme, AppLocalizations loc) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.p12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p16),
              ElevatedButton.icon(
                onPressed: _loadAlerts,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: AppSizes.p12),
            Text(appText('No alerts found for this category.')),
            const SizedBox(height: AppSizes.p16),
            TextButton.icon(
              onPressed: () {
                setState(() => _selectedCategory = 'ALL');
                _loadAlerts();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(appText('Show All Alerts')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final item = _alerts[index];
          final severityColor = _severityColor(item.severity);

          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: severityColor.withValues(alpha: 0.15),
                    child: Icon(
                      _categoryIcon(item.category),
                      color: severityColor,
                      size: 22,
                    ),
                  ),
                  if (!item.isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.severity,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: severityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Text(
                        '${item.channel} • ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                _markAsRead(item);
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          _categoryIcon(item.category),
                          color: severityColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.body, style: const TextStyle(height: 1.5)),
                          const Divider(height: 24),
                          Text(
                            'Channel: ${item.channel}  •  Severity: ${item.severity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(appText('Close')),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toUpperCase()) {
      case 'WEATHER':
        return Icons.thunderstorm_outlined;
      case 'PEST_DISEASE':
        return Icons.pest_control_outlined;
      case 'MARKET':
        return Icons.storefront_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  Color _severityColor(String sev) {
    switch (sev.toUpperCase()) {
      case 'HIGH':
        return AppColors.error;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
