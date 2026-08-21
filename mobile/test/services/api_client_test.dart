import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/services/api_client.dart';

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    setUp(() {
      ApiClient.clearInstance();
    });

    tearDown(() {
      ApiClient.clearInstance();
    });    test('GET request returns data on success', () async {
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
        return http.Response(jsonEncode({'error': {'message': 'Server Error'}}), 500);
      });

      apiClient = ApiClient(client: mockClient);

      expect(
        () async => await apiClient.get('/test'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Server Error')),
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
  });
}
