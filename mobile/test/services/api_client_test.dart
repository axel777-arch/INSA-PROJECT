import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/services/api_client.dart';

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    setUp(() {
      ApiClient.clearInstance();
    });

    tearDown(() {
      ApiClient.clearInstance();
    });
    test('GET request returns data on success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/test') {
          return http.Response(jsonEncode({'data': 'success'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      apiClient = ApiClient(client: mockClient);

      final response = await apiClient.get('/test');
      expect(response['data'], 'success');
    });

    test('GET request throws ApiException on failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'Server Error'},
          }),
          500,
        );
      });

      apiClient = ApiClient(client: mockClient);

      expect(
        () async => await apiClient.get('/test'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Server Error',
          ),
        ),
      );
    });

    test('POST request sends body and receives response', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        if (body['key'] == 'value') {
          return http.Response(jsonEncode({'success': true}), 201);
        }
        return http.Response('Bad Request', 400);
      });

      apiClient = ApiClient(client: mockClient);

      final response = await apiClient.post('/test', {'key': 'value'});
      expect(response['success'], true);
    });

    test('authenticated requests send the bearer token', () async {
      final mockClient = MockClient((request) async {
        final authorization = request.headers.entries
            .singleWhere((entry) => entry.key.toLowerCase() == 'authorization')
            .value;
        expect(authorization, 'Bearer test_token');
        return http.Response(jsonEncode({'success': true}), 200);
      });

      apiClient = ApiClient(client: mockClient);
      apiClient.updateToken('test_token');

      await apiClient.get('/test');
    });

    test('ApiException preserves backend error codes', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'ACCOUNT_PENDING',
              'message': 'Your account is waiting for approval.',
            },
          }),
          403,
        );
      });

      apiClient = ApiClient(client: mockClient);

      await expectLater(
        apiClient.post('/auth/login', {
          'identifier': 'user',
          'password': 'secret',
        }),
        throwsA(
          isA<ApiException>()
              .having((error) => error.code, 'code', 'ACCOUNT_PENDING')
              .having((error) => error.statusCode, 'statusCode', 403),
        ),
      );
    });
  });
}
