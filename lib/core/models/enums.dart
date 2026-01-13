import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('PATIENT') patient,
  @JsonValue('DOCTOR') doctor,
  @JsonValue('ADMIN') admin,
  @JsonValue('STAFF') staff
}

enum Gender {
  @JsonValue('MALE') male,
  @JsonValue('FEMALE') female,
  @JsonValue('OTHER') other
}

enum BloodType {
  @JsonValue('A_POSITIVE') aPositive,
  @JsonValue('A_NEGATIVE') aNegative,
  @JsonValue('B_POSITIVE') bPositive,
  @JsonValue('B_NEGATIVE') bNegative,
  @JsonValue('O_POSITIVE') oPositive,
  @JsonValue('O_NEGATIVE') oNegative,
  @JsonValue('AB_POSITIVE') abPositive,
  @JsonValue('AB_NEGATIVE') abNegative
}

enum PatientStatus {
  @JsonValue('ACTIVE') active,
  @JsonValue('INACTIVE') inactive,
  @JsonValue('BANNED') banned
}

enum DepartmentStatus {
  @JsonValue('ACTIVE') active,
  @JsonValue('INACTIVE') inactive,
  @JsonValue('UNDER_MAINTENANCE') underMaintenance
}

enum AppointmentStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('CONFIRMED') confirmed,
  @JsonValue('CANCELLED') cancelled,
  @JsonValue('COMPLETED') completed,
  @JsonValue('NO_SHOW') noShow
}

enum ConsultationStatus {
  @JsonValue('SCHEDULED') scheduled,
  @JsonValue('IN_PROGRESS') inProgress,
  @JsonValue('COMPLETED') completed,
  @JsonValue('CANCELLED') cancelled
}

enum SessionType {
  @JsonValue('CHAT') chat,
  @JsonValue('VIDEO') video,
  @JsonValue('VOICE') voice
}

enum SessionStatus {
  @JsonValue('WAITING') waiting,
  @JsonValue('ACTIVE') active,
  @JsonValue('ENDED') ended
}

enum MessageType {
  @JsonValue('TEXT') text,
  @JsonValue('IMAGE') image,
  @JsonValue('AUDIO') audio,
  @JsonValue('FILE') file
}

enum MessageStatus {
  @JsonValue('SENT') sent,
  @JsonValue('DELIVERED') delivered,
  @JsonValue('READ') read
}

enum PaymentMethod {
  @JsonValue('CASH') cash,
  @JsonValue('CREDIT_CARD') creditCard,
  @JsonValue('INSURANCE') insurance,
  @JsonValue('BANK_TRANSFER') bankTransfer
}

enum InvoiceStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('PAID') paid,
  @JsonValue('OVERDUE') overdue,
  @JsonValue('CANCELLED') cancelled
}

enum NotificationType {
  @JsonValue('APPOINTMENT') appointment,
  @JsonValue('MESSAGE') message,
  @JsonValue('SYSTEM') system,
  @JsonValue('REMINDER') reminder
}

enum Priority {
  @JsonValue('LOW') low,
  @JsonValue('MEDIUM') medium,
  @JsonValue('HIGH') high,
  @JsonValue('URGENT') urgent
}

enum RecordType {
  @JsonValue('CONSULTATION') consultation,
  @JsonValue('PRESCRIPTION') prescription,
  @JsonValue('TEST_RESULT') testResult,
  @JsonValue('DIAGNOSIS') diagnosis
}

enum TransactionType {
  @JsonValue('DEPOSIT') deposit,
  @JsonValue('WITHDRAWAL') withdrawal,
  @JsonValue('PAYMENT') payment
}

enum TransactionStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('COMPLETED') completed,
  @JsonValue('FAILED') failed,
  @JsonValue('CANCELLED') cancelled
}

enum EmailStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('SENT') sent,
  @JsonValue('FAILED') failed,
  @JsonValue('RETRY') retry,
  @JsonValue('CANCELLED') cancelled
}

enum EmailPriority {
  @JsonValue('LOW') low,
  @JsonValue('NORMAL') normal,
  @JsonValue('HIGH') high
}
