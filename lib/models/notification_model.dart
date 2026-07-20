class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final String priority;
  final String action;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.priority,
    required this.action,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      notificationType: (json['notification_type'] ?? json['type'] ?? 'general').toString(),
      priority: json['priority']?.toString() ?? 'normal',
      action: json['action']?.toString() ?? 'none',
      isRead: json['is_read'] == true || json['isRead'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'priority': priority,
      'action': action,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}
