import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/crop_calendar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CropCalendarService Tests', () {
    late CropCalendarService calendarService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      calendarService = CropCalendarService();
    });

    test('getCalendarEntries returns Ethiopian crop calendar items', () async {
      final entries = await calendarService.getCalendarEntries();

      expect(entries.isNotEmpty, isTrue);
      final crops = entries.map((e) => e.crop).toSet();
      expect(crops.contains('Teff'), isTrue);
      expect(crops.contains('Wheat'), isTrue);
      expect(crops.contains('Coffee'), isTrue);

      final entry = entries.first;
      expect(entry.agroecologicalZone.isNotEmpty, isTrue);
      expect(entry.season.isNotEmpty, isTrue);
      expect(entry.stage.isNotEmpty, isTrue);
      expect(entry.recommendedTask.isNotEmpty, isTrue);
      expect(entry.timePeriod.isNotEmpty, isTrue);
    });

    test('getCalendarEntries filters accurately by crop', () async {
      final teffEntries = await calendarService.getCalendarEntries(crop: 'Teff');
      expect(teffEntries.isNotEmpty, isTrue);
      expect(teffEntries.every((e) => e.crop == 'Teff'), isTrue);

      final coffeeEntries = await calendarService.getCalendarEntries(crop: 'Coffee');
      expect(coffeeEntries.isNotEmpty, isTrue);
      expect(coffeeEntries.every((e) => e.crop == 'Coffee'), isTrue);
    });

    test('getCalendarEntries filters accurately by season', () async {
      final meherEntries = await calendarService.getCalendarEntries(season: 'Meher');
      expect(meherEntries.isNotEmpty, isTrue);
      expect(meherEntries.every((e) => e.season.contains('Meher')), isTrue);

      final belgEntries = await calendarService.getCalendarEntries(season: 'Belg');
      expect(belgEntries.isNotEmpty, isTrue);
      expect(belgEntries.every((e) => e.season.contains('Belg')), isTrue);
    });

    test('toggleTaskCompletion accurately toggles and persists task completion', () async {
      const taskId = 'task-teff-landprep';

      expect(await calendarService.isTaskCompleted(taskId), isFalse);

      final newState1 = await calendarService.toggleTaskCompletion(taskId);
      expect(newState1, isTrue);
      expect(await calendarService.isTaskCompleted(taskId), isTrue);

      final newState2 = await calendarService.toggleTaskCompletion(taskId);
      expect(newState2, isFalse);
      expect(await calendarService.isTaskCompleted(taskId), isFalse);
    });

    test('getCropList and getSeasonList return expected categories', () async {
      final crops = await calendarService.getCropList();
      final seasons = await calendarService.getSeasonList();

      expect(crops.contains('Teff'), isTrue);
      expect(crops.contains('Wheat'), isTrue);
      expect(crops.contains('Maize'), isTrue);

      expect(seasons.contains('Meher'), isTrue);
      expect(seasons.contains('Belg'), isTrue);
      expect(seasons.contains('Bega'), isTrue);
    });
  });
}
