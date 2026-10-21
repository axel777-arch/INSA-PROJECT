import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/notification_service.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  final NotificationService _service = NotificationService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    await _service.fetchNotifications();
    if (mounted) setState(() => _isLoading = false);
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    final id = alert['id'] as String;
    final route = alert['route'] as String? ?? '';
    final resourceId = alert['resourceId'] as String? ?? '';

    // Mark as read
    _service.markAsRead(id);

    // Direct in-app navigation to underlying resource
    if (route.isNotEmpty) {
      if (route == '/content/detail') {
        Navigator.pushNamed(context, '/content/detail', arguments: resourceId);
        return;
      }
      if (route == '/expert/reviews') {
        Navigator.pushNamed(context, '/expert/review/list');
        return;
      }
      Navigator.pushNamed(context, route);
      return;
    }

    // Fallback: show alert modal dialog
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(alert['title'] ?? 'System Alert'),
        content: Text(alert['body'] ?? 'No additional details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'PENDING_USER_APPROVAL':
        return Icons.person_add_rounded;
      case 'FIELD_CASE_ASSIGNED':
      case 'CASE_RESOLVED':
        return Icons.biotech_rounded;
      case 'CONTENT_REVIEW_REQUIRED':
      case 'ADVISORY_PUBLISHED':
      case 'ADVISORY_ALERT':
        return Icons.campaign_rounded;
      case 'AUDIT_EVENT':
        return Icons.security_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'FIELD_CASE_ASSIGNED':
        return AppColors.error;
      case 'ADVISORY_ALERT':
        return Colors.orange;
      case 'CONTENT_REVIEW_REQUIRED':
        return Colors.blue;
      case 'PENDING_USER_APPROVAL':
      case 'ADVISORY_PUBLISHED':
      case 'CASE_RESOLVED':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Notifications & Real-Time Alerts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: _loadAlerts,
            ),
          ],
        ),
        body: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _service.notificationsNotifier,
          builder: (context, notifications, _) {
            if (_isLoading && notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 64, color: theme.disabledColor),
                    const SizedBox(height: 12),
                    const Text('No alerts or notifications at this time.', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('You will be notified immediately when events occur.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadAlerts,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final alert = notifications[index];
                  final isRead = alert['read'] as bool? ?? false;
                  final title = alert['title'] as String? ?? 'Notification';
                  final body = alert['body'] as String? ?? '';
                  final type = alert['type'] as String? ?? 'SYSTEM';
                  final icon = _getIconForType(type);
                  final color = _getColorForType(type);

                  return Card(
                    elevation: isRead ? 0 : 2,
                    margin: const EdgeInsets.only(bottom: AppSizes.p12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isRead ? Colors.grey.shade300 : color.withValues(alpha: 0.5),
                        width: isRead ? 0.5 : 1.5,
                      ),
                    ),
                    color: isRead ? null : color.withValues(alpha: 0.04),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(icon, color: color),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          body,
                          style: TextStyle(
                            fontSize: 12,
                            color: isRead ? Colors.grey.shade600 : Colors.black87,
                          ),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      onTap: () => _handleAlertTap(alert),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
