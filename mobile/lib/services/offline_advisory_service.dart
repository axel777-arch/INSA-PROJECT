import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_model.dart';

class SavedAdvisoryItem {
  final ContentModel advisory;
  final DateTime cachedAt;

  DateTime get savedAt => cachedAt;

  SavedAdvisoryItem({
    required this.advisory,
    DateTime? cachedAt,
    DateTime? savedAt,
  }) : cachedAt = cachedAt ?? savedAt ?? DateTime.now();

  bool get isStale => DateTime.now().difference(cachedAt).inDays >= 14;

  String get cachedAgo {
    final diff = DateTime.now().difference(cachedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toJson() => {
        'advisory': advisory.toJson(),
        'cachedAt': cachedAt.toIso8601String(),
      };

  factory SavedAdvisoryItem.fromJson(Map<String, dynamic> json) {
    return SavedAdvisoryItem(
      advisory: ContentModel.fromJson(json['advisory'] as Map<String, dynamic>),
      cachedAt: json['cachedAt'] != null
          ? DateTime.tryParse(json['cachedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// OfflineAdvisoryService
/// Manages locally saved agricultural bulletins for offline reading.
/// Adheres strictly to the architectural rule:
/// "Never cache unapproved drafts (coordinate caching rules with Member 3)."
class OfflineAdvisoryService {
  static const String _storageKey = 'offline_saved_advisories';

  final SharedPreferences? _prefs;

  OfflineAdvisoryService({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Saves a published advisory locally for offline access.
  /// Rejects unapproved drafts immediately.
  Future<bool> saveAdvisory(ContentModel advisory) async {
    if (advisory.status.toUpperCase() != 'PUBLISHED') {
      debugPrint('[OfflineAdvisoryService] Rejecting non-published advisory caching: ${advisory.status}');
      throw StateError('Cannot cache unapproved drafts or non-published content offline.');
    }

    final prefs = await _getPrefs();
    final list = await getSavedAdvisories();

    // Remove existing if already present to update timestamp
    list.removeWhere((item) => item.advisory.id == advisory.id);

    list.insert(
      0,
      SavedAdvisoryItem(
        advisory: advisory,
        cachedAt: DateTime.now(),
      ),
    );

    final rawJson = jsonEncode(list.map((e) => e.toJson()).toList());
    return prefs.setString(_storageKey, rawJson);
  }

  /// Removes an advisory from offline storage.
  Future<bool> removeAdvisory(String contentId) async {
    final prefs = await _getPrefs();
    final list = await getSavedAdvisories();
    list.removeWhere((item) => item.advisory.id == contentId);
    final rawJson = jsonEncode(list.map((e) => e.toJson()).toList());
    return prefs.setString(_storageKey, rawJson);
  }

  /// Checks if an advisory is saved offline.
  Future<bool> isSaved(String contentId) async {
    final list = await getSavedAdvisories();
    return list.any((item) => item.advisory.id == contentId);
  }

  /// Returns all advisories saved offline.
  Future<List<SavedAdvisoryItem>> getSavedAdvisories() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => SavedAdvisoryItem.fromJson(item as Map<String, dynamic>))
          .where((item) => item.advisory.status.toUpperCase() == 'PUBLISHED')
          .toList();
    } catch (e) {
      debugPrint('[OfflineAdvisoryService] Error reading offline advisories: $e');
      return [];
    }
  }

  /// Clears all offline saved advisories.
  Future<bool> clearAll() async {
    final prefs = await _getPrefs();
    return prefs.remove(_storageKey);
  }

  /// Convenience aliases for backward compatibility and test ergonomics
  Future<bool> isAdvisorySaved(String contentId) => isSaved(contentId);
  Future<bool> clearAllSaved() => clearAll();
}
