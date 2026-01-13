import '../core/models/enums.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final UserRole role;
  final String? address;
  final String? emergencyContact;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String verificationMethod;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.role = UserRole.patient,
    this.address,
    this.emergencyContact,
    this.gender,
    this.dateOfBirth,
    this.verificationMethod = 'email',
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to get value from either camelCase or snake_case
    dynamic get(String camelKey, String snakeKey) => json[camelKey] ?? json[snakeKey];

    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return User(
      id: parseInt(get('id', 'id')),
      firstName: get('firstName', 'first_name')?.toString() ?? '',
      lastName: get('lastName', 'last_name')?.toString() ?? '',
      email: get('email', 'email')?.toString() ?? '',
      avatarUrl: get('avatarUrl', 'avatar_url')?.toString(),
      phone: get('phone', 'phone')?.toString(),
      role: (get('role', 'role') != null)
          ? UserRole.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == get('role', 'role').toString().toUpperCase(),
              orElse: () => UserRole.patient)
          : UserRole.patient,
      address: get('address', 'address')?.toString(),
      emergencyContact: get('emergencyContact', 'emergency_contact')?.toString(),
      gender: get('gender', 'gender') != null
          ? Gender.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == get('gender', 'gender').toString().toUpperCase(),
              orElse: () => Gender.other)
          : null,
      dateOfBirth: get('dateOfBirth', 'date_of_birth') != null 
          ? DateTime.tryParse(get('dateOfBirth', 'date_of_birth').toString()) : null,
      verificationMethod: get('verificationMethod', 'verification_method')?.toString() ?? 'email',
      isVerified: json['isVerified'] == true || json['isVerified'] == 1 || 
                 json['is_verified'] == true || json['is_verified'] == 1 ||
                 json['verified'] == true || json['verified'] == 1,
      isActive: json['isActive'] == true || json['isActive'] == 1 || 
                json['is_active'] == true || json['is_active'] == 1 ||
                json['active'] == true || json['active'] == 1,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : 
                (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now() : 
                (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'role': role.toString().split('.').last.toUpperCase(),
      'address': address,
      'emergencyContact': emergencyContact,
      'gender': gender?.toString().split('.').last.toUpperCase(),
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
      'verificationMethod': verificationMethod,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isDoctor => role == UserRole.doctor;
  bool get isPatient => role == UserRole.patient;
  bool get isAdmin => role == UserRole.admin;
  
  // Backward compatibility
  String get profileImage => avatarUrl ?? '';
  String get userType => role == UserRole.doctor ? 'doctor' : 'patient';
}


