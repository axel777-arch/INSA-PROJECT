import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/content_service.dart';

import 'content_service_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('ContentService Tests', () {
    late ContentService contentService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      contentService = ContentService(apiClient: mockApiClient);
    });

    test('getAdvisories fetches from API', () async {
      when(mockApiClient.get('/content')).thenAnswer(
        (_) async => [
          {
            'id': 'api-adv-1',
            'title': 'API Title',
            'body': 'API Body',
            'cropId': 'api-crop',
            'language': 'en',
            'status': 'PUBLISHED',
            'createdBy': 'API User',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        ],
      );

      final advisories = await contentService.getAdvisories();

      expect(advisories.length, 1);
      expect(advisories.first.id, 'api-adv-1');
      verify(mockApiClient.get('/content')).called(1);
    });

    test(
      'getAdvisories surfaces API failures instead of returning fake content',
      () async {
        when(
          mockApiClient.get('/content'),
        ).thenThrow(ApiException('Network Error'));

        await expectLater(
          contentService.getAdvisories(),
          throwsA(isA<ApiException>()),
        );
        verify(mockApiClient.get('/content')).called(1);
      },
    );

    test('getAdvisories supports an author filter for worker drafts', () async {
      when(
        mockApiClient.get('/content?status=DRAFT&authorId=user-1'),
      ).thenAnswer((_) async => []);

      expect(
        await contentService.getAdvisories(status: 'DRAFT', authorId: 'user-1'),
        isEmpty,
      );
      verify(
        mockApiClient.get('/content?status=DRAFT&authorId=user-1'),
      ).called(1);
    });

    test('createAdvisory posts to API', () async {
      when(mockApiClient.post('/content', any)).thenAnswer(
        (_) async => {
          'id': 'new-adv-1',
          'title': 'New Title',
          'body': 'New Body',
          'cropId': 'corn',
          'language': 'en',
          'status': 'DRAFT',
          'createdBy': 'Author',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      final newAdvisory = await contentService.createAdvisory(
        title: 'New Title',
        body: 'New Body',
        language: 'en',
      );

      expect(newAdvisory.id, 'new-adv-1');
      expect(newAdvisory.title, 'New Title');
    });
  });
}
