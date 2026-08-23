class ContentModel {
  final String id;
  final String title;
  final String body;
  // cropId is a UUID from the crops table, or null/empty if not crop-specific
  final String? cropId;
  final String language;
  final String? location;
  final String status; // DRAFT, IN_REVIEW, APPROVED, PUBLISHED, REJECTED, ARCHIVED
  // createdBy is a UUID; display name must be fetched from users if needed
  final String createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.body,
    this.cropId,
    required this.language,
    this.location,
    required this.status,
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cropId: json['crop_id'] as String?,
      language: json['language'] as String? ?? 'en',
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      createdBy: json['created_by'] as String? ?? '',
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'crop_id': cropId,
      'language': language,
      'location': location,
      'status': status,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Human-readable status label for display
  String get statusLabel {
    switch (status) {
      case 'DRAFT': return 'Draft';
      case 'IN_REVIEW': return 'In Review';
      case 'APPROVED': return 'Approved';
      case 'PUBLISHED': return 'Published';
      case 'REJECTED': return 'Rejected';
      case 'ARCHIVED': return 'Archived';
      default: return status;
    }
  }
}
