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
      when(mockApiClient.get('/content')).thenAnswer((_) async => [
        {
          'id': 'api-adv-1',
          'title': 'API Title',
          'summary': 'Short digest',
          'body': 'API Body',
          'cropId': 'api-crop',
          'category': 'Agronomy',
          'language': 'en',
          'priority': 'NORMAL',
          'status': 'PUBLISHED',
          'createdBy': 'API User',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        }
      ]);

      final advisories = await contentService.getAdvisories();

      expect(advisories.length, 1);
      expect(advisories.first.id, 'api-adv-1');
      expect(advisories.first.summary, 'Short digest');
      verify(mockApiClient.get('/content')).called(1);
    });

    test('getAdvisories throws ApiException on failure without fake mock data', () async {
      when(mockApiClient.get('/content')).thenThrow(ApiException('Network Error'));

      expect(
        () => contentService.getAdvisories(),
        throwsA(isA<ApiException>()),
      );
      verify(mockApiClient.get('/content')).called(1);
    });

    test('createAdvisory posts rich fields to API', () async {
      when(mockApiClient.post('/content', any)).thenAnswer((_) async => {
        'id': 'new-adv-1',
        'title': 'New Title',
        'summary': 'New Summary',
        'body': 'New Body',
        'cropId': 'corn',
        'category': 'Agronomy',
        'language': 'en',
        'region': 'Amhara',
        'priority': 'HIGH',
        'version': 1,
        'status': 'DRAFT',
        'createdBy': 'Author',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final newAdvisory = await contentService.createAdvisory(
        title: 'New Title',
        summary: 'New Summary',
        body: 'New Body',
        cropId: 'corn',
        category: 'Agronomy',
        language: 'en',
        region: 'Amhara',
        priority: 'HIGH',
      );

      expect(newAdvisory.id, 'new-adv-1');
      expect(newAdvisory.title, 'New Title');
      expect(newAdvisory.priority, 'HIGH');
      expect(newAdvisory.version, 1);
    });

    test('requestRevision posts to /content/:id/request-revision', () async {
      when(mockApiClient.post('/content/adv-1/request-revision', {'comment': 'Provide dosage'}))
          .thenAnswer((_) async => {
                'id': 'adv-1',
                'title': 'Test',
                'body': 'Body',
                'language': 'en',
                'status': 'NEEDS_REVISION',
                'createdBy': 'Author',
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              });

      final result = await contentService.requestRevision('adv-1', 'Provide dosage');
      expect(result.status, 'NEEDS_REVISION');
      expect(result.isNeedsRevision, isTrue);
    });

    test('archiveAdvisory posts to /content/:id/archive', () async {
      when(mockApiClient.post('/content/adv-1/archive', {'reason': 'End of season'}))
          .thenAnswer((_) async => {
                'id': 'adv-1',
                'title': 'Test',
                'body': 'Body',
                'language': 'en',
                'status': 'ARCHIVED',
                'createdBy': 'Author',
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              });

      final result = await contentService.archiveAdvisory('adv-1', reason: 'End of season');
      expect(result.status, 'ARCHIVED');
      expect(result.isArchived, isTrue);
    });

    test('getContentVersions fetches version history list', () async {
      when(mockApiClient.get('/content/adv-1/versions')).thenAnswer((_) async => [
        {
          'id': 'ver-1',
          'contentId': 'adv-1',
          'versionNumber': 2,
          'title': 'v2 Title',
          'body': 'v2 Body',
          'language': 'en',
          'statusAtVersion': 'PENDING_REVIEW',
          'changeSummary': 'Fixed dosage',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'ver-0',
          'contentId': 'adv-1',
          'versionNumber': 1,
          'title': 'v1 Title',
          'body': 'v1 Body',
          'language': 'en',
          'statusAtVersion': 'DRAFT',
          'changeSummary': 'Initial draft',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ]);

      final versions = await contentService.getContentVersions('adv-1');
      expect(versions.length, 2);
      expect(versions.first.versionNumber, 2);
      expect(versions.first.changeSummary, 'Fixed dosage');
    });

    test('getContentReviews fetches review trail', () async {
      when(mockApiClient.get('/content/adv-1/reviews')).thenAnswer((_) async => [
        {
          'id': 'rev-1',
          'contentId': 'adv-1',
          'reviewerId': 'exp-1',
          'status': 'NEEDS_REVISION',
          'comments': 'Please revise treatment timing',
          'reviewedAt': DateTime.now().toIso8601String(),
          'reviewerName': 'Dr. Kebede',
          'reviewerRole': 'EXPERT',
        }
      ]);

      final reviews = await contentService.getContentReviews('adv-1');
      expect(reviews.length, 1);
      expect(reviews.first.status, 'NEEDS_REVISION');
      expect(reviews.first.reviewerName, 'Dr. Kebede');
      expect(reviews.first.comments, 'Please revise treatment timing');
    });
  });
}
