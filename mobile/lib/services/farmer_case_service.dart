import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer_case_model.dart';
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

    // Validate attachment file types
    for (final path in finalAttachments) {
      final ext = path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
        throw ArgumentError(
          'Invalid file format: .$ext. Only JPEG, PNG, and PDF files are allowed.',
        );
      }
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

    // Save locally
    final prefs = await _getPrefs();
    final existing = await getCases(farmerId: farmerId);
    existing.insert(0, newCase);

    final rawJson = jsonEncode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, rawJson);

    // Try posting to backend if available
    if (apiClient != null) {
      try {
        dynamic res;
        try {
          res = await apiClient!.post('/farmers/cases', newCase.toJson());
        } catch (_) {
          res = await apiClient!.post('/cases', newCase.toJson());
        }
        if (res is Map<String, dynamic>) {
          return FarmerCaseModel.fromJson(res);
        }
      } catch (e) {
        debugPrint('[FarmerCaseService] Backend case sync notice: $e (saved locally)');
      }
    }

    return newCase;
  }

  /// Gets all submitted cases for a farmer.
  Future<List<FarmerCaseModel>> getCases({String? farmerId}) async {
    if (apiClient != null) {
      try {
        dynamic res;
        try {
          res = await apiClient!.get('/farmers/cases');
        } catch (_) {
          res = await apiClient!.get('/cases');
        }
        if (res is List && res.isNotEmpty) {
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
        debugPrint('[FarmerCaseService] Backend case fetch note: $e');
      }
    }

    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final cases = decoded
            .map((e) => FarmerCaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (farmerId != null && farmerId.isNotEmpty) {
          return cases.where((c) => c.farmerId == farmerId || c.farmerId.isEmpty).toList();
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
    final list = await getCases();
    return list.where((c) => c.id == caseId).firstOrNull;
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
}
