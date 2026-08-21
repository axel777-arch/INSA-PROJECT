class FarmerModel {
  final String id;
  final String userId;
  // Display fields carried on the farmer record for the mock/offline directory.
  // In a real backend these would be joined in from UserModel, but the
  // extension worker flows need them available locally without a join.
  final String fullName;
  final String phone;
  final String gender;
  final String region;
  final String zone;
  final String woreda;
  final String kebele;
  final bool alertEnabled;
  final bool active;
  final List<String> cropIds;

  FarmerModel({
    required this.id,
    required this.userId,
    this.fullName = '',
    this.phone = '',
    this.gender = 'Other',
    required this.region,
    required this.zone,
    required this.woreda,
    required this.kebele,
    required this.alertEnabled,
    this.active = true,
    required this.cropIds,
  });

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'Other',
      region: json['region'] ?? '',
      zone: json['zone'] ?? '',
      woreda: json['woreda'] ?? '',
      kebele: json['kebele'] ?? '',
      alertEnabled: json['alert_enabled'] ?? true,
      active: json['active'] ?? true,
      cropIds: List<String>.from(json['crop_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'alert_enabled': alertEnabled,
      'active': active,
      'crop_ids': cropIds,
    };
  }

  FarmerModel copyWith({
    String? fullName,
    String? phone,
    String? gender,
    String? region,
    String? zone,
    String? woreda,
    String? kebele,
    bool? alertEnabled,
    bool? active,
    List<String>? cropIds,
  }) {
    return FarmerModel(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      region: region ?? this.region,
      zone: zone ?? this.zone,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      active: active ?? this.active,
      cropIds: cropIds ?? this.cropIds,
    );
  }
}
