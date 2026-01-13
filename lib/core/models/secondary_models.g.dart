// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secondary_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Department _$DepartmentFromJson(Map<String, dynamic> json) => Department(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  icon: json['icon'] as String?,
  status: $enumDecodeNullable(_$DepartmentStatusEnumMap, json['status']),
  doctorsCount: (json['doctorsCount'] as num?)?.toInt(),
  patientsCount: (json['patientsCount'] as num?)?.toInt(),
  bedsTotal: (json['bedsTotal'] as num?)?.toInt(),
  bedsOccupied: (json['bedsOccupied'] as num?)?.toInt(),
  description: json['description'] as String?,
  headDoctor: json['headDoctor'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DepartmentToJson(Department instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'status': _$DepartmentStatusEnumMap[instance.status],
      'doctorsCount': instance.doctorsCount,
      'patientsCount': instance.patientsCount,
      'bedsTotal': instance.bedsTotal,
      'bedsOccupied': instance.bedsOccupied,
      'description': instance.description,
      'headDoctor': instance.headDoctor,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DepartmentStatusEnumMap = {
  DepartmentStatus.active: 'ACTIVE',
  DepartmentStatus.inactive: 'INACTIVE',
  DepartmentStatus.underMaintenance: 'UNDER_MAINTENANCE',
};

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: (json['id'] as num).toInt(),
  patientId: (json['patientId'] as num).toInt(),
  doctorId: (json['doctorId'] as num).toInt(),
  patientName: json['patientName'] as String?,
  patientPhoto: json['patientPhoto'] as String?,
  doctorName: json['doctorName'] as String?,
  department: json['department'] as String?,
  specialty: json['specialty'] as String?,
  appointmentDate: DateTime.parse(json['appointmentDate'] as String),
  time: json['time'] as String,
  status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'patientName': instance.patientName,
      'patientPhoto': instance.patientPhoto,
      'doctorName': instance.doctorName,
      'department': instance.department,
      'specialty': instance.specialty,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'time': instance.time,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.pending: 'PENDING',
  AppointmentStatus.confirmed: 'CONFIRMED',
  AppointmentStatus.cancelled: 'CANCELLED',
  AppointmentStatus.completed: 'COMPLETED',
  AppointmentStatus.noShow: 'NO_SHOW',
};

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  title: json['title'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isRead: json['isRead'] as bool,
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'isRead': instance.isRead,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.appointment: 'APPOINTMENT',
  NotificationType.message: 'MESSAGE',
  NotificationType.system: 'SYSTEM',
  NotificationType.reminder: 'REMINDER',
};

const _$PriorityEnumMap = {
  Priority.low: 'LOW',
  Priority.medium: 'MEDIUM',
  Priority.high: 'HIGH',
};
