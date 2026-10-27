import 'dart:convert';

class FarmerCaseModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String subject;
  final String description;
  final String cropName;
  final String location;
  final List<String> attachmentPaths;
  final String
  status; // Canonical: OPEN, ASSIGNED, IN_PROGRESS, WAITING_FOR_INFORMATION, ESCALATED, RESOLVED, CLOSED
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedWorkerName;
  final String? responseNotes;
  final DateTime? responseDate;

  const FarmerCaseModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.subject,
    required this.description,
    required this.cropName,
    required this.location,
    this.attachmentPaths = const [],
    this.status = 'OPEN',
    required this.createdAt,
    required this.updatedAt,
    this.assignedWorkerName,
    this.responseNotes,
    this.responseDate,
  });

  String get crop => cropName;
  List<String> get attachments => attachmentPaths;
  bool get isClosed => status == 'RESOLVED' || status == 'CLOSED';
  String get trackingNumber =>
      'CASE-${id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}';
  String? get diagnosis => responseNotes;
  String? get recommendations => responseNotes;

  factory FarmerCaseModel.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachmentPaths'] ?? json['attachments'];
    final attachmentPaths = _parseAttachments(rawAttachments);
    return FarmerCaseModel(
      id:
          json['id'] as String? ??
          'case-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: (json['farmerId'] ?? json['farmer_id']) as String? ?? '',
      farmerName:
          (json['farmerName'] ?? json['farmer_name']) as String? ?? 'Farmer',
      farmerPhone:
          (json['farmerPhone'] ?? json['farmer_phone']) as String? ?? '',
      subject:
          json['subject'] as String? ??
          json['title'] as String? ??
          'Field Inquiry',
      description: json['description'] as String? ?? '',
      cropName:
          json['cropName'] as String? ??
          json['category'] as String? ??
          'General Crop',
      location: json['location'] as String? ?? 'Farm Plot',
      attachmentPaths: attachmentPaths,
      status: json['status'] as String? ?? 'OPEN',
      createdAt: (json['createdAt'] ?? json['created_at']) != null
          ? DateTime.tryParse(
                  (json['createdAt'] ?? json['created_at']).toString(),
                ) ??
                DateTime.now()
          : DateTime.now(),
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.tryParse(
                  (json['updatedAt'] ?? json['updated_at']).toString(),
                ) ??
                DateTime.now()
          : DateTime.now(),
      assignedWorkerName:
          (json['assignedWorkerName'] ?? json['assigned_to_name']) as String?,
      responseNotes:
          json['responseNotes'] as String? ??
          json['resolutionSummary'] as String? ??
          json['resolution_summary'] as String?,
      responseDate: (json['responseDate'] ?? json['response_date']) != null
          ? DateTime.tryParse(
              (json['responseDate'] ?? json['response_date']).toString(),
            )
          : null,
    );
  }

  static List<String> _parseAttachments(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    if (value is! String || value.isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } on FormatException {
      return const <String>[];
    }
    return const <String>[];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmerId': farmerId,
    'farmerName': farmerName,
    'farmerPhone': farmerPhone,
    'subject': subject,
    'description': description,
    'cropName': cropName,
    'location': location,
    'attachmentPaths': attachmentPaths,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (assignedWorkerName != null) 'assignedWorkerName': assignedWorkerName,
    if (responseNotes != null) 'responseNotes': responseNotes,
    if (responseDate != null) 'responseDate': responseDate!.toIso8601String(),
  };

  FarmerCaseModel copyWith({
    String? status,
    String? assignedWorkerName,
    String? responseNotes,
    DateTime? responseDate,
  }) {
    return FarmerCaseModel(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      subject: subject,
      description: description,
      cropName: cropName,
      location: location,
      attachmentPaths: attachmentPaths,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      responseNotes: responseNotes ?? this.responseNotes,
      responseDate: responseDate ?? this.responseDate,
    );
  }
}
