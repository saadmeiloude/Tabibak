import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../core/api/api_client.dart';
import '../core/api/token_storage.dart';
import 'package:dio/dio.dart';

class AuthService {
  static const String _userKey = 'user_data';
  final ApiClient _client = ApiClient();

  // --- Static Compatibility Layer ---

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> storeUser(dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user is User) {
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } else if (user is Map<String, dynamic>) {
      await prefs.setString(_userKey, jsonEncode(user));
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await TokenStorage.clearTokens();
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final client = ApiClient();
    try {
      print('DEBUG: Attempting login for $email');
      final response = await client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      print('DEBUG: Login response data keys: ${data.keys}');

      // Handle both pure JSON and Spring Boot standard responses
      final dynamic accessTokenRaw = data['accessToken'] ?? data['token'];
      final dynamic refreshTokenRaw = data['refreshToken'];

      if (accessTokenRaw != null) {
        print('DEBUG: Saving tokens...');
        await TokenStorage.saveTokens(
          accessToken: accessTokenRaw.toString(),
          refreshToken: refreshTokenRaw?.toString() ?? '',
        );
      } else {
        print('DEBUG: Access token is null!');
      }

      // Save User if present
      if (data['user'] != null) {
        print('DEBUG: Parsing user data: ${data['user']}');
        try {
          final user = User.fromJson(data['user']);
          print('DEBUG: User parsed successfully: ${user.fullName}');
          await storeUser(user);
        } catch (e) {
          print('DEBUG: User parsing failed: $e');
          // Don't fail login if user parsing fails, just don't store local user yet
        }
      } else {
        print('DEBUG: No user object in login response');
      }

      return {'success': true, 'data': data, 'user': data['user']};
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String verificationMethod,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? emergencyContact,
  }) async {
    final client = ApiClient();
    // Split full name into first and last name
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'verification_method': verificationMethod,
      'date_of_birth': dateOfBirth,
      'gender': gender?.toUpperCase(),
      'address': address,
      'emergency_contact': emergencyContact,
      'role': 'PATIENT',
    };

    try {
      print('Sending registration request to /auth/register with data: $data');
      final response = await client.post('/auth/register', data: data);
      print('Registration response: ${response.statusCode} - ${response.data}');

      return {'success': true, 'data': response.data, 'message': 'Registration successful'};
    } catch (e) {
      print('Registration Error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (errorMessage.contains('Duplicate entry') || errorMessage.contains('already exists')) {
        errorMessage = 'This email is already registered. Please login instead.';
      }
      
      return {
        'success': false,
        'message': errorMessage
      };
    }
  }

  static Future<Map<String, dynamic>> registerDoctor({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String licenseNumber,
    required String specialization,
    required double consultationFee,
    required int experienceYears,
  }) async {
    final client = ApiClient();
    // Split full name into first and last name
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'license_number': licenseNumber,
      'specialty': specialization,
      'consultation_fee': consultationFee,
      'experience_years': experienceYears,
      'role': 'DOCTOR',
    };

    try {
      final response = await client.post('/auth/register-doctor', data: data);
      return {'success': true, 'data': response.data};
    } catch (e) {
      print('Doctor registration error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithSocial(
    String provider, 
    String email, 
    String displayName
  ) async {
     final client = ApiClient();
    try {
      final response = await client.dio.post('/auth/social-login', data: {

        'provider': provider,
        'email': email,
        'name': displayName
      });
      
      final data = response.data;
      if (data['accessToken'] != null) {
         await TokenStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'] ?? '',
        );
      }
      
      if (data['user'] != null) {
        await storeUser(User.fromJson(data['user']));
      }

      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- Instance Methods (New Architecture) ---
  
  // kept for future use if we switch to instance-based injection
}
