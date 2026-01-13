import '../core/models/enums.dart';

class Notification {
  final int id;
  final int? userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final int? relatedId;
  final Priority priority;
  final DateTime createdAt;

  Notification({
    required this.id,
    this.userId,
    this.type = NotificationType.system,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
    this.priority = Priority.medium,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: int.parse(json['id'].toString()),
      userId: json['userId'] != null ? int.parse(json['userId'].toString()) : null,
      type: json['type'] != null
          ? NotificationType.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['type'].toString().toUpperCase(),
              orElse: () => NotificationType.system)
          : NotificationType.system,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      isRead: json['isRead'] == true || json['isRead'] == 1 || json['isRead'] == '1',
      relatedId: json['relatedId'] != null ? int.parse(json['relatedId'].toString()) : null,
      priority: json['priority'] != null
          ? Priority.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['priority'].toString().toUpperCase(),
              orElse: () => Priority.medium)
          : Priority.medium,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last.toUpperCase(),
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedId': relatedId,
      'priority': priority.toString().split('.').last.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isUnread => !isRead;
  bool get isHighPriority => priority == Priority.high || priority == Priority.urgent;
  bool get isAppointmentNotification => type == NotificationType.appointment;
  bool get isMessageNotification => type == NotificationType.message;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
