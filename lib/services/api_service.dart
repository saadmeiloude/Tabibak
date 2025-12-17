import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For web/chrome, use your computer's IP address
  // Replace '192.168.1.100' with your actual IP address
  static const String baseUrl = 'http://localhost:8000';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Store token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Generic HTTP request method
  static Future<http.Response> request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization header if required
    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response;
    } catch (e) {
      // For web, provide more helpful error messages
      if (e.toString().contains('Connection refused')) {
        throw Exception(
          'Cannot connect to backend. Please check:\n'
          '1. PHP server is running on port 8000\n'
          '2. MySQL is running and database exists\n'
          '3. Database tables are created\n'
          '4. Chrome browser allows localhost connections',
        );
      }
      rethrow;
    }
  }

  // Handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'API request failed');
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Helper method to update IP address for different environments
  static void updateBaseUrl(String newUrl) {
    // This method can be called to update the base URL dynamically
    // if needed for different environments
  }
}
