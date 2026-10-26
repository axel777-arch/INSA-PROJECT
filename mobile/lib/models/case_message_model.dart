class CaseMessageModel {
  final String id;
  final String caseId;
  final String senderId;
  final String? recipientId;
  final String body;
  final String visibility;
  final DateTime createdAt;
  final DateTime? readAt;

  const CaseMessageModel({
    required this.id,
    required this.caseId,
    required this.senderId,
    this.recipientId,
    required this.body,
    required this.visibility,
    required this.createdAt,
    this.readAt,
  });

  factory CaseMessageModel.fromJson(Map<String, dynamic> json) {
    return CaseMessageModel(
      id: json['id'] as String? ?? '',
      caseId: (json['caseId'] ?? json['case_id']) as String? ?? '',
      senderId: (json['senderId'] ?? json['sender_id']) as String? ?? '',
      recipientId: (json['recipientId'] ?? json['recipient_id']) as String?,
      body: json['body'] as String? ?? '',
      visibility: json['visibility'] as String? ?? 'INTERNAL',
      createdAt:
          DateTime.tryParse(
            (json['createdAt'] ?? json['created_at']).toString(),
          ) ??
          DateTime.now(),
      readAt: (json['readAt'] ?? json['read_at']) == null
          ? null
          : DateTime.tryParse((json['readAt'] ?? json['read_at']).toString()),
    );
  }
}
