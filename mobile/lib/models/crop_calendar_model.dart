class CropCalendarModel {
  final String id;
  final String cropName;
  final String region;
  final String agroecologicalZone;
  final String season;
  final String stage;
  final String recommendedTask;
  final String timePeriod;
  final String importance;
  bool isCompleted;

  CropCalendarModel({
    required this.id,
    required this.cropName,
    required this.region,
    required this.agroecologicalZone,
    required this.season,
    required this.stage,
    required this.recommendedTask,
    required this.timePeriod,
    this.importance = 'High',
    this.isCompleted = false,
  });

  String get crop => cropName;

  factory CropCalendarModel.fromJson(Map<String, dynamic> json) {
    return CropCalendarModel(
      id: json['id'] as String? ?? 'cal-${DateTime.now().millisecondsSinceEpoch}',
      cropName: json['cropName'] as String? ?? 'Crop',
      region: json['region'] as String? ?? 'All Regions',
      agroecologicalZone: json['agroecologicalZone'] as String? ?? 'Weyna Dega',
      season: json['season'] as String? ?? 'Meher',
      stage: json['stage'] as String? ?? 'General Care',
      recommendedTask: json['recommendedTask'] as String? ?? 'Perform standard farm maintenance.',
      timePeriod: json['timePeriod'] as String? ?? 'Current Season',
      importance: json['importance'] as String? ?? 'High',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cropName': cropName,
    'region': region,
    'agroecologicalZone': agroecologicalZone,
    'season': season,
    'stage': stage,
    'recommendedTask': recommendedTask,
    'timePeriod': timePeriod,
    'importance': importance,
    'isCompleted': isCompleted,
  };
}
