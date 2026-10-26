import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item_model.dart';
import 'api_client.dart';

class AlertsService {
  static const String _readAlertsKey = 'farmer_read_alert_ids';

  final ApiClient? apiClient;
  final SharedPreferences? _prefs;

  AlertsService({this.apiClient, SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  static final List<NotificationItemModel> _benchmarkAlerts = [
    NotificationItemModel(
      id: 'alert-weather-01',
      title: 'Heavy Rainfall & Flash Flood Advisory',
      body:
          'Ethiopian Meteorology Institute forecasts intense rainfall across East Shewa and Arsi over the next 48 hours. Clear drainage canals in teff and wheat fields immediately.',
      category: 'WEATHER',
      severity: 'HIGH',
      channel: 'SMS',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationItemModel(
      id: 'alert-pest-01',
      title: 'Wheat Stripe Rust Warning: High Humidity Alert',
      body:
          'Spore germination risk elevated in high-altitude zones (>2200m). Scout flag leaves for yellowish-orange pustules. Report suspected clusters to your local DA.',
      category: 'PEST_DISEASE',
      severity: 'HIGH',
      channel: 'SMS',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationItemModel(
      id: 'alert-market-01',
      title: 'Teff Price Update — Adama Central Market',
      body:
          'Magna Teff prices increased +1.8% to 13,500 ETB per quintal. Check latest directory prices before committing to field brokers.',
      category: 'MARKET',
      severity: 'MEDIUM',
      channel: 'IN_APP',
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    NotificationItemModel(
      id: 'alert-advisory-01',
      title: 'NPS Fertilizer Split Application Reminder',
      body:
          'Mid-season top dressing for maize planted 4 weeks ago is now due. Apply during moist soil conditions to prevent volatilization loss.',
      category: 'ADVISORY',
      severity: 'INFO',
      channel: 'IN_APP',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Fetches the signed-in user's notifications from the real backend endpoint.
  /// Benchmark alerts are only used when the backend cannot be reached, not
  /// when the backend successfully reports that the user has no notifications.
  Future<List<NotificationItemModel>> getAlerts({String? category}) async {
    final prefs = await _getPrefs();
    final readIds = (prefs.getStringList(_readAlertsKey) ?? <String>[]).toSet();
    var items = <NotificationItemModel>[];
    var backendResponded = false;

    if (apiClient != null) {
      try {
        final dynamic res = await apiClient!.get('/notifications');
        backendResponded = true;
        final dynamic rawItems = res is Map<String, dynamic>
            ? res['notifications']
            : res;
        if (rawItems is List) {
          items = rawItems.map((raw) {
            final map = Map<String, dynamic>.from(raw as Map);
            final type =
                (map['type'] ??
                        map['eventType'] ??
                        map['category'] ??
                        'ADVISORY')
                    .toString()
                    .toUpperCase();
            final category = type.contains('ADVISORY')
                ? 'ADVISORY'
                : type.contains('WEATHER')
                ? 'WEATHER'
                : type.contains('PEST') || type.contains('DISEASE')
                ? 'PEST_DISEASE'
                : type.contains('MARKET')
                ? 'MARKET'
                : type;
            return NotificationItemModel(
              id:
                  map['id']?.toString() ??
                  'notif-${DateTime.now().millisecondsSinceEpoch}',
              title: map['title']?.toString() ?? 'Notification',
              body: map['body']?.toString() ?? '',
              category: category,
              severity: map['severity']?.toString() ?? 'MEDIUM',
              channel: map['channel']?.toString() ?? 'IN_APP',
              isRead: map['read'] == true || map['isRead'] == true,
              createdAt:
                  DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                  DateTime.now(),
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('[AlertsService] Backend notifications query failed: $e');
      }
    }

    if (!backendResponded) {
      items = List<NotificationItemModel>.from(_benchmarkAlerts);
    }

    for (final item in items) {
      if (readIds.contains(item.id)) item.isRead = true;
    }
    if (category != null && category.isNotEmpty && category != 'ALL') {
      items = items
          .where((i) => i.category.toUpperCase() == category.toUpperCase())
          .toList();
    }
    return items;
  }

  /// Returns unread alert count.
  Future<int> getUnreadCount() async {
    final alerts = await getAlerts();
    return alerts.where((a) => !a.isRead).length;
  }

  /// Marks an individual alert as read.
  Future<bool> markAsRead(String alertId) async {
    final prefs = await _getPrefs();
    final readIds = (prefs.getStringList(_readAlertsKey) ?? <String>[]).toSet();
    readIds.add(alertId);
    await prefs.setStringList(_readAlertsKey, readIds.toList());
    if (apiClient != null && !alertId.startsWith('alert-')) {
      try {
        await apiClient!.patch(
          '/notifications/$alertId/read',
          const <String, dynamic>{},
        );
      } catch (e) {
        debugPrint('[AlertsService] Could not sync read state: $e');
      }
    }
    return true;
  }

  /// Marks all alerts as read.
  Future<bool> markAllAsRead() async {
    final prefs = await _getPrefs();
    final all = await getAlerts();
    final allIds = all.map((a) => a.id).toList();
    return prefs.setStringList(_readAlertsKey, allIds);
  }
}
