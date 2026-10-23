import 'package:flutter/foundation.dart';
import '../models/field_observation_model.dart';
import '../models/follow_up_model.dart';
import 'api_client.dart';

class ObservationService {
  final ApiClient apiClient;

  ObservationService({required this.apiClient});

  /// POST /api/observations
  Future<FieldObservationModel> createObservation({
    required String farmerId,
    String? cropId,
    String observationType = 'GENERAL_CHECKUP',
    String severity = 'LOW',
    required String title,
    required String description,
    String? actionTaken,
  }) async {
    debugPrint('[ObservationService] POST /api/observations');
    final body = <String, dynamic>{
      'farmerId': farmerId,
      if (cropId != null) 'cropId': cropId,
      'observationType': observationType,
      'severity': severity,
      'title': title,
      'description': description,
      if (actionTaken != null) 'actionTaken': actionTaken,
    };
    final response = await apiClient.post('/observations', body);
    final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return FieldObservationModel.fromJson(data);
  }

  /// GET /api/observations
  Future<List<FieldObservationModel>> getObservations({String? farmerId}) async {
    debugPrint('[ObservationService] GET /api/observations');
    final query = farmerId != null ? '?farmerId=$farmerId' : '';
    final response = await apiClient.get('/observations$query');
    if (response == null) return [];
    return (response as List<dynamic>)
        .map((e) => FieldObservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/observations/:id
  Future<FieldObservationModel?> getObservationById(String id) async {
    debugPrint('[ObservationService] GET /api/observations/$id');
    final response = await apiClient.get('/observations/$id');
    if (response == null) return null;
    return FieldObservationModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/observations/:id/escalate
  Future<FieldObservationModel> escalateObservation({
    required String observationId,
    required String expertId,
  }) async {
    debugPrint('[ObservationService] POST /api/observations/$observationId/escalate');
    final response = await apiClient.post('/observations/$observationId/escalate', {
      'escalatedToId': expertId,
    });
    final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return FieldObservationModel.fromJson(data);
  }

  /// POST /api/observations/:id/attachments
  Future<ObservationAttachmentModel> addAttachment({
    required String observationId,
    required String fileUrl,
    required String fileType,
    String? fileName,
  }) async {
    debugPrint('[ObservationService] POST /api/observations/$observationId/attachments');
    final response = await apiClient.post('/observations/$observationId/attachments', {
      'fileUrl': fileUrl,
      'fileType': fileType,
      if (fileName != null) 'fileName': fileName,
    });
    final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ObservationAttachmentModel.fromJson(data);
  }

  // ── Follow-Up Visits ───────────────────────────────────────────────────────

  /// POST /api/follow-ups
  Future<FollowUpModel> scheduleFollowUp({
    required String farmerId,
    String? observationId,
    required DateTime scheduledDate,
    String? notes,
  }) async {
    debugPrint('[ObservationService] POST /api/follow-ups');
    final body = <String, dynamic>{
      'farmerId': farmerId,
      if (observationId != null) 'observationId': observationId,
      'scheduledDate': scheduledDate.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
    final response = await apiClient.post('/follow-ups', body);
    final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return FollowUpModel.fromJson(data);
  }

  /// GET /api/follow-ups
  Future<List<FollowUpModel>> getFollowUps({String? farmerId, String? status}) async {
    debugPrint('[ObservationService] GET /api/follow-ups');
    final params = <String>[];
    if (farmerId != null) params.add('farmerId=$farmerId');
    if (status != null) params.add('status=$status');
    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    final response = await apiClient.get('/follow-ups$queryString');
    if (response == null) return [];
    return (response as List<dynamic>)
        .map((e) => FollowUpModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /api/follow-ups/:id
  Future<FollowUpModel> updateFollowUp({
    required String id,
    String? status,
    DateTime? completedDate,
    String? notes,
    String? outcome,
  }) async {
    debugPrint('[ObservationService] PATCH /api/follow-ups/$id');
    final body = <String, dynamic>{
      if (status != null) 'status': status,
      if (completedDate != null) 'completedDate': completedDate.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (outcome != null) 'outcome': outcome,
    };
    final response = await apiClient.patch('/follow-ups/$id', body);
    final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return FollowUpModel.fromJson(data);
  }
}
