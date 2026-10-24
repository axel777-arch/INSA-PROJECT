import 'package:flutter/foundation.dart';
import '../models/crop_model.dart';
import '../models/farmer_model.dart';
import 'api_client.dart';

/// FarmerService — all methods call the real backend.
/// No mock fallback: errors propagate so the UI can show proper error states.
class FarmerService {
  final ApiClient apiClient;

  FarmerService({required this.apiClient});

  // ── Farmer CRUD ────────────────────────────────────────────────────────────

  /// GET /api/farmers — list farmers scoped to worker (or all for admin).
  Future<List<FarmerModel>> getFarmers({
    String? query,
    String? cropId,
    String? region,
  }) async {
    debugPrint('[FarmerService] GET /api/farmers');
    final response = await apiClient.get('/farmers');
    final list = (response as List<dynamic>)
        .map((data) => FarmerModel.fromJson(data as Map<String, dynamic>))
        .toList();

    var results = list;

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((f) {
        return f.fullName.toLowerCase().contains(q) ||
            f.region.toLowerCase().contains(q) ||
            f.woreda.toLowerCase().contains(q) ||
            f.phone.toLowerCase().contains(q);
      }).toList();
    }

    if (cropId != null && cropId.isNotEmpty && cropId.toLowerCase() != 'all') {
      results = results.where((f) => f.cropIds.contains(cropId)).toList();
    }

    if (region != null && region.isNotEmpty && region.toLowerCase() != 'all') {
      results = results.where((f) => f.region == region).toList();
    }

    return results;
  }

  /// GET /api/farmers/:id
  Future<FarmerModel?> getFarmerProfile(String id) async {
    debugPrint('[FarmerService] GET /api/farmers/$id');
    final response = await apiClient.get('/farmers/$id');
    if (response == null) return null;
    return FarmerModel.fromJson(response as Map<String, dynamic>);
  }

  /// GET /api/farmers/user/:userId
  Future<FarmerModel?> getFarmerByUserId(String userId) async {
    debugPrint('[FarmerService] GET /api/farmers/user/$userId');
    try {
      final response = await apiClient.get('/farmers/user/$userId');
      if (response == null) return null;
      return FarmerModel.fromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// POST /api/farmers — registers a new farmer securely.
  /// Supports both basic-phone farmers and farmers requesting mobile app access.
  Future<FarmerModel> registerFarmer({
    required String fullName,
    required String phone,
    String preferredLanguage = 'amharic',
    bool createAppAccount = false,
    String? userId,
    double? farmSize,
    double? experienceYears,
    required String region,
    required String zone,
    required String woreda,
    required String kebele,
    bool alertEnabled = true,
    double? latitude,
    double? longitude,
    List<String>? cropIds,
  }) async {
    debugPrint('[FarmerService] POST /api/farmers (createAppAccount=$createAppAccount)');
    final body = <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
      'preferredLanguage': preferredLanguage,
      'createAppAccount': createAppAccount,
      if (userId != null) 'userId': userId,
      if (farmSize != null) 'farmSize': farmSize,
      if (experienceYears != null) 'experienceYears': experienceYears,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'alertEnabled': alertEnabled,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (cropIds != null && cropIds.isNotEmpty) 'cropIds': cropIds,
    };
    final response = await apiClient.post('/farmers', body);
    return FarmerModel.fromJson(response as Map<String, dynamic>);
  }

  /// PATCH /api/farmers/:id
  Future<FarmerModel?> updateFarmerProfile(
    String id,
    Map<String, dynamic> data,
  ) async {
    debugPrint('[FarmerService] PATCH /api/farmers/$id');
    final response = await apiClient.patch('/farmers/$id', data);
    if (response == null) return null;
    return FarmerModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/farmers/:id/assign
  Future<Map<String, dynamic>> assignFarmer({
    required String farmerId,
    required String workerId,
    String assignmentType = 'PRIMARY',
    String? reason,
    String? endDate,
  }) async {
    debugPrint('[FarmerService] POST /api/farmers/$farmerId/assign');
    final response = await apiClient.post('/farmers/$farmerId/assign', {
      'workerId': workerId,
      'assignmentType': assignmentType,
      if (reason != null) 'reason': reason,
      if (endDate != null) 'endDate': endDate,
    });
    return response as Map<String, dynamic>;
  }

  /// GET /api/farmers/:id/assignments
  Future<List<Map<String, dynamic>>> getFarmerAssignments(String farmerId) async {
    debugPrint('[FarmerService] GET /api/farmers/$farmerId/assignments');
    final response = await apiClient.get('/farmers/$farmerId/assignments');
    if (response == null) return [];
    return (response as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
  }

  // ── Crops ──────────────────────────────────────────────────────────────────

  /// GET /api/crops
  Future<List<CropModel>> getCrops() async {
    debugPrint('[FarmerService] GET /api/crops');
    try {
      final response = await apiClient.get('/crops');
      if (response == null) return [];
      final list = response as List<dynamic>;
      return list
          .map((item) => CropModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[FarmerService] getCrops error: $e');
      return [];
    }
  }

  /// POST /api/farmers/:id/crops — assign a single crop to a farmer.
  Future<bool> assignCropToFarmer(String farmerId, String cropId) async {
    debugPrint('[FarmerService] POST /api/farmers/$farmerId/crops (cropId=$cropId)');
    try {
      await apiClient.post('/farmers/$farmerId/crops', {'cropId': cropId});
      return true;
    } catch (e) {
      debugPrint('[FarmerService] assignCropToFarmer error: $e');
      return false;
    }
  }

  /// GET /api/farmers/:id/crops
  Future<List<Map<String, dynamic>>> getFarmerCrops(String farmerId) async {
    debugPrint('[FarmerService] GET /api/farmers/$farmerId/crops');
    try {
      final response = await apiClient.get('/farmers/$farmerId/crops');
      if (response == null) return [];
      return (response as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('[FarmerService] getFarmerCrops error: $e');
      return [];
    }
  }
}
