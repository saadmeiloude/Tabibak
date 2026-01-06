class MedicalRecord {
  final int id;
  final int patientId;
  final int doctorId;
  final int? appointmentId;
  final String recordType;
  final String title;
  final String? description;
  final String? diagnosis;
  final String? treatment;
  final String? medications;
  final String? attachments;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.appointmentId,
    required this.recordType,
    required this.title,
    this.description,
    this.diagnosis,
    this.treatment,
    this.medications,
    this.attachments,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: int.parse(json['id'].toString()),
      patientId: int.parse(json['patient_id'].toString()),
      doctorId: int.parse(json['doctor_id'].toString()),
      appointmentId: json['appointment_id'] != null
          ? int.parse(json['appointment_id'].toString())
          : null,
      recordType: json['record_type'],
      title: json['title'],
      description: json['description'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      medications: json['medications'],
      attachments: json['attachments'],
      recordDate: DateTime.parse(json['record_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_id': appointmentId,
      'record_type': recordType,
      'title': title,
      'description': description,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'medications': medications,
      'attachments': attachments,
      'record_date': recordDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
