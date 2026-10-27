import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer_case_model.dart';
import '../models/case_message_model.dart';
import 'api_client.dart';

/// FarmerCaseService
/// Manages "Ask an Extension Worker" case submissions, photo attachment validations,
/// and canonical case lifecycle tracking:
/// OPEN -> ASSIGNED -> IN_PROGRESS -> WAITING_FOR_INFORMATION -> ESCALATED -> RESOLVED -> CLOSED
class FarmerCaseService {
  static const String _storageKey = 'farmer_submitted_cases';

  final ApiClient? apiClient;
  final SharedPreferences? _prefs;

  FarmerCaseService({this.apiClient, SharedPreferences? prefs})
    : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  static final List<FarmerCaseModel> _defaultSeedCases = [
    FarmerCaseModel(
      id: 'case-8492-b',
      farmerId: 'farmer-01',
      farmerName: 'Abebe Bikila',
      farmerPhone: '+251911223344',
      subject: 'Rapid yellow striping on lower maize leaves',
      description:
          'Over the last 48 hours, lesions are elongating quickly upward. Overnight temperatures remain above 20°C with high humidity.',
      cropName: 'Maize',
      location: 'Oromia / East Shewa / Adama Plot 3',
      attachmentPaths: const ['maize_lesion_field_photo.jpg'],
      status: 'RESOLVED',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      assignedWorkerName: 'Sarah Jenkins (Extension Worker Level 2)',
      responseNotes:
          'Diagnosis: Confirmed Northern Corn Leaf Blight (Exserohilum turcicum). Recommendation: Apply recommended mancozeb fungicide spray immediately before dew sets in. Ensure lower infected leaves are pruned and safely buried.',
      responseDate: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    FarmerCaseModel(
      id: 'case-9104-c',
      farmerId: 'farmer-01',
      farmerName: 'Abebe Bikila',
      farmerPhone: '+251911223344',
      subject: 'Inquiry on Teff sowing depth with dry seedbed',
      description:
          'Should I pack the soil before or after scattering Teff seed in light sandy loam soil?',
      cropName: 'Teff',
      location: 'Oromia / East Shewa / Adama Plot 1',
      attachmentPaths: const [],
      status: 'IN_PROGRESS',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      assignedWorkerName: 'Dawit Bekele (DA Agro-Officer)',
      responseNotes:
          'Preliminary advice: Ensure soil is lightly rolled before broadcasting. DA Dawit is scheduled to visit your plot tomorrow morning.',
      responseDate: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  /// Submits a new question / case to the extension worker.
  /// Validates allowed attachment formats: JPEG, PNG, PDF per Part 1 Rule 2.
  Future<FarmerCaseModel> submitCase({
    String farmerId = 'farmer-01',
    String farmerName = 'Farmer',
    String farmerPhone = '',
    required String subject,
    required String description,
    String? cropName,
    String? crop,
    required String location,
    List<String>? attachmentPaths,
    List<String>? attachments,
    String? urgency,
  }) async {
    final finalCrop = cropName ?? crop ?? 'General Crop';
    final finalAttachments = attachmentPaths ?? attachments ?? const <String>[];

    if (finalAttachments.length > 5) {
      throw ArgumentError('A case can include at most five attachments.');
    }

    var totalAttachmentBytes = 0;
    for (final path in finalAttachments) {
      final ext = _attachmentExtension(path);
      if (!['jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
        throw ArgumentError(
          'Invalid file format: .$ext. Only JPEG, PNG, and PDF files are allowed.',
        );
      }
      totalAttachmentBytes += _attachmentByteLength(path);
    }
    if (totalAttachmentBytes > 4 * 1024 * 1024) {
      throw ArgumentError('Case attachments must total no more than 4 MB.');
    }

    final newCase = FarmerCaseModel(
      id: 'case-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: farmerId,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      subject: subject,
      description: description,
      cropName: finalCrop,
      location: location,
      attachmentPaths: finalAttachments,
      status: 'OPEN',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    var submittedCase = newCase;
    if (apiClient != null) {
      final response = await apiClient!.post('/cases', {
        'title': subject,
        'description': description,
        'category': finalCrop,
        'location': location,
        'priority': _backendPriority(urgency),
        'source': 'FARMER_INQUIRY',
        'attachments': finalAttachments,
      });
      if (response is! Map<String, dynamic>) {
        throw const FormatException(
          'The server returned an invalid case record.',
        );
      }
      submittedCase = FarmerCaseModel.fromJson(response);
    }

    final prefs = await _getPrefs();
    final existing = await _readLocalCases(prefs);
    existing.removeWhere((item) => item.id == submittedCase.id);
    existing.insert(0, submittedCase);
    await prefs.setString(
      _storageKey,
      jsonEncode(existing.map((item) => item.toJson()).toList()),
    );
    return submittedCase;
  }

  /// Gets all submitted cases for a farmer.
  Future<List<FarmerCaseModel>> getCases({
    String? farmerId,
    bool useLocalFallback = true,
  }) async {
    if (apiClient != null) {
      try {
        final res = await apiClient!.get('/cases');
        if (res is List) {
          final items = res
              .map((e) => FarmerCaseModel.fromJson(e as Map<String, dynamic>))
              .toList();
          if (farmerId != null && farmerId.isNotEmpty) {
            return items
                .where((c) => c.farmerId == farmerId || c.farmerId.isEmpty)
                .toList();
          }
          return items;
        }
      } catch (e) {
        if (!useLocalFallback) rethrow;
        debugPrint('[FarmerCaseService] Backend case fetch note: $e');
      }
    }

    if (!useLocalFallback) {
      throw StateError('Cases could not be loaded from the server.');
    }

    try {
      final cases = await _readLocalCases(await _getPrefs());
      if (cases.isNotEmpty) {
        if (farmerId != null && farmerId.isNotEmpty) {
          return cases
              .where((c) => c.farmerId == farmerId || c.farmerId.isEmpty)
              .toList();
        }
        return cases;
      }
    } catch (e) {
      debugPrint('[FarmerCaseService] Error reading local cases: $e');
    }

    return List<FarmerCaseModel>.from(_defaultSeedCases);
  }

  /// Gets a specific case by ID.
  Future<FarmerCaseModel?> getCaseById(String caseId) async {
    if (apiClient != null) {
      final response = await apiClient!.get(
        '/cases/${Uri.encodeComponent(caseId)}',
      );
      if (response == null) return null;
      return FarmerCaseModel.fromJson(response as Map<String, dynamic>);
    }
    final list = await getCases();
    return list.where((c) => c.id == caseId).firstOrNull;
  }

  Future<List<CaseMessageModel>> getCaseMessages(String caseId) async {
    final thread = await getCaseThread(caseId);
    return thread?.messages ?? [];
  }

  Future<({FarmerCaseModel caseRecord, List<CaseMessageModel> messages})?>
  getCaseThread(String caseId) async {
    if (apiClient == null) return null;
    final response = await apiClient!.get(
      '/cases/${Uri.encodeComponent(caseId)}',
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'The server returned an invalid case record.',
      );
    }
    final messages = response['messages'];
    return (
      caseRecord: FarmerCaseModel.fromJson(response),
      messages: messages is List
          ? messages
                .whereType<Map<String, dynamic>>()
                .map(CaseMessageModel.fromJson)
                .toList()
          : <CaseMessageModel>[],
    );
  }

  Future<CaseMessageModel> sendCaseMessage({
    required String caseId,
    required String body,
    String visibility = 'INTERNAL',
  }) async {
    if (apiClient == null) {
      throw StateError('Case messaging requires a server connection.');
    }
    final response = await apiClient!.post(
      '/cases/${Uri.encodeComponent(caseId)}/messages',
      {'body': body.trim(), 'visibility': visibility},
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'The server returned an invalid case message.',
      );
    }
    return CaseMessageModel.fromJson(response);
  }

  Future<FarmerCaseModel> updateCaseStatus({
    required String caseId,
    required String status,
    String? details,
  }) async {
    if (apiClient == null) {
      throw StateError('Case status updates require a server connection.');
    }
    final response = await apiClient!.patch(
      '/cases/${Uri.encodeComponent(caseId)}/status',
      {'status': status, 'summary': ?details},
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'The server returned an invalid case record.',
      );
    }
    return FarmerCaseModel.fromJson(response);
  }

  Future<FarmerCaseModel> requestCaseInformation({
    required String caseId,
    required String message,
  }) async {
    if (apiClient == null) {
      throw StateError(
        'Case information requests require a server connection.',
      );
    }
    final response = await apiClient!.post(
      '/cases/${Uri.encodeComponent(caseId)}/request-information',
      {'message': message.trim()},
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'The server returned an invalid case record.',
      );
    }
    return FarmerCaseModel.fromJson(response);
  }

  Future<FarmerCaseModel> escalateCase({
    required String caseId,
    String? reason,
  }) async {
    if (apiClient == null) {
      throw StateError('Case escalation requires a server connection.');
    }
    final response = await apiClient!.post(
      '/cases/${Uri.encodeComponent(caseId)}/escalate',
      {'reason': ?reason},
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'The server returned an invalid case record.',
      );
    }
    return FarmerCaseModel.fromJson(response);
  }

