import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/exceptions/api_exception.dart';
import '../services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/medical_record.dart';
import '../models/article.dart';

class DataService {
  // Initialization
  static Future<void> init() async {
    // API-based service, no local initialization needed
  }

  // Get doctor dashboard stats
  static Future<Map<String, dynamic>> getDoctorDashboardStats() async {
    try {
      final response = await ApiClient().get('/doctor/dashboard/stats');
      return {'success': true, 'data': response.data};
    } catch (e) {
      print('DEBUG: getDoctorDashboardStats failed ($e). Returning empty stats to trigger local fallback.');
      // Return success but empty stats so UI calculates from lists
      return {
        'success': true, 
        'data': {
          'stats': {
            'todayAppointments': 0,
            'newPatients': 0,
            'totalPatients': 0,
            'totalEarnings': 0,
          }
        }
      };
    }
  }


  // Update doctor profile
  static Future<Map<String, dynamic>> updateDoctorProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      // Map UI keys (snake_case) to API keys (camelCase)
      final Map<String, dynamic> apiData = {};
      data.forEach((key, value) {
        if (key == 'first_name') apiData['firstName'] = value;
        else if (key == 'last_name') apiData['lastName'] = value;
        else if (key == 'clinic_address') apiData['clinicAddress'] = value;
        else if (key == 'experience_years') apiData['experienceYears'] = value;
        else if (key == 'consultation_fee') apiData['consultationFee'] = value;
        else if (key == 'specialty' || key == 'specialization') apiData['specialty'] = value;
        else apiData[key] = value;
      });

