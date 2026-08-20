class MessageModel {
  final String id;
  final String contentId;
  final String channel; // SMS, IVR
  final String status; // QUEUED, SENT, DELIVERED, FAILED
  final String createdBy;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.contentId,
    required this.channel,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      contentId: json['content_id'] ?? '',
      channel: json['channel'] ?? 'SMS',
      status: json['status'] ?? 'QUEUED',
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'channel': channel,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