  /// Updates status or adds response to an existing case.
  Future<bool> updateCase(FarmerCaseModel updated) async {
    final prefs = await _getPrefs();
    final list = await getCases();
    final idx = list.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      list[idx] = updated;
    } else {
      list.insert(0, updated);
    }
    final rawJson = jsonEncode(list.map((e) => e.toJson()).toList());
    return prefs.setString(_storageKey, rawJson);
  }

  Future<List<FarmerCaseModel>> _readLocalCases(SharedPreferences prefs) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((value) => FarmerCaseModel.fromJson(value as Map<String, dynamic>))
        .toList();
  }

  String _backendPriority(String? urgency) {
    switch (urgency?.toUpperCase()) {
      case 'LOW':
        return 'LOW';
      case 'HIGH':
        return 'HIGH';
      case 'URGENT':
        return 'URGENT';
      default:
        return 'NORMAL';
    }
  }

  String _attachmentExtension(String attachment) {
    final dataUri = RegExp(
      r'^data:([^;,]+)(?:;name=([^;,]+))?;base64,',
    ).firstMatch(attachment);
    if (dataUri != null) {
      final name = dataUri.group(2);
      if (name != null) {
        return Uri.decodeComponent(name).split('.').last.toLowerCase();
      }
      switch (dataUri.group(1)?.toLowerCase()) {
        case 'image/jpeg':
          return 'jpg';
        case 'image/png':
          return 'png';
        case 'application/pdf':
          return 'pdf';
      }
      return '';
    }
    return attachment.split('.').last.toLowerCase();
  }

  int _attachmentByteLength(String attachment) {
    final dataUri = RegExp(
      r'^data:[^,]+;base64,(.*)$',
      dotAll: true,
    ).firstMatch(attachment);
    if (dataUri == null) return 0;
    try {
      return base64Decode(dataUri.group(1)!).length;
    } on FormatException {
      throw ArgumentError('An attachment has invalid encoded data.');
    }
  }
}
