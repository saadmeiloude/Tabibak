import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class User {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String userType;
  final String verificationMethod;
  final bool isVerified;
  final DateTime createdAt;
  final String? profileImage;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContact;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.userType,
    required this.verificationMethod,
    required this.isVerified,
    required this.createdAt,
    this.profileImage,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContact,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['user_type'],
      verificationMethod: json['verification_method'],
      isVerified:
          json['is_verified'] == 1 ||
          json['is_verified'] == '1' ||
          json['is_verified'] == true,
      createdAt: DateTime.parse(json['created_at']),
      profileImage: json['profile_image'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'verification_method': verificationMethod,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'profile_image': profileImage,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'emergency_contact': emergencyContact,
    };
  }
}

class AuthService {
  static const String _userKey = 'current_user';

  // Store user data locally
  static Future<void> storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Get stored user data
  static Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Remove stored user data
  static Future<void> removeStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/auth/login.php',
        method: 'POST',
        data: {'email': email, 'password': password},
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        // Store token and user data
        await ApiService.storeToken(result['data']['token']);
        final user = User.fromJson(result['data']['user']);
        await storeUser(user);

        return {'success': true, 'user': user, 'message': result['message']};
      } else {
        return {'success': false, 'message': result['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Register user
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
    try {
      final response = await ApiService.request(
        endpoint: 'api/auth/register.php',
        method: 'POST',
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'verification_method': verificationMethod,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'address': address,
          'emergency_contact': emergencyContact,
        },
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final user = User.fromJson(result['data']['user']);

        return {
          'success': true,
          'user': user,
          'message': result['message'],
          'verification_required': result['data']['verification_required'],
          'verification_method': result['data']['verification_method'],
        };
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        await ApiService.request(
          endpoint: 'api/auth/logout.php',
          method: 'POST',
          data: {'token': token},
        );
      }

      // Clear stored data
      await ApiService.removeToken();
      await removeStoredUser();

      return {'success': true, 'message': 'Logout successful'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    final user = await getStoredUser();
    return token != null && user != null;
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    return await getStoredUser();
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? emergencyContact,
  }) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/user/profile.php',
        method: 'PUT',
        data: {
          'full_name': fullName,
          'phone': phone,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'address': address,
          'emergency_contact': emergencyContact,
        },
        requiresAuth: true,
      );

      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final user = User.fromJson(result['data']['user']);
        await storeUser(user);

        return {'success': true, 'user': user, 'message': result['message']};
      } else {
        return {
          'success': false,
          'message': result['error'] ?? 'Profile update failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
