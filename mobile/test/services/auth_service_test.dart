import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockApiClient mockApiClient;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockApiClient = MockApiClient();
      authService = AuthService(apiClient: mockApiClient);
    });

    test('login sets token and user on success', () async {
      when(mockApiClient.post('/auth/login', any)).thenAnswer((_) async => {
        'accessToken': 'test_token',
        'user': {
          'id': '1',
          'full_name': 'Test User',
          'phone': '1234567890',
          'role': 'farmer',
          'preferred_language': 'en'
        }
      });

      final success = await authService.login('user', 'password');

      expect(success, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser?.fullName, 'Test User');
      verify(mockApiClient.updateToken('test_token')).called(1);
    });

    test('login returns false on failure', () async {
      when(mockApiClient.post('/auth/login', any)).thenThrow(ApiException('Invalid credentials'));

      final success = await authService.login('user', 'wrong');

      expect(success, isFalse);
      expect(authService.isAuthenticated, isFalse);
    });

    test('logout clears user and token', () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'existing_token'});
      when(mockApiClient.post('/auth/logout', any)).thenAnswer((_) async => {});

      await authService.logout();

      expect(authService.isAuthenticated, isFalse);
      verify(mockApiClient.updateToken(null)).called(1);
    });
  });
}
