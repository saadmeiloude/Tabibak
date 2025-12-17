import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Web-compatible base URL
  static String get baseUrl {
    // For web, use your computer's IP address
    // Replace '192.168.1.100' with your actual IP address
    return 'http://192.168.1.100/tabibek/backend/api';
  }

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
          '1. Wampserver is running\n'
          '2. Backend files are in C:\\wamp64\\www\\tabibek\\\n'
          '3. Your IP address is correct in the baseUrl\n'
          '4. MySQL service is running',
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

  // Helper method to detect if running on web
  static bool get isWeb {
    return identical(0, 0.0); // Simple web detection
  }

  // Get your computer's IP address for web testing
  static String getLocalIpAddress() {
    // This is a placeholder - you need to find your actual IP
    // Common formats: 192.168.x.x or 10.0.x.x
    return '192.168.1.100'; // Replace with your actual IP
  }
}
