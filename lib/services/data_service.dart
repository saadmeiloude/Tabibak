import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/medical_record.dart';
import '../models/research.dart';
import 'api_service.dart';

// Helper function to safely parse double values should be kept if used internally by DataService, 
// but models have their own now. DataService uses it?
// Searching file... DataService uses _parseDouble? No, only models used it.
// Actually, let's keep the imports clean.

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
    int? patientId, // Added optional patientId
    String? symptoms,
    String consultationType = 'online',
    int durationMinutes = 30,
  }) async {
    try {
      final Map<String, dynamic> reqData = {
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String().split('T')[0],
        'appointment_time':
            '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}:00',
        'symptoms': symptoms,
        'consultation_type': consultationType,
        'duration_minutes': durationMinutes,
      };

      if (patientId != null) {
        reqData['patient_id'] = patientId;
      }

      final response = await ApiService.request(
        endpoint: 'api/appointments/create.php',
        method: 'POST',
        data: reqData,
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

  static Future<Map<String, dynamic>> rateDoctor({
    required int doctorId,
    required int rating,
    String? reviewText,
    int? appointmentId,
  }) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/doctors/rate.php',
        method: 'POST',
        data: {
          'doctor_id': doctorId,
          'rating': rating,
          'review_text': reviewText,
          'appointment_id': appointmentId,
        },
        requiresAuth: true,
      );
      return ApiService.handleResponse(response);
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
    int? patientId,
    String? description,
    String? diagnosis,
    String? treatment,
    String? medications,
    int? appointmentId,
  }) async {
    try {
      final Map<String, dynamic> reqData = {
        'doctor_id': doctorId,
        'record_type': recordType,
        'title': title,
        'description': description,
        'diagnosis': diagnosis,
        'treatment': treatment,
        'medications': medications,
        'appointment_id': appointmentId,
        'record_date': DateTime.now().toIso8601String().split('T')[0],
      };

      if (patientId != null) {
        reqData['patient_id'] = patientId;
      }

      final response = await ApiService.request(
        endpoint: 'api/medical-records/create.php',
        method: 'POST',
        data: reqData,
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

  static Future<Map<String, dynamic>> getPatientDetails(int id) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/patients/details.php?id=$id',
        method: 'GET',
        requiresAuth: true,
      );
      return ApiService.handleResponse(response);
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

  static Future<Map<String, dynamic>> getReportStats() async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/reports/daily.php',
        method: 'GET',
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

  static Future<Map<String, dynamic>> saveUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/auth/update_profile.php',
        method: 'POST',
        data: {'name': name, 'email': email, 'phone': phone},
        requiresAuth: true,
      );
      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> saveProfileImage(
    String? imagePath, {
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      final response = await ApiService.uploadFile(
        endpoint: 'api/auth/update_profile_image.php',
        filePath: imagePath,
        bytes: bytes,
        fileName: fileName,
        fileField: 'image',
      );
      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> saveMedicalRecord(
    String title,
    String? filePath, {
    Uint8List? bytes,
    String recordType = 'test_result',
    int? doctorId,
  }) async {
    try {
      final response = await ApiService.uploadFile(
        endpoint: 'api/medical-records/create.php',
        filePath: filePath,
        bytes: bytes,
        fileName: title,
        fileField: 'file',
        fields: {
          'title': title,
          'record_type': recordType,
          if (doctorId != null) 'doctor_id': doctorId.toString(),
        },
      );
      return ApiService.handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<MedicalRecord>> getMedicalRecords() async {
    try {
      final result = await getPatientRecords();
      if (result['success']) {
        return result['records'] as List<MedicalRecord>;
      }
      return [];
    } catch (e) {
      return [];
    }
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
