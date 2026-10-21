import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final ApiClient _apiClient = ApiClient();
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  Timer? _timer;

  void startPolling() {
    _timer?.cancel();
    fetchNotifications();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => fetchNotifications());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');
      if (response is Map<String, dynamic>) {
        final list = (response['notifications'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final count = (response['unreadCount'] as int?) ?? list.where((n) => n['read'] == false).length;

        notificationsNotifier.value = list;
        unreadCountNotifier.value = count;
        return list;
      }
    } catch (e) {
      debugPrint('[NotificationService] fetchNotifications warning: $e');
    }
    return notificationsNotifier.value;
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.patch('/notifications/$id/read', {});

      final updated = notificationsNotifier.value.map((n) {
        if (n['id'] == id) {
          return {...n, 'read': true};
        }
        return n;
      }).toList();

      notificationsNotifier.value = updated;
      unreadCountNotifier.value = updated.where((n) => n['read'] == false).length;
    } catch (e) {
      debugPrint('[NotificationService] markAsRead error: $e');
    }
  }
}
