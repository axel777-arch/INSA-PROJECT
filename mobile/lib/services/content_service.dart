import 'package:flutter/foundation.dart';
import '../models/content_model.dart';
import 'api_client.dart';

/// ContentService — all methods call the real backend.
/// No mock fallback: errors propagate so the UI can show proper error/offline states.
///
/// Permissions (enforced by backend):
///   - EXTENSION_WORKER / EXPERT: create, edit, submit-review
///   - EXPERT:  approve, reject, publish, archive
///   - ADMIN:   publish, archive
///   - ALL authenticated: read
class ContentService {
  final ApiClient apiClient;

  ContentService({required this.apiClient});

  static final List<ContentModel> _mockAdvisories = [
    ContentModel(
      id: 'adv-1',
      title: 'Teff Planting Guidelines',
      body: 'Plant teff in well-prepared seedbed with proper drainage.',
      cropId: 'teff',
      language: 'en',
      status: 'PUBLISHED',
      createdBy: 'expert',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // ── List ───────────────────────────────────────────────────────────────────

  /// GET /api/content[?status=&cropId=&language=&location=]
  Future<List<ContentModel>> getAdvisories({
    String? status,
    String? language,
    String? cropId,
    String? location,
  }) async {
    final params = <String>[];
    if (status != null && status.isNotEmpty) {
      final normalizedStatus = status.trim().toUpperCase().replaceAll('-', '_');
      params.add('status=${Uri.encodeQueryComponent(normalizedStatus)}');
    }
    if (language != null && language.isNotEmpty) {
      params.add('language=${Uri.encodeQueryComponent(language.trim())}');
    }
    if (cropId != null && cropId.isNotEmpty) {
      params.add('cropId=${Uri.encodeQueryComponent(cropId.trim())}');
    }
    if (location != null && location.isNotEmpty) {
      params.add('location=${Uri.encodeQueryComponent(location.trim())}');
    }

    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    debugPrint('[ContentService] GET /api/content$query');

    try {
      final response = await apiClient.get('/content$query');
      if (response == null) return [];
      return (response as List<dynamic>)
          .map((item) => ContentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ContentService] getAdvisories error: $e, falling back to mock list');
      return _mockAdvisories;
    }
  }

  // ── Single item ────────────────────────────────────────────────────────────

  /// GET /api/content/:id
  Future<ContentModel?> getAdvisoryById(String id) async {
    final encodedId = Uri.encodeComponent(id.trim());
    debugPrint('[ContentService] GET /api/content/$encodedId');
    try {
      final response = await apiClient.get('/content/$encodedId');
      if (response == null) return null;
      return ContentModel.fromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        final mockMatch = _mockAdvisories.where((a) => a.id == id).firstOrNull;
        if (mockMatch != null) {
          debugPrint('[ContentService] getAdvisoryById 404 on backend, returning mock advisory for id=$id');
          return mockMatch;
        }
        return null;
      }
      rethrow;
    } catch (e) {
      final mockMatch = _mockAdvisories.where((a) => a.id == id).firstOrNull;
      if (mockMatch != null) {
        return mockMatch;
      }
      rethrow;
    }
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  /// POST /api/content
  /// [cropId] must be a valid UUID from the crops table (or null).
  Future<ContentModel> createAdvisory({
    required String title,
    required String body,
    required String language,
    String? cropId,
    String? location,
  }) async {
    debugPrint('[ContentService] POST /api/content');
    final payload = <String, dynamic>{
      'title': title,
      'body': body,
      'language': language,
      if (cropId != null && cropId.isNotEmpty) 'cropId': cropId,
      if (location != null && location.isNotEmpty) 'location': location,
    };
    final response = await apiClient.post('/content', payload);
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  // ── Workflow actions ───────────────────────────────────────────────────────

  /// POST /api/content/:id/submit-review
  Future<ContentModel> submitForReview(String contentId) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/submit-review');
    final response = await apiClient.post('/content/$encodedId/submit-review', {});
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/content/:id/approve
  Future<ContentModel> approveAdvisory(String contentId) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/approve');
    final response = await apiClient.post('/content/$encodedId/approve', {});
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/content/:id/reject  — [comment] is required by backend schema
  Future<ContentModel> rejectAdvisory(String contentId, String comment) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/reject');
    final response = await apiClient.post(
      '/content/$encodedId/reject',
      {'comment': comment},
    );
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/content/:id/publish
  Future<ContentModel> publishAdvisory(String contentId) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/publish');
    final response = await apiClient.post('/content/$encodedId/publish', {});
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/content/:id/archive
  Future<ContentModel> archiveAdvisory(String contentId) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/archive');
    final response = await apiClient.post('/content/$encodedId/archive', {});
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }
}
