class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String role; // FARMER, EXTENSION_WORKER, EXPERT, ADMIN
  final String preferredLanguage;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.preferredLanguage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'FARMER',
      preferredLanguage: json['preferred_language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'preferred_language': preferredLanguage,
    };
  }
}
