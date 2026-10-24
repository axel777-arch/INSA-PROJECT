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

  /// Fetches alerts from backend or benchmark records, integrating read/unread flags.
  Future<List<NotificationItemModel>> getAlerts({String? category}) async {
    final prefs = await _getPrefs();
    final readIds = (prefs.getStringList(_readAlertsKey) ?? []).toSet();

    var items = <NotificationItemModel>[];

    // Try backend messaging records first
    if (apiClient != null) {
      try {
        dynamic res;
        try {
          res = await apiClient!.get('/messaging');
        } catch (_) {
          res = await apiClient!.get('/alerts');
        }
        if (res is List && res.isNotEmpty) {
          for (final raw in res) {
            final map = raw as Map<String, dynamic>;
            items.add(
              NotificationItemModel(
                id: map['id']?.toString() ??
                    'msg-${DateTime.now().millisecondsSinceEpoch}',
                title: map['title']?.toString() ??
                    'Official Advisory Notification',
                body: map['body']?.toString() ?? '',
                category: map['category']?.toString() ?? 'ADVISORY',
                severity: map['severity']?.toString() ?? 'MEDIUM',
                channel: map['channel']?.toString() ?? 'SMS',
                createdAt: map['createdAt'] != null
                    ? DateTime.tryParse(map['createdAt'].toString()) ??
                        DateTime.now()
                    : DateTime.now(),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('[AlertsService] Backend alerts query note: $e');
      }
    }

    if (items.isEmpty) {
      items = List<NotificationItemModel>.from(_benchmarkAlerts);
    }

    // Apply read state
    for (final item in items) {
      if (readIds.contains(item.id)) {
        item.isRead = true;
      }
    }

    if (category != null && category.isNotEmpty && category != 'ALL') {
      items = items.where((i) => i.category.toUpperCase() == category.toUpperCase()).toList();
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
    final readIds = (prefs.getStringList(_readAlertsKey) ?? []).toSet();
    readIds.add(alertId);
    return prefs.setStringList(_readAlertsKey, readIds.toList());
  }

  /// Marks all alerts as read.
  Future<bool> markAllAsRead() async {
    final prefs = await _getPrefs();
    final all = await getAlerts();
    final allIds = all.map((a) => a.id).toList();
    return prefs.setStringList(_readAlertsKey, allIds);
  }
}
