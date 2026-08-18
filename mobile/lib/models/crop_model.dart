class CropModel {
  final String id;
  final String name;
  final String description;
  final bool active;

  CropModel({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
    };
  }
}
