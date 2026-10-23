class ContentModel {
  final String id;
  final String title;
  final String? summary;
  final String body;
  final String? cropId;
  final String? category;
  final String language;
  final String? region;
  final String? zone;
  final String? woreda;
  final String? kebele;
  final String? season;
  final String? cropStage;
  final String priority;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? sourceInfo;
  final String? attachments;
  final int version;
  final String status;
  final String createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentModel({
    required this.id,
    required this.title,
    this.summary,
    required this.body,
    this.cropId,
    this.category,
    required this.language,
    this.region,
    this.zone,
    this.woreda,
    this.kebele,
    this.season,
    this.cropStage,
    this.priority = 'NORMAL',
    this.validFrom,
    this.validUntil,
    this.sourceInfo,
    this.attachments,
    this.version = 1,
    required this.status,
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] as String? ?? 'DRAFT').toUpperCase();
    final normalizedStatus = rawStatus == 'PENDING_REVIEW' ? 'IN_REVIEW' : rawStatus;

    // Location can come from direct fields or legacy location field
    final region = json['region'] as String? ?? json['location'] as String?;
    final zone = json['zone'] as String?;
    final woreda = json['woreda'] as String?;
    final kebele = json['kebele'] as String?;

    return ContentModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String?,
      body: json['body'] as String? ?? '',
      cropId: (json['crop_id'] ?? json['cropId']) as String?,
      category: json['category'] as String?,
      language: json['language'] as String? ?? 'en',
      region: region,
      zone: zone,
      woreda: woreda,
      kebele: kebele,
      season: json['season'] as String?,
      cropStage: (json['crop_stage'] ?? json['cropStage']) as String?,
      priority: (json['priority'] as String? ?? 'NORMAL').toUpperCase(),
      validFrom: json['valid_from'] != null
          ? DateTime.tryParse(json['valid_from'] as String)
          : (json['validFrom'] != null ? DateTime.tryParse(json['validFrom'] as String) : null),
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'] as String)
          : (json['validUntil'] != null ? DateTime.tryParse(json['validUntil'] as String) : null),
      sourceInfo: (json['source_info'] ?? json['sourceInfo']) as String?,
      attachments: json['attachments'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      status: normalizedStatus,
      createdBy: (json['author_id'] ?? json['authorId'] ?? json['created_by'] ?? json['createdBy']) as String? ?? '',
      approvedBy: (json['approved_by'] ?? json['approvedBy']) as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'body': body,
      'crop_id': cropId,
      'category': category,
      'language': language,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'season': season,
      'crop_stage': cropStage,
      'priority': priority,
      'valid_from': validFrom?.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'source_info': sourceInfo,
      'attachments': attachments,
      'version': version,
      'status': status,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convenience helper for backward compatibility
  String? get location => region;

  bool get isDraft => status == 'DRAFT';
  bool get isNeedsRevision => status == 'NEEDS_REVISION';
  bool get isPendingReview => status == 'IN_REVIEW' || status == 'PENDING_REVIEW';
  bool get isApproved => status == 'APPROVED';
  bool get isPublished => status == 'PUBLISHED';
  bool get isArchived => status == 'ARCHIVED';
  bool get isRejected => status == 'REJECTED';

  String get statusLabel {
    switch (status) {
      case 'DRAFT': return 'Draft';
      case 'IN_REVIEW':
      case 'PENDING_REVIEW': return 'In Review';
      case 'NEEDS_REVISION': return 'Needs Revision';
      case 'APPROVED': return 'Approved';
      case 'PUBLISHED': return 'Published';
      case 'REJECTED': return 'Rejected';
      case 'ARCHIVED': return 'Archived';
      default: return status;
    }
  }

  String get locationDisplay {
    final parts = [region, zone, woreda, kebele].where((p) => p != null && p.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'All Regions' : parts.join(', ');
  }
}

class ContentVersionModel {
  final String id;
  final String contentId;
  final int versionNumber;
  final String title;
  final String? summary;
  final String body;
  final String? cropId;
  final String? category;
  final String language;
  final String? region;
  final String? zone;
  final String? woreda;
  final String? kebele;
  final String? season;
  final String? cropStage;
  final String priority;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? sourceInfo;
  final String? attachments;
  final String statusAtVersion;
  final String? authorId;
  final String? changeSummary;
  final DateTime createdAt;

  ContentVersionModel({
    required this.id,
    required this.contentId,
    required this.versionNumber,
    required this.title,
    this.summary,
    required this.body,
    this.cropId,
    this.category,
    required this.language,
    this.region,
    this.zone,
    this.woreda,
    this.kebele,
    this.season,
    this.cropStage,
    this.priority = 'NORMAL',
    this.validFrom,
    this.validUntil,
    this.sourceInfo,
    this.attachments,
    required this.statusAtVersion,
    this.authorId,
    this.changeSummary,
    required this.createdAt,
  });

  factory ContentVersionModel.fromJson(Map<String, dynamic> json) {
    return ContentVersionModel(
      id: json['id'] as String? ?? '',
      contentId: (json['content_id'] ?? json['contentId']) as String? ?? '',
      versionNumber: (json['version_number'] ?? json['versionNumber'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String?,
      body: json['body'] as String? ?? '',
      cropId: (json['crop_id'] ?? json['cropId']) as String?,
      category: json['category'] as String?,
      language: json['language'] as String? ?? 'en',
      region: json['region'] as String?,
      zone: json['zone'] as String?,
      woreda: json['woreda'] as String?,
      kebele: json['kebele'] as String?,
      season: json['season'] as String?,
      cropStage: (json['crop_stage'] ?? json['cropStage']) as String?,
      priority: (json['priority'] as String? ?? 'NORMAL').toUpperCase(),
      validFrom: json['valid_from'] != null
          ? DateTime.tryParse(json['valid_from'] as String)
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'] as String)
          : null,
      sourceInfo: (json['source_info'] ?? json['sourceInfo']) as String?,
      attachments: json['attachments'] as String?,
      statusAtVersion: (json['status_at_version'] ?? json['statusAtVersion']) as String? ?? 'DRAFT',
      authorId: (json['author_id'] ?? json['authorId']) as String?,
      changeSummary: (json['change_summary'] ?? json['changeSummary']) as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ContentReviewModel {
  final String id;
  final String contentId;
  final String reviewerId;
  final String status;
  final String? comments;
  final DateTime reviewedAt;
  final String? reviewerName;
  final String? reviewerRole;

  ContentReviewModel({
    required this.id,
    required this.contentId,
    required this.reviewerId,
    required this.status,
    this.comments,
    required this.reviewedAt,
    this.reviewerName,
    this.reviewerRole,
  });

  factory ContentReviewModel.fromJson(Map<String, dynamic> json) {
    return ContentReviewModel(
      id: json['id'] as String? ?? '',
      contentId: (json['content_id'] ?? json['contentId']) as String? ?? '',
      reviewerId: (json['reviewer_id'] ?? json['reviewerId']) as String? ?? '',
      status: json['status'] as String? ?? '',
      comments: json['comments'] as String?,
      reviewedAt: DateTime.tryParse(json['reviewed_at'] as String? ?? json['reviewedAt'] as String? ?? '') ?? DateTime.now(),
      reviewerName: json['reviewerName'] as String?,
      reviewerRole: json['reviewerRole'] as String?,
    );
  }
}
