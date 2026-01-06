class Appointment {
  final int id;
  final int patientId;
  final int doctorId;
  final String? doctorName;
  final String? patientName;
  final DateTime appointmentDate;
  final DateTime appointmentTime;
  final int durationMinutes;
  final String status;
  final String consultationType;
  final String? symptoms;
  final String? notes;
  final String? prescription;
  final double feePaid;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.doctorName,
    this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.durationMinutes,
    required this.status,
    required this.consultationType,
    this.symptoms,
    this.notes,
    this.prescription,
    required this.feePaid,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Helper
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Appointment(
      id: int.parse(json['id'].toString()),
      patientId: int.parse(json['patient_id'].toString()),
      doctorId: int.parse(json['doctor_id'].toString()),
      doctorName: json['doctor_name'],
      patientName: json['patient_name'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      appointmentTime: DateTime.parse('1970-01-01 ${json['appointment_time']}'),
      durationMinutes: int.parse((json['duration_minutes'] ?? 30).toString()),
      status: json['status'],
      consultationType: json['consultation_type'] ?? 'online',
      symptoms: json['symptoms'],
      notes: json['notes'],
      prescription: json['prescription'],
      feePaid: parseDouble(json['fee_paid']),
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'patient_name': patientName,
      'appointment_date': appointmentDate.toIso8601String().split('T')[0],
      'appointment_time':
          '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}:00',
      'duration_minutes': durationMinutes,
      'status': status,
      'consultation_type': consultationType,
      'symptoms': symptoms,
      'notes': notes,
      'prescription': prescription,
      'fee_paid': feePaid,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
