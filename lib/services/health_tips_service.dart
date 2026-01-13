import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/health_tip.dart';

class HealthTipsService {
  final ApiClient _client = ApiClient();

  /// Get the health tip of the day
  Future<Map<String, dynamic>> getDailyTip() async {
    try {
      final response = await _client.get('/health-tips/daily');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'tip': HealthTip.fromJson(response.data['tip']),
        };
      }

      return {
        'success': false,
        'message': 'Failed to load daily tip',
      };
    } catch (e) {
      print('Get daily tip error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get all health tips (with optional filtering)
  Future<Map<String, dynamic>> getAllTips({
    String? category,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      if (category != null) {
        queryParams['category'] = category;
      }

      final response = await _client.get(
        '/health-tips',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tips = (data['tips'] as List)
            .map((json) => HealthTip.fromJson(json))
            .toList();

        return {
          'success': true,
          'tips': tips,
          'totalCount': data['totalCount'] ?? tips.length,
        };
      }

      return {
        'success': false,
        'message': 'Failed to load health tips',
      };
    } catch (e) {
      print('Get all tips error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
