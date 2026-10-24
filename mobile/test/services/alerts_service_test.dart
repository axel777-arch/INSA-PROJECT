import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/alerts_service.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mockito/mockito.dart';

import 'content_service_test.mocks.dart';

void main() {
  group('AlertsService Tests', () {
    late AlertsService alertsService;
    late MockApiClient mockApiClient;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockApiClient = MockApiClient();
      alertsService = AlertsService(apiClient: mockApiClient);
    });

    test('getAlerts returns alerts and computes read status with local preferences', () async {
      when(mockApiClient.get(any)).thenAnswer((_) async => [
        {
          'id': 'alt-1',
          'title': 'Heavy Rainfall Warning',
          'body': 'Heavy rain expected in Oromia high altitudes.',
          'category': 'WEATHER',
          'severity': 'HIGH',
          'channel': 'IN_APP',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'alt-2',
          'title': 'Teff Price Update',
          'body': 'Teff price rose by 4% in Addis Ababa.',
          'category': 'MARKET',
          'severity': 'MEDIUM',
          'channel': 'SMS',
          'createdAt': DateTime.now().toIso8601String(),
        }
      ]);

      final alerts = await alertsService.getAlerts();
      expect(alerts.length, 2);
      expect(alerts.every((a) => a.isRead == false), isTrue);

      final unreadCount = await alertsService.getUnreadCount();
      expect(unreadCount, 2);
    });

    test('markAsRead updates read status and unread count', () async {
      when(mockApiClient.get('/alerts')).thenThrow(ApiException('Offline'));

      final initialAlerts = await alertsService.getAlerts();
      expect(initialAlerts.isNotEmpty, isTrue);
      final initialUnread = await alertsService.getUnreadCount();

      final firstId = initialAlerts.first.id;
      await alertsService.markAsRead(firstId);

      final updatedAlerts = await alertsService.getAlerts();
      final markedItem = updatedAlerts.firstWhere((a) => a.id == firstId);
      expect(markedItem.isRead, isTrue);

      final newUnread = await alertsService.getUnreadCount();
      expect(newUnread, initialUnread - 1);
    });

    test('getAlerts filters accurately by category', () async {
      when(mockApiClient.get('/alerts')).thenThrow(ApiException('Offline'));

      final weatherAlerts = await alertsService.getAlerts(category: 'WEATHER');
      expect(weatherAlerts.isNotEmpty, isTrue);
      expect(weatherAlerts.every((a) => a.category == 'WEATHER'), isTrue);

      final pestAlerts = await alertsService.getAlerts(category: 'PEST_DISEASE');
      expect(pestAlerts.isNotEmpty, isTrue);
      expect(pestAlerts.every((a) => a.category == 'PEST_DISEASE'), isTrue);
    });

    test('markAllAsRead marks all items as read', () async {
      when(mockApiClient.get('/alerts')).thenThrow(ApiException('Offline'));

      await alertsService.markAllAsRead();
      final unread = await alertsService.getUnreadCount();
      expect(unread, 0);

      final alerts = await alertsService.getAlerts();
      expect(alerts.every((a) => a.isRead == true), isTrue);
    });
  });
}
