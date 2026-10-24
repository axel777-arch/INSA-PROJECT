class NotificationItemModel {
  final String id;
  final String title;
  final String body;
  final String category; // WEATHER, PEST_DISEASE, MARKET, ADVISORY
  final String severity; // HIGH, MEDIUM, INFO
  final String channel; // SMS, IN_APP, IVR
  bool isRead;
  final DateTime createdAt;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.body,
    this.category = 'ADVISORY',
    this.severity = 'MEDIUM',
    this.channel = 'IN_APP',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String? ?? 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Notification Alert',
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? 'ADVISORY',
      severity: json['severity'] as String? ?? 'MEDIUM',
      channel: json['channel'] as String? ?? 'IN_APP',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'severity': severity,
    'channel': channel,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };
}
