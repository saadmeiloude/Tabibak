import '../core/models/enums.dart';

class MedicalRecord {
  final int id;
  final int? patientId;
  final int? doctorId;
  final int? appointmentId;
  final RecordType recordType;
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
    this.patientId,
    this.doctorId,
    this.appointmentId,
    this.recordType = RecordType.consultation,
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
    dynamic get(String k1, String k2) => json[k1] ?? json[k2];

    return MedicalRecord(
      id: int.parse(json['id'].toString()),
      patientId: json['patientId'] != null ? int.parse(json['patientId'].toString()) : 
                 (json['patient_id'] != null ? int.parse(json['patient_id'].toString()) : null),
      doctorId: json['doctorId'] != null ? int.parse(json['doctorId'].toString()) : 
                (json['doctor_id'] != null ? int.parse(json['doctor_id'].toString()) : null),
      appointmentId: json['appointmentId'] != null ? int.parse(json['appointmentId'].toString()) : 
                     (json['appointment_id'] != null ? int.parse(json['appointment_id'].toString()) : null),
      recordType: ((){
          final val = get('recordType', 'record_type');
          return val != null
            ? RecordType.values.firstWhere(
                (e) => e.toString().split('.').last.toUpperCase() == val.toString().toUpperCase(),
                orElse: () => RecordType.consultation)
            : RecordType.consultation;
      })(),
      title: json['title'] ?? 'Medical Record',
      description: get('description', 'description'),
      diagnosis: get('diagnosis', 'diagnosis'),
      treatment: get('treatment', 'treatment'),
      medications: get('medications', 'medications'),
      attachments: get('attachments', 'attachments'),
      recordDate: ((){
          final val = get('recordDate', 'record_date');
          return val != null ? DateTime.parse(val.toString()) : DateTime.now();
      })(),
      createdAt: ((){
          final val = get('createdAt', 'created_at');
          return val != null ? DateTime.parse(val.toString()) : DateTime.now();
      })(),
      updatedAt: ((){
          final val = get('updatedAt', 'updated_at');
          return val != null ? DateTime.parse(val.toString()) : DateTime.now();
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_id': appointmentId,
      'record_type': recordType.toString().split('.').last.toUpperCase(),
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

  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;
  bool get isPrescription => recordType == RecordType.prescription;
  bool get isTestResult => recordType == RecordType.testResult;
  bool get isDiagnosis => recordType == RecordType.diagnosis;
}
