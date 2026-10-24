class FieldObservationModel {
  final String id;
  final String farmerId;
  final String workerId;
  final String? cropId;
  final String observationType;
  final String severity;
  final String title;
  final String description;
  final String? actionTaken;
  final bool isEscalated;
  final String? escalatedToId;
  final String farmerName;
  final String workerName;
  final List<ObservationAttachmentModel> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FieldObservationModel({
    required this.id,
    required this.farmerId,
    required this.workerId,
    this.cropId,
    required this.observationType,
    required this.severity,
    required this.title,
    required this.description,
    this.actionTaken,
    required this.isEscalated,
    this.escalatedToId,
    this.farmerName = '',
    this.workerName = '',
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory FieldObservationModel.fromJson(Map<String, dynamic> json) {
    return FieldObservationModel(
      id: json['id'] as String? ?? '',
      farmerId: json['farmer_id'] as String? ?? '',
      workerId: json['worker_id'] as String? ?? '',
      cropId: json['crop_id'] as String?,
      observationType: json['observation_type'] as String? ?? 'GENERAL_CHECKUP',
      severity: json['severity'] as String? ?? 'LOW',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actionTaken: json['action_taken'] as String?,
      isEscalated: json['is_escalated'] as bool? ?? false,
      escalatedToId: json['escalated_to_id'] as String?,
      farmerName: json['farmer_name'] as String? ?? '',
      workerName: json['worker_name'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => ObservationAttachmentModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'worker_id': workerId,
      if (cropId != null) 'crop_id': cropId,
      'observation_type': observationType,
      'severity': severity,
      'title': title,
      'description': description,
      if (actionTaken != null) 'action_taken': actionTaken,
      'is_escalated': isEscalated,
      if (escalatedToId != null) 'escalated_to_id': escalatedToId,
    };
  }
}

class ObservationAttachmentModel {
  final String id;
  final String observationId;
  final String fileUrl;
  final String fileType;
  final String? fileName;
  final DateTime uploadedAt;

  const ObservationAttachmentModel({
    required this.id,
    required this.observationId,
    required this.fileUrl,
    required this.fileType,
    this.fileName,
    required this.uploadedAt,
  });

  factory ObservationAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ObservationAttachmentModel(
      id: json['id'] as String? ?? '',
      observationId: json['observation_id'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'IMAGE',
      fileName: json['file_name'] as String?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
