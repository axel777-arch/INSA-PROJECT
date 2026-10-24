import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/models/content_model.dart';
import 'package:mobile/services/offline_advisory_service.dart';

void main() {
  group('OfflineAdvisoryService Tests', () {
    late OfflineAdvisoryService offlineService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      offlineService = OfflineAdvisoryService();
    });

    test('saveAdvisory succeeds for PUBLISHED advisories', () async {
      final publishedAdv = ContentModel(
        id: 'adv-pub-1',
        title: 'Rust Management in Wheat',
        body: 'Apply registered fungicides early in the morning.',
        cropId: 'wheat',
        language: 'en',
        status: 'PUBLISHED',
        createdBy: 'Senior Agronomist',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await offlineService.saveAdvisory(publishedAdv);

      final isSaved = await offlineService.isAdvisorySaved('adv-pub-1');
      expect(isSaved, isTrue);

      final list = await offlineService.getSavedAdvisories();
      expect(list.length, 1);
      expect(list.first.advisory.id, 'adv-pub-1');
      expect(list.first.isStale, isFalse);
    });

    test('saveAdvisory throws StateError when attempting to cache non-PUBLISHED drafts', () async {
      final draftAdv = ContentModel(
        id: 'adv-draft-1',
        title: 'Unpublished Draft Advisory',
        body: 'Internal unapproved notes.',
        cropId: 'teff',
        language: 'en',
        status: 'DRAFT',
        createdBy: 'Field Officer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        () => offlineService.saveAdvisory(draftAdv),
        throwsA(isA<StateError>()),
      );

      final isSaved = await offlineService.isAdvisorySaved('adv-draft-1');
      expect(isSaved, isFalse);
    });

    test('saveAdvisory throws StateError when attempting to cache IN_REVIEW advisory', () async {
      final reviewAdv = ContentModel(
        id: 'adv-review-1',
        title: 'In Review Advisory',
        body: 'Pending expert signoff.',
        cropId: 'coffee',
        language: 'en',
        status: 'IN_REVIEW',
        createdBy: 'Field Officer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        () => offlineService.saveAdvisory(reviewAdv),
        throwsA(isA<StateError>()),
      );
    });

    test('removeAdvisory removes cached advisory', () async {
      final adv = ContentModel(
        id: 'adv-rem-1',
        title: 'Advisory to remove',
        body: 'Body',
        cropId: 'corn',
        language: 'en',
        status: 'PUBLISHED',
        createdBy: 'Officer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await offlineService.saveAdvisory(adv);
      expect(await offlineService.isAdvisorySaved('adv-rem-1'), isTrue);

      await offlineService.removeAdvisory('adv-rem-1');
      expect(await offlineService.isAdvisorySaved('adv-rem-1'), isFalse);
      expect((await offlineService.getSavedAdvisories()).isEmpty, isTrue);
    });

    test('stale detection correctly marks entries older than 14 days', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 15));
      final recentDate = DateTime.now().subtract(const Duration(days: 5));

      final staleItem = SavedAdvisoryItem(
        advisory: ContentModel(
          id: 'old',
          title: 'Old Advisory',
          body: '...',
          cropId: 'crop',
          language: 'en',
          status: 'PUBLISHED',
          createdBy: 'Officer',
          createdAt: oldDate,
          updatedAt: oldDate,
        ),
        savedAt: oldDate,
      );

      final freshItem = SavedAdvisoryItem(
        advisory: ContentModel(
          id: 'fresh',
          title: 'Fresh Advisory',
          body: '...',
          cropId: 'crop',
          language: 'en',
          status: 'PUBLISHED',
          createdBy: 'Officer',
          createdAt: recentDate,
          updatedAt: recentDate,
        ),
        savedAt: recentDate,
      );

      expect(staleItem.isStale, isTrue);
      expect(freshItem.isStale, isFalse);
    });

    test('clearAllSaved removes all cached items', () async {
      final adv1 = ContentModel(
        id: 'adv-1',
        title: 'Advisory 1',
        body: 'Body 1',
        cropId: 'wheat',
        language: 'en',
        status: 'PUBLISHED',
        createdBy: 'Officer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final adv2 = ContentModel(
        id: 'adv-2',
        title: 'Advisory 2',
        body: 'Body 2',
        cropId: 'teff',
        language: 'en',
        status: 'PUBLISHED',
        createdBy: 'Officer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await offlineService.saveAdvisory(adv1);
      await offlineService.saveAdvisory(adv2);
      expect((await offlineService.getSavedAdvisories()).length, 2);

      await offlineService.clearAllSaved();
      expect((await offlineService.getSavedAdvisories()).isEmpty, isTrue);
    });
  });
}
