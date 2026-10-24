class FollowUpModel {
  final String id;
  final String farmerId;
  final String workerId;
  final String? observationId;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status;
  final String? notes;
  final String? outcome;
  final String farmerName;
  final String workerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FollowUpModel({
    required this.id,
    required this.farmerId,
    required this.workerId,
    this.observationId,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    this.notes,
    this.outcome,
    this.farmerName = '',
    this.workerName = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id'] as String? ?? '',
      farmerId: json['farmer_id'] as String? ?? '',
      workerId: json['worker_id'] as String? ?? '',
      observationId: json['observation_id'] as String?,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.tryParse(json['scheduled_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedDate: json['completed_date'] != null
          ? DateTime.tryParse(json['completed_date'].toString())
          : null,
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      outcome: json['outcome'] as String?,
      farmerName: json['farmer_name'] as String? ?? '',
      workerName: json['worker_name'] as String? ?? '',
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
      if (observationId != null) 'observation_id': observationId,
      'scheduled_date': scheduledDate.toIso8601String(),
      if (completedDate != null) 'completed_date': completedDate!.toIso8601String(),
      'status': status,
      if (notes != null) 'notes': notes,
      if (outcome != null) 'outcome': outcome,
    };
  }
}
