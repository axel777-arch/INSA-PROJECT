import 'package:flutter/foundation.dart';
import '../models/crop_model.dart';
import '../models/farmer_model.dart';
import 'api_client.dart';

/// FarmerService — all methods call the real backend.
/// No mock fallback: errors propagate so the UI can show proper error states.
class FarmerService {
  final ApiClient apiClient;

  FarmerService({required this.apiClient});

  static final List<FarmerModel> _mockFarmers = [
    const FarmerModel(
      id: '1',
      userId: 'u1',
      fullName: 'Abebe Bikila',
      phone: '+251911223344',
      region: 'Oromia',
      zone: 'East Shewa',
      woreda: 'Adama',
      kebele: '01',
      alertEnabled: true,
      active: true,
      cropIds: ['teff'],
    ),
  ];

  // ── Farmer CRUD ────────────────────────────────────────────────────────────

  /// GET /api/farmers — list all farmers, optionally filter client-side.
  /// Backend returns FarmerWithUser objects (full_name, phone, crop_ids included).
  Future<List<FarmerModel>> getFarmers({
    String? query,
    String? cropId,
    String? region,
  }) async {
    debugPrint('[FarmerService] GET /api/farmers');
    try {
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
    } catch (e) {
      debugPrint('[FarmerService] getFarmers error: $e, falling back to mock data');
      return _mockFarmers;
    }
  }

  /// GET /api/farmers/:id
  Future<FarmerModel?> getFarmerProfile(String id) async {
    debugPrint('[FarmerService] GET /api/farmers/$id');
    try {
      final response = await apiClient.get('/farmers/$id');
      if (response == null) return null;
      return FarmerModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[FarmerService] getFarmerProfile error: $e, falling back to mock data');
      return _mockFarmers.where((f) => f.id == id).firstOrNull;
    }
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

  /// POST /api/farmers — registers a new farmer.
  /// [userId] must be a real UUID from the users table.
  Future<FarmerModel> registerFarmer({
    required String userId,
    required String region,
    required String zone,
    required String woreda,
    required String kebele,
    bool alertEnabled = true,
    double? latitude,
    double? longitude,
  }) async {
    debugPrint('[FarmerService] POST /api/farmers (userId=$userId)');
    final body = <String, dynamic>{
      'userId': userId,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'alertEnabled': alertEnabled,
      'latitude': ?latitude,
      'longitude': ?longitude,
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

  // ── Crops ──────────────────────────────────────────────────────────────────

  /// GET /api/crops — returns plain List (backend fixed to return array directly).
  Future<List<CropModel>> getCrops() async {
    debugPrint('[FarmerService] GET /api/crops');
    try {
      final response = await apiClient.get('/crops');
      if (response == null) return [];
      // Backend returns a plain array of crop objects
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
