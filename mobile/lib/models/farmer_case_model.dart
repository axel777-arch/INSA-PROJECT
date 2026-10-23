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
  final String status; // Canonical: OPEN, ASSIGNED, IN_PROGRESS, WAITING_FOR_INFORMATION, ESCALATED, RESOLVED, CLOSED
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
  String get trackingNumber => 'CASE-${id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}';
  String? get diagnosis => responseNotes;
  String? get recommendations => responseNotes;

  factory FarmerCaseModel.fromJson(Map<String, dynamic> json) {
    return FarmerCaseModel(
      id: json['id'] as String? ?? 'case-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: json['farmerId'] as String? ?? '',
      farmerName: json['farmerName'] as String? ?? 'Farmer',
      farmerPhone: json['farmerPhone'] as String? ?? '',
      subject: json['subject'] as String? ?? 'Field Inquiry',
      description: json['description'] as String? ?? '',
      cropName: json['cropName'] as String? ?? 'General Crop',
      location: json['location'] as String? ?? 'Farm Plot',
      attachmentPaths: (json['attachmentPaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      assignedWorkerName: json['assignedWorkerName'] as String?,
      responseNotes: json['responseNotes'] as String?,
      responseDate: json['responseDate'] != null
          ? DateTime.tryParse(json['responseDate'].toString())
          : null,
    );
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
