import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/models/farmer_model.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/farmer_service.dart';

import 'farmer_service_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('FarmerService Tests', () {
    late FarmerService farmerService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      farmerService = FarmerService(apiClient: mockApiClient);
    });

    test('getFarmers fetches from API', () async {
      when(mockApiClient.get('/farmers')).thenAnswer((_) async => [
        {
          'id': 'api-f-1',
          'user_id': 'u1',
          'full_name': 'API Farmer',
          'phone': '123456',
          'gender': 'Male',
          'region': 'Oromia',
          'zone': 'East Shewa',
          'woreda': 'Adama',
          'kebele': '02',
          'alert_enabled': true,
          'active': true,
          'crop_ids': ['wheat']
        }
      ]);

      final farmers = await farmerService.getFarmers();

      expect(farmers.isNotEmpty, isTrue);
      expect(farmers.first.id, 'api-f-1');
      verify(mockApiClient.get('/farmers')).called(1);
    });

    test('getFarmers falls back to mock data on API failure', () async {
      when(mockApiClient.get('/farmers')).thenThrow(ApiException('Network Error'));

      final farmers = await farmerService.getFarmers();

      expect(farmers.isNotEmpty, isTrue);
      expect(farmers.first.id, '1'); // Internal mock starts with id 1
      verify(mockApiClient.get('/farmers')).called(1);
    });

    test('registerFarmer posts to API', () async {
      when(mockApiClient.post('/farmers', any)).thenAnswer((_) async => {
        'id': 'api-new-1',
        'user_id': 'new-user',
        'full_name': 'New Farmer',
        'phone': '0000',
        'gender': 'Female',
        'region': 'SNNPR',
        'zone': 'Sidama',
        'woreda': 'Hawassa',
        'kebele': '01',
        'alert_enabled': true,
        'active': true,
        'crop_ids': []
      });

      final newFarmer = FarmerModel(
        id: 'temp',
        userId: 'temp',
        fullName: 'New Farmer',
        phone: '0000',
        gender: 'Female',
        region: 'SNNPR',
        zone: 'Sidama',
        woreda: 'Hawassa',
        kebele: '01',
        alertEnabled: true,
        active: true,
        cropIds: [],
      );

      final result = await farmerService.registerFarmer(newFarmer);

      expect(result.id, 'api-new-1');
      verify(mockApiClient.post('/farmers', any)).called(1);
    });
  });
}
