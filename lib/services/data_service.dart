import 'api_service.dart';

// Helper function to safely parse double values
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

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
    return Appointment(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      patientName: json['patient_name'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      appointmentTime: DateTime.parse('1970-01-01 ${json['appointment_time']}'),
      durationMinutes: json['duration_minutes'] ?? 30,
      status: json['status'],
      consultationType: json['consultation_type'] ?? 'online',
      symptoms: json['symptoms'],
      notes: json['notes'],
      prescription: json['prescription'],
      feePaid: _parseDouble(json['fee_paid']),
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
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      appointmentId: json['appointment_id'],
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

class Doctor {
  final int id;
  final int userId;
  final String licenseNumber;
  final String specialization;
  final int experienceYears;
  final String? education;
  final String? certifications;
  final double consultationFee;
  final String? availabilitySchedule;
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.specialization,
    required this.experienceYears,
    this.education,
    this.certifications,
    required this.consultationFee,
    this.availabilitySchedule,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      userId: json['user_id'],
      licenseNumber: json['license_number'],
      specialization: json['specialization'],
      experienceYears: json['experience_years'] ?? 0,
      education: json['education'],
      certifications: json['certifications'],
      consultationFee: _parseDouble(json['consultation_fee']),
      availabilitySchedule: json['availability_schedule'],
      rating: _parseDouble(json['rating']),
      totalReviews: json['total_reviews'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_number': licenseNumber,
      'specialization': specialization,
      'experience_years': experienceYears,
      'education': education,
      'certifications': certifications,
      'consultation_fee': consultationFee,
      'availability_schedule': availabilitySchedule,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Research {
  final int id;
  final int doctorId;
  final String title;
  final String? summary;
  final String? content;
  final String? attachmentUrl;
  final String? category;
  final String? tags;
  final bool isPublished;
  final String? doctorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Research({
    required this.id,
    required this.doctorId,
    required this.title,
    this.summary,
    this.content,
    this.attachmentUrl,
    this.category,
    this.tags,
    required this.isPublished,
    this.doctorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Research.fromJson(Map<String, dynamic> json) {
    return Research(
      id: json['id'],
      doctorId: json['doctor_id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      attachmentUrl: json['attachment_url'],
      category: json['category'],
      tags: json['tags'],
      isPublished: json['is_published'] == 1 || json['is_published'] == true,
      doctorName: json['doctor_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'title': title,
      'summary': summary,
      'content': content,
      'attachment_url': attachmentUrl,
      'category': category,
      'tags': tags,
      'is_published': isPublished,
      'doctor_name': doctorName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DataService {
  // Initialization
  static Future<void> init() async {
    // API-based service, no local initialization needed
  }

  // Get doctor dashboard stats
  static Future<Map<String, dynamic>> getDoctorDashboardStats() async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/doctor/dashboard_stats.php',
        method:
            'POST', // Using POST to easily send token in body if needed, though headers handle it
        data: {}, // Token handled by ApiService automatically
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get doctor profile
  static Future<Map<String, dynamic>> getDoctorProfile() async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/doctor/profile.php',
        method: 'GET',
        requiresAuth: true,
      );
      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update doctor profile
  static Future<Map<String, dynamic>> updateDoctorProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/doctor/profile.php',
        method: 'POST',
        data: data,
        requiresAuth: true,
      );
      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Appointment Services
  static Future<Map<String, dynamic>> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
    required DateTime appointmentTime,
    String? symptoms,
    String consultationType = 'online',
    int durationMinutes = 30,
  }) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/appointments/create.php',
        method: 'POST',
        data: {
          'doctor_id': doctorId,
          'appointment_date': appointmentDate.toIso8601String().split('T')[0],
          'appointment_time':
              '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}:00',
          'symptoms': symptoms,
          'consultation_type': consultationType,
          'duration_minutes': durationMinutes,
        },
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final appointment = Appointment.fromJson(result['data']['appointment']);

        return {
          'success': true,
          'appointment': appointment,
          'message': result['message'],
        };
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to create appointment',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserAppointments({int? userId}) async {
    try {
      final response = await ApiService.request(
        endpoint:
            'api/appointments/list.php${userId != null ? '?user_id=$userId' : ''}',
        method: 'GET',
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final appointments = (result['data']['appointments'] as List)
            .map((json) => Appointment.fromJson(json))
            .toList();

        return {'success': true, 'appointments': appointments};
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to fetch appointments',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> cancelAppointment(
    int appointmentId,
  ) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/appointments/cancel.php',
        method: 'POST',
        data: {'id': appointmentId},
        requiresAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateAppointment({
    required int appointmentId,
    String? status,
    DateTime? appointmentDate,
    DateTime? appointmentTime,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> data = {'id': appointmentId};
      if (status != null) data['status'] = status;
      if (appointmentDate != null) {
        data['appointment_date'] = appointmentDate.toIso8601String().split(
          'T',
        )[0];
      }
      if (appointmentTime != null) {
        data['appointment_time'] =
            '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}:00';
      }
      if (notes != null) data['notes'] = notes;

      final response = await ApiService.request(
        endpoint: 'api/appointments/update.php',
        method: 'POST',
        data: data,
        requiresAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Doctor Services
  static Future<Map<String, dynamic>> getDoctors({
    String? specialization,
  }) async {
    try {
      final endpoint = specialization != null
          ? 'api/doctors/list.php?specialization=$specialization'
          : 'api/doctors/list.php';

      final response = await ApiService.request(
        endpoint: endpoint,
        method: 'GET',
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final doctors = (result['data']['doctors'] as List)
            .map((json) => Doctor.fromJson(json))
            .toList();

        return {'success': true, 'doctors': doctors};
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to fetch doctors',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getDoctorDetails(int doctorId) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/doctors/details.php?id=$doctorId',
        method: 'GET',
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final doctor = Doctor.fromJson(result['data']['doctor']);

        return {'success': true, 'doctor': doctor};
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to fetch doctor details',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Medical Record Services
  static Future<Map<String, dynamic>> getPatientRecords({
    int? patientId,
  }) async {
    try {
      final endpoint = patientId != null
          ? 'api/medical-records/list.php?patient_id=$patientId'
          : 'api/medical-records/list.php';

      final response = await ApiService.request(
        endpoint: endpoint,
        method: 'GET',
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final records = (result['data']['records'] as List)
            .map((json) => MedicalRecord.fromJson(json))
            .toList();

        return {'success': true, 'records': records};
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to fetch medical records',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createMedicalRecord({
    required int doctorId,
    required String recordType,
    required String title,
    String? description,
    String? diagnosis,
    String? treatment,
    String? medications,
    int? appointmentId,
  }) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/medical-records/create.php',
        method: 'POST',
        data: {
          'doctor_id': doctorId,
          'record_type': recordType,
          'title': title,
          'description': description,
          'diagnosis': diagnosis,
          'treatment': treatment,
          'medications': medications,
          'appointment_id': appointmentId,
          'record_date': DateTime.now().toIso8601String().split('T')[0],
        },
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final record = MedicalRecord.fromJson(result['data']['record']);

        return {
          'success': true,
          'record': record,
          'message': result['message'],
          'data': result['data'],
        };
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to create medical record',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Patient Services (Doctor View)
  static Future<Map<String, dynamic>> getPatients() async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/patients/list.php',
        method: 'GET',
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        return {'success': true, 'patients': result['data']['patients']};
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to fetch patients',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> savePatient(
    Map<String, dynamic> patientData,
  ) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/patients/create.php', // or update if id exists
        method: 'POST',
        data: patientData,
        requiresAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Dashboard/Analytics Services
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/dashboard/stats.php',
        method: 'GET',
        requiresAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Profile & Settings Services
  static Map<String, bool> getNotificationSettings() {
    return {'notifications': true, 'email': true, 'sms': false};
  }

  static Future<void> saveNotificationSettings({
    required bool notifications,
    required bool emailNotifications,
    required bool smsNotifications,
  }) async {
    // TODO: Implement API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<void> saveUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    // TODO: Implement API call
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> saveProfileImage(String imagePath) async {
    // TODO: Implement API call
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> saveMedicalRecord(String name, String filePath) async {
    // TODO: Implement API call
    await Future.delayed(const Duration(seconds: 1));
  }

  static List<Map<String, dynamic>> getMedicalRecords() {
    // Mock data
    return [
      {'name': 'تحليل دم شامل', 'date': '2023-10-15', 'file': 'blood_test.pdf'},
      {'name': 'أشعة سينية للصدر', 'date': '2023-09-20', 'file': 'xray.jpg'},
    ];
  }

  // Research Services
  static Future<Map<String, dynamic>> getResearch({
    String? category,
    String? search,
    int? doctorId,
  }) async {
    try {
      String endpoint = 'api/research/list.php?';
      if (category != null) endpoint += 'category=$category&';
      if (search != null) endpoint += 'search=$search&';
      if (doctorId != null) endpoint += 'doctor_id=$doctorId&';

      final response = await ApiService.request(
        endpoint: endpoint,
        method: 'GET',
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final researchList = (result['data'] as List)
            .map((json) => Research.fromJson(json))
            .toList();

        return {'success': true, 'research': researchList};
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Failed to fetch research',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createResearch({
    required String title,
    String? summary,
    String? content,
    String? category,
    String? tags,
    bool isPublished = true,
  }) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/research/create.php',
        method: 'POST',
        data: {
          'title': title,
          'summary': summary,
          'content': content,
          'category': category,
          'tags': tags,
          'is_published': isPublished,
        },
        requiresAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateResearch({
    required int id,
    String? title,
    String? summary,
    String? content,
    String? category,
    bool? isPublished,
  }) async {
    try {
      final Map<String, dynamic> data = {'id': id};
      if (title != null) data['title'] = title;
      if (summary != null) data['summary'] = summary;
      if (content != null) data['content'] = content;
      if (category != null) data['category'] = category;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await ApiService.request(
        endpoint: 'api/research/update.php',
        method: 'POST',
        data: data,
        requiresAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteResearch(int id) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/research/delete.php',
        method: 'POST',
        data: {'id': id},
        requiresAuth: true,
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
