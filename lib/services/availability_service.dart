import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/time_slot.dart';

class AvailabilityService {
  final ApiClient _client = ApiClient();

  /// Get doctor availability for a date range
  Future<Map<String, dynamic>> getDoctorAvailability({
    required int doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client.get(
        '/doctors/$doctorId/availability',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final availabilityList = data['availability'] as List? ?? [];
        final availability = availabilityList
            .map((json) => DoctorAvailability.fromJson(json))
            .toList();

        return {
          'success': true,
          'availability': availability,
        };
      }
      throw Exception('Server returned ${response.statusCode}');
    } catch (e) {
      print('Get doctor availability error (Backend not ready): $e');
      
      // FALLBACK: Return empty availability list for now
      return {
        'success': true,
        'availability': <DoctorAvailability>[],
        'isMock': true
      };
    }
  }

  /// Add/update doctor availability (for doctors)
  Future<Map<String, dynamic>> setDoctorAvailability({
    required int doctorId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required int slotDuration,
    List<Map<String, String>>? breakTimes,
  }) async {
    try {
      final response = await _client.post(
        '/doctors/$doctorId/availability',
        data: {
          'dayOfWeek': dayOfWeek,
          'startTime': startTime,
          'endTime': endTime,
          'slotDuration': slotDuration,
          'breakTimes': breakTimes ?? [],
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Availability created',
          'slotsCreated': response.data['slotsCreated'] ?? 0,
        };
      }

      return {
        'success': false,
        'message': 'Failed to set availability',
      };
    } catch (e) {
      print('Set doctor availability error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get available time slots for a specific date
  Future<List<TimeSlot>> getAvailableSlotsForDate({
    required int doctorId,
    required DateTime date,
  }) async {
    try {
      final result = await getDoctorAvailability(
        doctorId: doctorId,
        startDate: date,
        endDate: date,
      );

      if (result['success'] && result['availability'] != null) {
        final List<DoctorAvailability> availability =
            result['availability'] as List<DoctorAvailability>;

        if (availability.isNotEmpty) {
          return availability.first.slots;
        }
      }

      return [];
    } catch (e) {
      print('Get available slots error: $e');
      return [];
    }
  }
}
