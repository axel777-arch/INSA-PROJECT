import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/messaging_service.dart';

import 'content_service_test.mocks.dart';

void main() {
  group('MessagingService', () {
    late MockApiClient apiClient;
    late MessagingService service;

    setUp(() {
      apiClient = MockApiClient();
      service = MessagingService(apiClient: apiClient);
    });

    test('returns the actual SMS simulator response', () async {
      when(
        apiClient.post('/messaging/sms', any),
      ).thenAnswer((_) async => {'id': 'sms-1', 'status': 'QUEUED'});

      final result = await service.sendSmsSimulation(
        recipient: '+251900000001',
        message: 'Test message',
        contentId: 'content-1',
        createdBy: 'user-1',
      );

      expect(result['id'], 'sms-1');
      expect(result['status'], 'QUEUED');
    });

    test(
      'propagates SMS API failures without returning a fake queued message',
      () {
        when(
          apiClient.post('/messaging/sms', any),
        ).thenThrow(ApiException('Simulator unavailable'));

        expect(
          service.sendSmsSimulation(
            recipient: '+251900000001',
            message: 'Test message',
            contentId: 'content-1',
            createdBy: 'user-1',
          ),
          throwsA(isA<ApiException>()),
        );
      },
    );
  });
}
