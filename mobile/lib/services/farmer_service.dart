import 'package:flutter/foundation.dart';
import '../models/crop_model.dart';
import '../models/farmer_model.dart';
import 'api_client.dart';

/// FarmerService â€” communicates with the real backend.
class FarmerService {
  final ApiClient apiClient;

  FarmerService({required this.apiClient});

  // â”€â”€ Farmer CRUD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// GET /api/farmers â€” list farmers, optionally filter client-side.
  Future<List<FarmerModel>> getFarmers({
    String? query,
    String? cropId,
    String? region,
  }) async {
    debugPrint('[FarmerService] GET /farmers');

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
    debugPrint('[FarmerService] GET /farmers/$id');

    final response = await apiClient.get('/farmers/$id');

    if (response == null) return null;

    return FarmerModel.fromJson(response as Map<String, dynamic>);
  }

  /// GET /api/farmers/user/:userId
  Future<FarmerModel?> getFarmerByUserId(String userId) async {
    debugPrint('[FarmerService] GET /farmers/user/$userId');

    try {
      final response = await apiClient.get('/farmers/user/$userId');

      if (response == null) return null;

      return FarmerModel.fromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// POST /api/farmers — creates a farmer profile without requiring an app account.
  Future<FarmerModel> registerFarmer({
    required String fullName,
    required String phone,
    required String region,
    required String zone,
    required String woreda,
    required String kebele,
    bool alertEnabled = true,
    double? latitude,
    double? longitude,
  }) async {
    debugPrint('[FarmerService] POST /farmers (fullName=$fullName)');

    final body = <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'alertEnabled': alertEnabled,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await apiClient.post('/farmers', body);

    return FarmerModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/farmers/:farmerId/assignments
  ///
  /// Assigns the farmer to an extension worker.
  /// The authenticated user is recorded by the backend as assignedBy.
  Future<Map<String, dynamic>> assignFarmerToWorker({
    required String farmerId,
    required String workerId,
    String? note,
  }) async {
    debugPrint(
      '[FarmerService] POST /farmers/$farmerId/assignments '
      '(workerId=$workerId)',
    );

    final body = <String, dynamic>{
      'workerId': workerId,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    };

    final response = await apiClient.post(
      '/farmers/$farmerId/assignments',
      body,
    );

    if (response is Map<String, dynamic>) {
      // Backend assignment handler returns { data: assignment }.
      final data = response['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    throw ApiException('The server returned an invalid farmer assignment.');
  }

  /// PATCH /api/farmers/:id
  Future<FarmerModel?> updateFarmerProfile(
    String id,
    Map<String, dynamic> data,
  ) async {
    debugPrint('[FarmerService] PATCH /farmers/$id');

    final response = await apiClient.patch('/farmers/$id', data);

    if (response == null) return null;

    return FarmerModel.fromJson(response as Map<String, dynamic>);
  }

  // â”€â”€ Crops â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// GET /api/crops
  Future<List<CropModel>> getCrops() async {
    debugPrint('[FarmerService] GET /crops');

    final response = await apiClient.get('/crops');

    if (response == null) return [];

    final list = response as List<dynamic>;

    return list
        .map((item) => CropModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/farmers/:id/crops
  Future<bool> assignCropToFarmer(String farmerId, String cropId) async {
    debugPrint(
      '[FarmerService] POST /farmers/$farmerId/crops (cropId=$cropId)',
    );

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
    debugPrint('[FarmerService] GET /farmers/$farmerId/crops');

    final response = await apiClient.get('/farmers/$farmerId/crops');

    if (response == null) return [];

    return (response as List<dynamic>)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }
}
