import 'package:flutter/foundation.dart';
import '../models/content_model.dart';
import 'api_client.dart';

/// ContentService — all methods communicate with the backend API.
/// No mock fallback is used; API errors propagate so that screens can
/// render accurate loading, error, empty, and offline states.
class ContentService {
  final ApiClient apiClient;

  ContentService({required this.apiClient});

  // ── List Advisories ────────────────────────────────────────────────────────

  /// GET /api/content[?status=&cropId=&language=&region=&search=&authorId=&includeArchived=]
  Future<List<ContentModel>> getAdvisories({
    String? status,
    String? language,
    String? cropId,
    String? category,
    String? region,
    String? search,
    String? authorId,
    bool? includeArchived,
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
    if (category != null && category.isNotEmpty) {
      params.add('category=${Uri.encodeQueryComponent(category.trim())}');
    }
    if (region != null && region.isNotEmpty) {
      params.add('region=${Uri.encodeQueryComponent(region.trim())}');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (authorId != null && authorId.isNotEmpty) {
      params.add('authorId=${Uri.encodeQueryComponent(authorId.trim())}');
    }
    if (includeArchived != null) {
      params.add('includeArchived=$includeArchived');
    }

    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    debugPrint('[ContentService] GET /api/content$query');

    final response = await apiClient.get('/content$query');
    if (response == null) return [];
    return (response as List<dynamic>)
        .map((item) => ContentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ── Single Advisory ────────────────────────────────────────────────────────

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
        return null;
      }
      rethrow;
    }
  }

  // ── Create Advisory ────────────────────────────────────────────────────────

  /// POST /api/content
  Future<ContentModel> createAdvisory({
    required String title,
    String? summary,
    required String body,
    String? cropId,
    String? category,
    String language = 'en',
    String? region,
    String? zone,
    String? woreda,
    String? kebele,
    String? season,
    String? cropStage,
    String priority = 'NORMAL',
    DateTime? validFrom,
    DateTime? validUntil,
    String? sourceInfo,
    String? attachments,
    String? location, // legacy fallback for region
  }) async {
    debugPrint('[ContentService] POST /api/content');
    final payload = <String, dynamic>{
      'title': title,
      if (summary != null && summary.isNotEmpty) 'summary': summary,
      'body': body,
      if (cropId != null && cropId.isNotEmpty) 'cropId': cropId,
      if (category != null && category.isNotEmpty) 'category': category,
      'language': language,
      if ((region ?? location) != null && (region ?? location)!.isNotEmpty)
        'region': region ?? location,
      if (zone != null && zone.isNotEmpty) 'zone': zone,
      if (woreda != null && woreda.isNotEmpty) 'woreda': woreda,
      if (kebele != null && kebele.isNotEmpty) 'kebele': kebele,
      if (season != null && season.isNotEmpty) 'season': season,
      if (cropStage != null && cropStage.isNotEmpty) 'cropStage': cropStage,
      'priority': priority,
      if (validFrom != null) 'validFrom': validFrom.toIso8601String(),
      if (validUntil != null) 'validUntil': validUntil.toIso8601String(),
      if (sourceInfo != null && sourceInfo.isNotEmpty) 'sourceInfo': sourceInfo,
      if (attachments != null && attachments.isNotEmpty) 'attachments': attachments,
    };

    final response = await apiClient.post('/content', payload);
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  // ── Update Advisory ────────────────────────────────────────────────────────

  /// PATCH /api/content/:id
  Future<ContentModel> updateAdvisory(
    String contentId, {
    String? title,
    String? summary,
    String? body,
    String? cropId,
    String? category,
    String? language,
    String? region,
    String? zone,
    String? woreda,
    String? kebele,
    String? season,
    String? cropStage,
    String? priority,
    DateTime? validFrom,
    DateTime? validUntil,
    String? sourceInfo,
    String? attachments,
    String? changeSummary,
  }) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] PATCH /api/content/$encodedId');
    final payload = <String, dynamic>{
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (body != null) 'body': body,
      if (cropId != null) 'cropId': cropId,
      if (category != null) 'category': category,
      if (language != null) 'language': language,
      if (region != null) 'region': region,
      if (zone != null) 'zone': zone,
      if (woreda != null) 'woreda': woreda,
      if (kebele != null) 'kebele': kebele,
      if (season != null) 'season': season,
      if (cropStage != null) 'cropStage': cropStage,
      if (priority != null) 'priority': priority,
      if (validFrom != null) 'validFrom': validFrom.toIso8601String(),
      if (validUntil != null) 'validUntil': validUntil.toIso8601String(),
      if (sourceInfo != null) 'sourceInfo': sourceInfo,
      if (attachments != null) 'attachments': attachments,
      if (changeSummary != null) 'changeSummary': changeSummary,
    };

    final response = await apiClient.patch('/content/$encodedId', payload);
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  // ── Workflow Actions ───────────────────────────────────────────────────────

  /// POST /api/content/:id/submit-review
  Future<ContentModel> submitForReview(String contentId) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/submit-review');
    final response = await apiClient.post('/content/$encodedId/submit-review', {});
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/content/:id/approve
  Future<ContentModel> approveAdvisory(String contentId, {String? comment}) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/approve');
    final payload = <String, dynamic>{
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final response = await apiClient.post('/content/$encodedId/approve', payload);
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/content/:id/request-revision
  Future<ContentModel> requestRevision(String contentId, String comment) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/request-revision');
    final response = await apiClient.post(
      '/content/$encodedId/request-revision',
      {'comment': comment},
    );
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/content/:id/reject
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
  Future<ContentModel> archiveAdvisory(String contentId, {String? reason}) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] POST /api/content/$encodedId/archive');
    final payload = <String, dynamic>{
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };
    final response = await apiClient.post('/content/$encodedId/archive', payload);
    return ContentModel.fromJson(response as Map<String, dynamic>);
  }

  // ── Version & Review History ───────────────────────────────────────────────

  /// GET /api/content/:id/versions
  Future<List<ContentVersionModel>> getContentVersions(String contentId) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] GET /api/content/$encodedId/versions');
    final response = await apiClient.get('/content/$encodedId/versions');
    if (response == null) return [];
    return (response as List<dynamic>)
        .map((item) => ContentVersionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/content/:id/reviews
  Future<List<ContentReviewModel>> getContentReviews(String contentId) async {
    final encodedId = Uri.encodeComponent(contentId.trim());
    debugPrint('[ContentService] GET /api/content/$encodedId/reviews');
    final response = await apiClient.get('/content/$encodedId/reviews');
    if (response == null) return [];
    return (response as List<dynamic>)
        .map((item) => ContentReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
