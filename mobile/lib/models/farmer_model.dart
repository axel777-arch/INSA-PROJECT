class FarmerModel {
  final String id;
  final String? userId;
  final String fullName;
  final String phone;
  final String preferredLanguage;
  final bool hasAppAccess;
  final double? farmSize;
  final double? experienceYears;
  final String region;
  final String zone;
  final String woreda;
  final String kebele;
  final String? primaryWorkerId;
  final bool alertEnabled;
  final bool active;
  final List<String> cropIds;
  final double? latitude;
  final double? longitude;
  final String? temporaryPassword;

  const FarmerModel({
    required this.id,
    this.userId,
    this.fullName = '',
    this.phone = '',
    this.preferredLanguage = 'amharic',
    this.hasAppAccess = false,
    this.farmSize,
    this.experienceYears,
    required this.region,
    required this.zone,
    required this.woreda,
    required this.kebele,
    this.primaryWorkerId,
    required this.alertEnabled,
    this.active = true,
    required this.cropIds,
    this.latitude,
    this.longitude,
    this.temporaryPassword,
  });

  /// Backend returns snake_case keys
  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      preferredLanguage: json['preferred_language'] as String? ?? 'amharic',
      hasAppAccess: json['has_app_access'] as bool? ?? false,
      farmSize: (json['farm_size'] as num?)?.toDouble(),
      experienceYears: (json['experience_years'] as num?)?.toDouble(),
      region: json['region'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      woreda: json['woreda'] as String? ?? '',
      kebele: json['kebele'] as String? ?? '',
      primaryWorkerId: json['primary_worker_id'] as String?,
      alertEnabled: json['alert_enabled'] as bool? ?? true,
      active: json['active'] as bool? ?? true,
      cropIds: (json['crop_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      temporaryPassword: json['temporaryPassword'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'preferred_language': preferredLanguage,
      'has_app_access': hasAppAccess,
      if (farmSize != null) 'farm_size': farmSize,
      if (experienceYears != null) 'experience_years': experienceYears,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      if (primaryWorkerId != null) 'primary_worker_id': primaryWorkerId,
      'alert_enabled': alertEnabled,
      'active': active,
      'crop_ids': cropIds,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (temporaryPassword != null) 'temporaryPassword': temporaryPassword,
    };
  }

  FarmerModel copyWith({
    String? fullName,
    String? phone,
    String? preferredLanguage,
    bool? hasAppAccess,
    double? farmSize,
    double? experienceYears,
    String? region,
    String? zone,
    String? woreda,
    String? kebele,
    String? primaryWorkerId,
    bool? alertEnabled,
    bool? active,
    List<String>? cropIds,
    double? latitude,
    double? longitude,
    String? temporaryPassword,
  }) {
    return FarmerModel(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      hasAppAccess: hasAppAccess ?? this.hasAppAccess,
      farmSize: farmSize ?? this.farmSize,
      experienceYears: experienceYears ?? this.experienceYears,
      region: region ?? this.region,
      zone: zone ?? this.zone,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      primaryWorkerId: primaryWorkerId ?? this.primaryWorkerId,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      active: active ?? this.active,
      cropIds: cropIds ?? this.cropIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temporaryPassword: temporaryPassword ?? this.temporaryPassword,
    );
  }
}
