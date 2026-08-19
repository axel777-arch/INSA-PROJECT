class FarmerModel {
  final String id;
  final String userId;
  final String region;
  final String zone;
  final String woreda;
  final String kebele;
  final bool alertEnabled;
  final List<String> cropIds;

  FarmerModel({
    required this.id,
    required this.userId,
    required this.region,
    required this.zone,
    required this.woreda,
    required this.kebele,
    required this.alertEnabled,
    required this.cropIds,
  });

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      region: json['region'] ?? '',
      zone: json['zone'] ?? '',
      woreda: json['woreda'] ?? '',
      kebele: json['kebele'] ?? '',
      alertEnabled: json['alert_enabled'] ?? true,
      cropIds: List<String>.from(json['crop_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'alert_enabled': alertEnabled,
      'crop_ids': cropIds,
    };
  }
}
