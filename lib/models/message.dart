import '../core/models/enums.dart';

class Message {
  final int id;
  final int? chatRoomId;
  final int senderId;
  final int receiverId;
  final String message;
  final int? appointmentId;
  final MessageType type;
  final String? attachmentUrl;
  final DateTime timestamp;
  final bool isRead;
  final MessageStatus status;
  final int? audioDuration;
  final DateTime createdAt;

  Message({
    required this.id,
    this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.appointmentId,
    this.type = MessageType.text,
    this.attachmentUrl,
    required this.timestamp,
    this.isRead = false,
    this.status = MessageStatus.sent,
    this.audioDuration,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: int.parse(json['id'].toString()),
      chatRoomId: json['chatRoomId'] != null ? int.parse(json['chatRoomId'].toString()) : null,
      senderId: int.parse(json['senderId'].toString()),
      receiverId: int.parse(json['receiverId'].toString()),
      message: json['message'] ?? '',
      appointmentId: json['appointmentId'] != null ? int.parse(json['appointmentId'].toString()) : null,
      type: json['type'] != null
          ? MessageType.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['type'].toString().toUpperCase(),
              orElse: () => MessageType.text)
          : MessageType.text,
      attachmentUrl: json['attachmentUrl'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      isRead: json['isRead'] == true || json['isRead'] == 1 || json['isRead'] == '1',
      status: json['status'] != null
          ? MessageStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['status'].toString().toUpperCase(),
              orElse: () => MessageStatus.sent)
          : MessageStatus.sent,
      audioDuration: json['audioDuration'] != null ? int.parse(json['audioDuration'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'appointmentId': appointmentId,
      'type': type.toString().split('.').last.toUpperCase(),
      'attachmentUrl': attachmentUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'status': status.toString().split('.').last.toUpperCase(),
      'audioDuration': audioDuration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  bool get isAudio => type == MessageType.audio;
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;
}
