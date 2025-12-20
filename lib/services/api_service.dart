import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  // Upload file method
  static Future<http.Response> uploadFile({
    required String endpoint,
    String? filePath,
    Uint8List? bytes,
    String? fileName,
    String fileField = 'file',
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest('POST', uri);

    // Add authorization header if required
    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Add fields if any
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Add file
    if (bytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          bytes,
          filename: fileName,
          contentType: _getMediaType(fileName),
        ),
      );
    } else if (filePath != null) {
      // Note: fromPath is not supported on Web
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    try {
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
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

  static MediaType? _getMediaType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
