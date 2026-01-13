import '../core/models/enums.dart';

class ConsultationSession {
  final int id;
  final int? chatRoomId;
  final int? doctorId;
  final int? patientId;
  final SessionType type;
  final SessionStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;

  ConsultationSession({
    required this.id,
    this.chatRoomId,
    this.doctorId,
    this.patientId,
    this.type = SessionType.chat,
    this.status = SessionStatus.waiting,
    this.startTime,
    this.endTime,
    required this.createdAt,
  });

  factory ConsultationSession.fromJson(Map<String, dynamic> json) {
    return ConsultationSession(
      id: int.parse(json['id'].toString()),
      chatRoomId: json['chatRoomId'] != null ? int.parse(json['chatRoomId'].toString()) : null,
      doctorId: json['doctorId'] != null ? int.parse(json['doctorId'].toString()) : null,
      patientId: json['patientId'] != null ? int.parse(json['patientId'].toString()) : null,
      type: json['type'] != null
          ? SessionType.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['type'].toString().toUpperCase(),
              orElse: () => SessionType.chat)
          : SessionType.chat,
      status: json['status'] != null
          ? SessionStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['status'].toString().toUpperCase(),
              orElse: () => SessionStatus.waiting)
          : SessionStatus.waiting,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'doctorId': doctorId,
      'patientId': patientId,
      'type': type.toString().split('.').last.toUpperCase(),
      'status': status.toString().split('.').last.toUpperCase(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  bool get isActive => status == SessionStatus.active;
  bool get isEnded => status == SessionStatus.ended;
}
