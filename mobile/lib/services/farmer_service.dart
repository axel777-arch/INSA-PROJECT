import '../models/crop_model.dart';
import '../models/farmer_model.dart';
import 'api_client.dart';

class FarmerService {
  final ApiClient apiClient;

  FarmerService({required this.apiClient});

  // In-memory mock "directory". Static so every screen that constructs a
  // FarmerService shares the same data until a real API client replaces this.
  static final List<FarmerModel> _directory = [
    FarmerModel(
      id: '1',
      userId: 'u1',
      fullName: 'Elias Thorne',
      phone: '+251911000001',
      gender: 'Male',
      region: 'Oromia',
      zone: 'East Shewa',
      woreda: 'Adama',
      kebele: '02',
      alertEnabled: true,
      active: true,
      cropIds: ['wheat'],
    ),
    FarmerModel(
      id: '2',
      userId: 'u2',
      fullName: 'Sarah Jenkins',
      phone: '+251911000002',
      gender: 'Female',
      region: 'Amhara',
      zone: 'North Shewa',
      woreda: 'Debre Birhan',
      kebele: '05',
      alertEnabled: true,
      active: true,
      cropIds: ['maize'],
    ),
    FarmerModel(
      id: '3',
      userId: 'u3',
      fullName: 'Marcus Reyes',
      phone: '+251911000003',
      gender: 'Male',
      region: 'SNNPR',
      zone: 'Sidama',
      woreda: 'Hawassa Zuria',
      kebele: '01',
      alertEnabled: false,
      active: false,
      cropIds: ['soybeans'],
    ),
  ];

  static final List<CropModel> _crops = [
    CropModel(id: 'wheat', name: 'Wheat', description: 'Cereal crop', active: true),
    CropModel(id: 'maize', name: 'Maize', description: 'Cereal crop', active: true),
    CropModel(id: 'soybeans', name: 'Soybeans', description: 'Legume crop', active: true),
    CropModel(id: 'teff', name: 'Teff', description: 'Cereal crop', active: true),
    CropModel(id: 'barley', name: 'Barley', description: 'Cereal crop', active: true),
  ];

  /// Returns the mock farmer directory, optionally filtered by a free-text
  /// [query] (matches name, region, woreda, phone), by [cropId], or [region].
  Future<List<FarmerModel>> getFarmers({String? query, String? cropId, String? region}) async {
    // API endpoint: GET /api/farmers
    var results = List<FarmerModel>.from(_directory);

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

  Future<FarmerModel?> getFarmerProfile(String id) async {
    // API endpoint: GET /api/farmers/:id
    try {
      return _directory.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Registers a new farmer from the RegisterFarmerFlow stepper and adds
  /// them to the mock directory so they immediately show up in
  /// FarmerManagementScreen.
  Future<FarmerModel> registerFarmer(FarmerModel farmer) async {
    // API endpoint: POST /api/farmers
    final newFarmer = farmer.copyWith();
    _directory.insert(0, newFarmer);
    return newFarmer;
  }

  Future<FarmerModel?> updateFarmerProfile(String id, Map<String, dynamic> data) async {
    // API endpoint: PATCH /api/farmers/:id
    final index = _directory.indexWhere((f) => f.id == id);
    if (index == -1) return null;

    final updated = _directory[index].copyWith(
      fullName: data['full_name'],
      phone: data['phone'],
      gender: data['gender'],
      region: data['region'],
      zone: data['zone'],
      woreda: data['woreda'],
      kebele: data['kebele'],
      alertEnabled: data['alert_enabled'],
      active: data['active'],
      cropIds: data['crop_ids'] != null ? List<String>.from(data['crop_ids']) : null,
    );
    _directory[index] = updated;
    return updated;
  }

  Future<List<CropModel>> getCrops() async {
    // API endpoint: GET /api/crops
    return List<CropModel>.from(_crops);
  }

  Future<bool> assignCropsToFarmer(String farmerId, List<String> cropIds) async {
    // API endpoint: POST /api/farmers/:id/crops
    final index = _directory.indexWhere((f) => f.id == farmerId);
    if (index == -1) return false;
    _directory[index] = _directory[index].copyWith(cropIds: cropIds);
    return true;
  }
}
