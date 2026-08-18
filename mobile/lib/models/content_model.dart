class ContentModel {
  final String id;
  final String title;
  final String body;
  final String cropId;
  final String language;
  final String status; // DRAFT, IN_REVIEW, APPROVED, PUBLISHED, REJECTED, ARCHIVED
  final String createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.body,
    required this.cropId,
    required this.language,
    required this.status,
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      cropId: json['crop_id'] ?? '',
      language: json['language'] ?? 'en',
      status: json['status'] ?? 'DRAFT',
      createdBy: json['created_by'] ?? '',
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'crop_id': cropId,
      'language': language,
      'status': status,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
