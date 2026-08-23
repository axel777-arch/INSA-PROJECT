class FarmerModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String region;
  final String zone;
  final String woreda;
  final String kebele;
  final bool alertEnabled;
  final bool active;
  final List<String> cropIds;
  final double? latitude;
  final double? longitude;

  const FarmerModel({
    required this.id,
    required this.userId,
    this.fullName = '',
    this.phone = '',
    required this.region,
    required this.zone,
    required this.woreda,
    required this.kebele,
    required this.alertEnabled,
    this.active = true,
    required this.cropIds,
    this.latitude,
    this.longitude,
  });

  /// Backend returns snake_case keys: id, user_id, full_name, phone,
  /// region, zone, woreda, kebele, alert_enabled, active, crop_ids
  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      region: json['region'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      woreda: json['woreda'] as String? ?? '',
      kebele: json['kebele'] as String? ?? '',
      alertEnabled: json['alert_enabled'] as bool? ?? true,
      active: json['active'] as bool? ?? true,
      cropIds: (json['crop_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'alert_enabled': alertEnabled,
      'active': active,
      'crop_ids': cropIds,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  FarmerModel copyWith({
    String? fullName,
    String? phone,
    String? region,
    String? zone,
    String? woreda,
    String? kebele,
    bool? alertEnabled,
    bool? active,
    List<String>? cropIds,
    double? latitude,
    double? longitude,
  }) {
    return FarmerModel(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      region: region ?? this.region,
      zone: zone ?? this.zone,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      active: active ?? this.active,
      cropIds: cropIds ?? this.cropIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
