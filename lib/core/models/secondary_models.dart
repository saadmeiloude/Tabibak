import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'secondary_models.g.dart';

@JsonSerializable()
class Department {
  final int id;
  final String name;
  final String? icon;
  final DepartmentStatus? status;
  final int? doctorsCount;
  final int? patientsCount;
  final int? bedsTotal;
  final int? bedsOccupied;
  final String? description;
  final String? headDoctor;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Department({
    required this.id,
    required this.name,
    this.icon,
    this.status,
    this.doctorsCount,
    this.patientsCount,
    this.bedsTotal,
    this.bedsOccupied,
    this.description,
    this.headDoctor,
    required this.createdAt,
    this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) => _$DepartmentFromJson(json);
  Map<String, dynamic> toJson() => _$DepartmentToJson(this);
}

@JsonSerializable()
class Appointment {
  final int id;
  final int patientId;
  final int doctorId;
  final String? patientName;
  final String? patientPhoto;
  final String? doctorName;
  final String? department;
  final String? specialty;
  final DateTime appointmentDate;
  final String time;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.patientName,
    this.patientPhoto,
    this.doctorName,
    this.department,
    this.specialty,
    required this.appointmentDate,
    required this.time,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

@JsonSerializable()
class Notification {
  final int id;
  final int userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Priority priority;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.priority,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
