import '../core/models/enums.dart';

class Consultation {
  final int id;
  final int? patientId;
  final int? doctorId;
  final String? doctorName;
  final String? specialty;
  final DateTime consultationDate;
  final ConsultationStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    this.patientId,
    this.doctorId,
    this.doctorName,
    this.specialty,
    required this.consultationDate,
    this.status = ConsultationStatus.scheduled,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: int.parse(json['id'].toString()),
      patientId: json['patientId'] != null ? int.parse(json['patientId'].toString()) : null,
      doctorId: json['doctorId'] != null ? int.parse(json['doctorId'].toString()) : null,
      doctorName: json['doctorName'],
      specialty: json['specialty'],
      consultationDate: json['consultationDate'] != null 
          ? DateTime.parse(json['consultationDate']) 
          : DateTime.now(),
      status: json['status'] != null
          ? ConsultationStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['status'].toString().toUpperCase(),
              orElse: () => ConsultationStatus.scheduled)
          : ConsultationStatus.scheduled,
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'consultationDate': consultationDate.toIso8601String(),
      'status': status.toString().split('.').last.toUpperCase(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
