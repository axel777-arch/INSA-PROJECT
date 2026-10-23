import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop_calendar_model.dart';

class CropCalendarService {
  static const String _completedTasksKey = 'crop_calendar_completed_tasks';

  final SharedPreferences? _prefs;

  CropCalendarService({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  static final List<CropCalendarModel> _masterCalendar = [
    CropCalendarModel(
      id: 'cal-teff-01',
      cropName: 'Teff',
      region: 'Oromia / Amhara',
      agroecologicalZone: 'Weyna Dega (Mid-altitude)',
      season: 'Meher (Main Season)',
      stage: 'Land Preparation',
      recommendedTask: 'Plow field 3 to 4 times to achieve fine, firm seedbed. Ensure adequate drainage furrow construction to prevent waterlogging.',
      timePeriod: 'May - Early July',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-teff-02',
      cropName: 'Teff',
      region: 'Oromia / Amhara',
      agroecologicalZone: 'Weyna Dega (Mid-altitude)',
      season: 'Meher (Main Season)',
      stage: 'Sowing / Planting',
      recommendedTask: 'Broadcast or row-plant certified seed (10-15 kg/ha) mixed with sand. Apply basal NPS fertilizer during planting.',
      timePeriod: 'Mid July - Early August',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-teff-03',
      cropName: 'Teff',
      region: 'Oromia / Amhara',
      agroecologicalZone: 'Weyna Dega (Mid-altitude)',
      season: 'Meher (Main Season)',
      stage: 'Weeding & Top-Dressing',
      recommendedTask: 'Hand weed 25-30 days after emergence. Apply Urea top-dressing fertilizer immediately after weeding during moist conditions.',
      timePeriod: 'August - September',
      importance: 'High',
    ),
    CropCalendarModel(
      id: 'cal-teff-04',
      cropName: 'Teff',
      region: 'Oromia / Amhara',
      agroecologicalZone: 'Weyna Dega (Mid-altitude)',
      season: 'Meher (Main Season)',
      stage: 'Harvesting & Threshing',
      recommendedTask: 'Harvest when panicles turn straw-yellow. Dry sheafs on field platform and thresh promptly to minimize shatter loss.',
      timePeriod: 'November - December',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-wheat-01',
      cropName: 'Wheat',
      region: 'Oromia / Amhara / Tigray',
      agroecologicalZone: 'Dega (Highlands)',
      season: 'Meher (Main Season)',
      stage: 'Land Preparation & Sowing',
      recommendedTask: 'Deep plow and harrow to control perennial grass weeds. Sow treated seed resistant to yellow/stripe rust.',
      timePeriod: 'June - Early July',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-wheat-02',
      cropName: 'Wheat',
      region: 'Oromia / Amhara / Tigray',
      agroecologicalZone: 'Dega (Highlands)',
      season: 'Meher (Main Season)',
      stage: 'Pest & Disease Monitoring',
      recommendedTask: 'Scout weekly for yellow and stem rust pustules on leaf underside. Contact extension agent immediately if spore dust is visible.',
      timePeriod: 'August - September',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-wheat-03',
      cropName: 'Wheat',
      region: 'Oromia / Amhara / Tigray',
      agroecologicalZone: 'Dega (Highlands)',
      season: 'Meher (Main Season)',
      stage: 'Harvesting',
      recommendedTask: 'Harvest at 14% grain moisture. Store in elevated bins or clean hermetic PICS bags to protect against weevils.',
      timePeriod: 'October - November',
      importance: 'High',
    ),
    CropCalendarModel(
      id: 'cal-maize-01',
      cropName: 'Maize',
      region: 'Oromia / Sidama / SNNPR',
      agroecologicalZone: 'Weyna Dega & Kolla',
      season: 'Meher (Main Season)',
      stage: 'Land Preparation & Planting',
      recommendedTask: 'Incorporate organic manure during primary tillage. Row-plant with 75 cm between rows and 25-30 cm between plants.',
      timePeriod: 'April - May',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-maize-02',
      cropName: 'Maize',
      region: 'Oromia / Sidama / SNNPR',
      agroecologicalZone: 'Weyna Dega & Kolla',
      season: 'Meher (Main Season)',
      stage: 'Fall Armyworm Scouting & Weeding',
      recommendedTask: 'Inspect whorl leaves twice weekly for pinhole damage caused by Fall Armyworm larvae. Apply bio-pesticide or recommended agent.',
      timePeriod: 'June - July',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-maize-03',
      cropName: 'Maize',
      region: 'Oromia / Sidama / SNNPR',
      agroecologicalZone: 'Weyna Dega & Kolla',
      season: 'Meher (Main Season)',
      stage: 'Tasseling & Moisture Management',
      recommendedTask: 'Ensure soil moisture is adequate during pollination and ear filling. Top-dress second split of nitrogen fertilizer.',
      timePeriod: 'August - September',
      importance: 'High',
    ),
    CropCalendarModel(
      id: 'cal-coffee-01',
      cropName: 'Coffee',
      region: 'Sidama / Oromia / Southwest',
      agroecologicalZone: 'Weyna Dega (Forest/Semi-Forest)',
      season: 'Meher (Main Season)',
      stage: 'Canopy Pruning & Mulching',
      recommendedTask: 'Prune dead and diseased branches. Mulch coffee tree bases with dry grass leaving 10 cm stem clearance to preserve soil moisture.',
      timePeriod: 'January - March',
      importance: 'High',
    ),
    CropCalendarModel(
      id: 'cal-coffee-02',
      cropName: 'Coffee',
      region: 'Sidama / Oromia / Southwest',
      agroecologicalZone: 'Weyna Dega (Forest/Semi-Forest)',
      season: 'Meher (Main Season)',
      stage: 'Selective Cherry Picking',
      recommendedTask: 'Handpick only uniform bright-red ripe cherries. Avoid green or overripe cherries to ensure highest cup quality and price premium.',
      timePeriod: 'October - December',
      importance: 'Critical',
    ),
    CropCalendarModel(
      id: 'cal-barley-01',
      cropName: 'Barley',
      region: 'Amhara / Oromia',
      agroecologicalZone: 'Dega (Highlands > 2400m)',
      season: 'Belg (Short Rains)',
      stage: 'Belg Sowing',
      recommendedTask: 'Take advantage of Belg precipitation. Sow fast-maturing food barley cultivars in well-drained upper slopes.',
      timePeriod: 'March - April',
      importance: 'High',
    ),
  ];

  /// Fetches calendar entries filtered by crop, season, or agroecological zone.
  Future<List<CropCalendarModel>> getCalendarEntries({
    String? crop,
    String? cropName,
    String? season,
    String? agroecologicalZone,
    String? query,
  }) async {
    final effectiveCrop = crop ?? cropName;
    final prefs = await _getPrefs();
    final completedSet = (prefs.getStringList(_completedTasksKey) ?? []).toSet();

    var list = _masterCalendar.map((item) {
      return CropCalendarModel(
        id: item.id,
        cropName: item.cropName,
        region: item.region,
        agroecologicalZone: item.agroecologicalZone,
        season: item.season,
        stage: item.stage,
        recommendedTask: item.recommendedTask,
        timePeriod: item.timePeriod,
        importance: item.importance,
        isCompleted: completedSet.contains(item.id),
      );
    }).toList();

    if (effectiveCrop != null && effectiveCrop.isNotEmpty && effectiveCrop != 'All') {
      list = list.where((i) => i.cropName.toLowerCase().contains(effectiveCrop.toLowerCase())).toList();
    }

    if (season != null && season.isNotEmpty && season != 'All') {
      list = list.where((i) => i.season.toLowerCase().contains(season.toLowerCase())).toList();
    }

    if (agroecologicalZone != null && agroecologicalZone.isNotEmpty && agroecologicalZone != 'All') {
      list = list
          .where((i) => i.agroecologicalZone.toLowerCase().contains(agroecologicalZone.toLowerCase()))
          .toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((i) {
        return i.cropName.toLowerCase().contains(q) ||
            i.stage.toLowerCase().contains(q) ||
            i.recommendedTask.toLowerCase().contains(q) ||
            i.region.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  /// Checks if a calendar task is marked complete.
  Future<bool> isTaskCompleted(String taskId) async {
    try {
      final prefs = await _getPrefs();
      final set = (prefs.getStringList(_completedTasksKey) ?? []).toSet();
      return set.contains(taskId);
    } catch (_) {
      return false;
    }
  }

  /// Toggles task completion state and persists it. Returns new state.
  Future<bool> toggleTaskCompletion(String taskId, [bool? isCompleted]) async {
    try {
      final prefs = await _getPrefs();
      final set = (prefs.getStringList(_completedTasksKey) ?? []).toSet();
      final target = isCompleted ?? !set.contains(taskId);
      if (target) {
        set.add(taskId);
      } else {
        set.remove(taskId);
      }
      await prefs.setStringList(_completedTasksKey, set.toList());
      return target;
    } catch (e) {
      debugPrint('[CropCalendarService] Error saving task state: $e');
      return false;
    }
  }

  /// Returns unique sorted crop names in calendar
  Future<List<String>> getCropList() async {
    final entries = await getCalendarEntries();
    final set = <String>{};
    for (final e in entries) {
      set.add(e.cropName);
    }
    return set.toList()..sort();
  }

  /// Returns available seasons
  Future<List<String>> getSeasonList() async {
    return ['Meher', 'Belg', 'Bega'];
  }
}