      final response = await ApiClient().put('/doctors/profile', data: apiData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceAll('Exception: ', '')};
    }
  }

  // ==================== APPOINTMENT SERVICES ====================

  /// Create a new appointment (camelCase mapping)
  static Future<Map<String, dynamic>> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
    String? notes,
    int? patientId,
    String? doctorName,
    String? patientName,
    String? specialty,
    String? department,
    String? patientPhoto,
  }) async {
    try {
      final Map<String, dynamic> reqData = {
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String().split('T')[0],
        'time': "${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}",
        'notes': notes,
        'doctor_name': doctorName,
        'patient_name': patientName,
        'specialty': specialty,
        'department': department,
        'patient_photo': patientPhoto,
        'status': 'SCHEDULED', // Default status for new appointments
      };

      if (patientId != null) {
        reqData['patient_id'] = patientId;
      }

      print('DEBUG: createAppointment payload: $reqData');

      final response = await ApiClient().post('/appointments', data: reqData);
      final appointment = Appointment.fromJson(response.data);

      return {
        'success': true,
        'appointment': appointment,
        'message': 'Appointment created successfully',
      };
    } catch (e) {
      print('DEBUG: createAppointment Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Get all user appointments
  static Future<Map<String, dynamic>> getUserAppointments({int? userId}) async {
    try {
      final response = await ApiClient().get(
        '/appointments',
        queryParameters: userId != null ? {'userId': userId} : null,
      );

      // Backend returns List<AppointmentResponseDTO> directly
      final List<dynamic> appointmentsJson = response.data is List
          ? response.data
          : (response.data is Map ? (response.data['data'] ?? []) : []);

      final appointments = appointmentsJson
          .map((json) => json != null ? Appointment.fromJson(json) : null)
          .whereType<Appointment>()
          .toList();

      return {'success': true, 'appointments': appointments};
    } catch (e) {
      print('DEBUG: getUserAppointments Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Cancel appointment
  static Future<Map<String, dynamic>> cancelAppointment(int appointmentId) async {
    try {
      await ApiClient().delete('/appointments/$appointmentId');
      return {'success': true, 'message': 'Appointment cancelled successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Update appointment
  static Future<Map<String, dynamic>> updateAppointment({
    required int appointmentId,
    String? status,
    DateTime? appointmentDate,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (status != null) data['status'] = status.toUpperCase();
      if (appointmentDate != null) {
        data['appointmentDate'] = appointmentDate.toIso8601String();
      }
      if (notes != null) data['notes'] = notes;

      final response = await ApiClient().put(
        '/appointments/$appointmentId',
        data: data,
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // ==================== DOCTOR SERVICES ====================

  /// Get all doctors or filter by specialization
  static Future<Map<String, dynamic>> getDoctors({
    String? specialization,
  }) async {
    try {
      final response = await ApiClient().get(
        '/doctors',
        queryParameters:
            specialization != null ? {'specialization': specialization} : null,
      );

      // Backend returns List<Doctor> directly
      final List<dynamic> doctorsJson = response.data is List
          ? response.data
          : (response.data is Map ? (response.data['data'] ?? []) : []);

      print('DEBUG: getDoctors JSON: $doctorsJson');

      final doctors = doctorsJson
          .map((json) => json != null ? Doctor.fromJson(json) : null)
          .whereType<Doctor>()
          .toList();

      return {'success': true, 'doctors': doctors};
    } catch (e) {
      print('DEBUG: getDoctors Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Get doctor details by ID
  static Future<Map<String, dynamic>> getDoctorDetails(int doctorId) async {
    try {
      final response = await ApiClient().get('/doctors/$doctorId');
      final doctor = Doctor.fromJson(response.data);

      return {'success': true, 'doctor': doctor};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Get current logged-in doctor profile
  static Future<Map<String, dynamic>> getDoctorProfile() async {
    try {
      final response = await ApiClient().get('/doctors/profile');
      final doctor = Doctor.fromJson(response.data);
      return {
        'success': true,
        'doctor': doctor,
        'data': response.data, // For backward compatibility
      };
    } catch (e) {
      print('DEBUG: getDoctorProfile Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Rate a doctor
  static Future<Map<String, dynamic>> rateDoctor({
    required int doctorId,
    required int rating,
    String? reviewText,
    int? appointmentId,
  }) async {
    try {
      final response = await ApiClient().post(
        '/doctors/$doctorId/rate',
        data: {
          'rating': rating,
          'reviewText': reviewText,
          'appointmentId': appointmentId,
        },
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // ==================== MEDICAL RECORD SERVICES ====================

  /// Get patient medical records
  static Future<Map<String, dynamic>> getPatientRecords({
    int? patientId,
  }) async {
    try {
      final response = await ApiClient().get(
        '/medical-records',
        queryParameters: patientId != null ? {'patient_id': patientId} : null,
      );

      final List<dynamic> recordsJson = response.data is List
          ? response.data
          : (response.data is Map ? (response.data['data'] ?? []) : []);

      final records = recordsJson
          .map((json) => json != null ? MedicalRecord.fromJson(json) : null)
          .whereType<MedicalRecord>()
          .toList();

      return {'success': true, 'records': records};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Create medical record
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
      final String today = DateTime.now().toIso8601String().split('T')[0];
      final Map<String, dynamic> reqData = {
        'recordType': recordType.toUpperCase(),
        'record_type': recordType.toUpperCase(),
        'title': title,
        'recordDate': today,
        'record_date': today,
        
        // Relationship fields - trying various formats to bypass mapping ambiguity
        'doctorId': doctorId,
        'doctor_id': doctorId,
        'doctor': {'id': doctorId},
        
        'patientId': patientId,
        'patient_id': patientId,
        'patient': {'id': patientId},
      };

      if (appointmentId != null && appointmentId != 0) {
        reqData['appointmentId'] = appointmentId;
        reqData['appointment_id'] = appointmentId;
        reqData['appointment'] = {'id': appointmentId};
      }

      if (description != null && description.isNotEmpty) reqData['description'] = description;
      if (diagnosis != null && diagnosis.isNotEmpty) reqData['diagnosis'] = diagnosis;
      if (treatment != null && treatment.isNotEmpty) reqData['treatment'] = treatment;
      if (medications != null && medications.isNotEmpty) reqData['medications'] = medications;

      print('DEBUG: createMedicalRecord robust payload: $reqData');

      final response = await ApiClient().post('/medical-records', data: reqData);
      final record = MedicalRecord.fromJson(response.data);

      return {
        'success': true,
        'record': record,
        'message': 'Medical record created successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // ==================== PATIENT SERVICES ====================

  /// Get all patients
  static Future<Map<String, dynamic>> getPatients() async {
    try {
      final response = await ApiClient().get('/patients');

      final List<dynamic> patientsJson = response.data is List
          ? response.data
          : (response.data is Map ? (response.data['data'] ?? []) : []);

      return {'success': true, 'patients': patientsJson};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Get patient details
  static Future<Map<String, dynamic>> getPatientDetails(int id) async {
    try {
      final response = await ApiClient().get('/patients/$id');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Get patient ID by User ID
  static Future<int?> getPatientIdByUserId(int userId) async {
    try {
      final response = await ApiClient().get('/patients');
      final List<dynamic> patients = response.data is List
          ? response.data
          : (response.data is Map ? (response.data['data'] ?? []) : []);

      for (var p in patients) {
        final pUserId = p['userId'] ?? p['user_id'];
        if (pUserId != null &&
            int.tryParse(pUserId.toString()) == userId) {
          return int.tryParse(p['id']?.toString() ?? '');
        }
      }
    } catch (e) {
      print('DEBUG: getPatientIdByUserId error: $e');
    }
    return null;
  }

  /// Save patient (create or update)
  static Future<Map<String, dynamic>> savePatient(
    Map<String, dynamic> patientData,
  ) async {
    try {
      bool isUpdate =
          patientData.containsKey('id') && patientData['id'] != null;

      Response response;
      if (isUpdate) {
        response = await ApiClient()
            .put('/patients/${patientData['id']}', data: patientData);
      } else {
        response = await ApiClient().post('/patients', data: patientData);
      }

      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // ==================== REPORTS ====================

  static Future<Map<String, dynamic>> getReportStats() async {
    try {
      final response = await ApiClient().get('/reports/daily');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await ApiClient().get('/reports/stats');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // ==================== PROFILE & SETTINGS ====================

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
      final trimmedName = name.trim();
      final response = await ApiClient().put(
        '/auth/profile',
        data: {
          'name': trimmedName,
          'full_name': trimmedName,
          'fullName': trimmedName,
          'email': email,
          'phone': phone,
        },
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  static Future<Map<String, dynamic>> saveProfileImage(
    String? imagePath, {
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      final formData = FormData.fromMap({
        'userId': currentUser?.id,
        'user_id': currentUser?.id,
      });

      if (bytes != null) {
        final multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: fileName ?? 'profile.jpg',
        );
        formData.files.add(MapEntry('file', multipartFile));
        // Add duplicate entry with 'image' key
        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(
            bytes,
            filename: fileName ?? 'profile.jpg',
          ),
        ));
      } else if (imagePath != null) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            imagePath,
            filename: fileName,
          ),
        ));
        // Add duplicate entry with 'image' key
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            imagePath,
            filename: fileName,
          ),
        ));
      }

      final response = await ApiClient().post(
        '/auth/profile-image',
        data: formData,
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  static Future<Map<String, dynamic>> saveMedicalRecord(
    String title,
    String? filePath, {
    Uint8List? bytes,
    String recordType = 'TEST_RESULT',
    int? doctorId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'recordType': recordType,
        if (doctorId != null) 'doctorId': doctorId,
      });

      if (bytes != null) {
        formData.files.add(MapEntry(
          'file',
          MultipartFile.fromBytes(bytes, filename: title),
        ));
      } else if (filePath != null) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(filePath, filename: title),
        ));
      }

      final response = await ApiClient().post(
        '/medical-records',
        data: formData,
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
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

  // ==================== ARTICLE SERVICES ====================

  /// Get articles (research)
  static Future<Map<String, dynamic>> getResearch({
    String? category,
    String? search,
    int? doctorId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (doctorId != null) queryParams['doctorId'] = doctorId;

      final response = await ApiClient().get(
        '/articles',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<dynamic> articlesJson = response.data is List
          ? response.data
          : (response.data is Map ? (response.data['data'] ?? []) : []);

      final articles = articlesJson
          .map((json) => json != null ? Article.fromJson(json) : null)
          .whereType<Article>()
          .toList();

      return {'success': true, 'research': articles};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Create article
  static Future<Map<String, dynamic>> createResearch({
    required String title,
    String? summary,
    String? content,
    String? category,
    String? tags,
    bool isPublished = true,
  }) async {
    try {
      final response = await ApiClient().post(
        '/articles',
        data: {
          'title': title,
          'content': content ?? summary,
          'category': category,
          'tags': tags,
          'published': isPublished,
        },
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Update article
  static Future<Map<String, dynamic>> updateResearch({
    required int id,
    String? title,
    String? summary,
    String? content,
    String? category,
    bool? isPublished,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (category != null) data['category'] = category;
      if (isPublished != null) data['published'] = isPublished;

      final response = await ApiClient().put(
        '/articles/$id',
        data: data,
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  /// Delete article
  static Future<Map<String, dynamic>> deleteResearch(int id) async {
    try {
      await ApiClient().delete('/articles/$id');
      return {'success': true, 'message': 'Article deleted successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }
}
