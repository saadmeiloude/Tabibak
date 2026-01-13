import '../core/models/enums.dart';

class Patient {
  final int id;
  final int userId;
  final String? phone;
  final DateTime? birthDate;
  final int? age;
  final Gender? gender;
  final BloodType? bloodType;
  final String? profileImage;
  final String? address;
  final String? city;
  final String? country;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final List<String> medicalHistory;
  final List<String> allergies;
  final List<String> currentMedications;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final PatientStatus status;
  final DateTime? lastVisit;
  final DateTime? nextAppointment;
  final int totalVisits;
  final int totalAppointments;
  final String? assignedDoctor;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.userId,
    this.phone,
    this.birthDate,
    this.age,
    this.gender,
    this.bloodType,
    this.profileImage,
    this.address,
    this.city,
    this.country,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalHistory = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.insuranceProvider,
    this.insuranceNumber,
    this.status = PatientStatus.active,
    this.lastVisit,
    this.nextAppointment,
    this.totalVisits = 0,
    this.totalAppointments = 0,
    this.assignedDoctor,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Helper to get value from either camelCase or snake_case
    dynamic get(String camelKey, String snakeKey) => json[camelKey] ?? json[snakeKey];

    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    int? parseIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Patient(
      id: parseInt(get('id', 'id')),
      userId: parseInt(get('userId', 'user_id')),
      phone: get('phone', 'phone')?.toString(),
      birthDate: get('birthDate', 'birth_date') != null ? DateTime.tryParse(get('birthDate', 'birth_date').toString()) : null,
      age: parseIntOrNull(get('age', 'age')),
      gender: get('gender', 'gender') != null 
          ? Gender.values.firstWhere((e) => e.toString().split('.').last.toUpperCase() == get('gender', 'gender').toString().toUpperCase(),
              orElse: () => Gender.other)
          : null,
      bloodType: get('bloodType', 'blood_type') != null
          ? BloodType.values.firstWhere((e) => e.toString().split('.').last.toUpperCase() == get('bloodType', 'blood_type').toString().toUpperCase().replaceAll('_', ''),
              orElse: () => BloodType.oPositive)
          : null,
      profileImage: (get('profileImage', 'profile_image') ?? get('avatarUrl', 'avatar_url'))?.toString(),
      address: get('address', 'address')?.toString(),
      city: get('city', 'city')?.toString(),
      country: get('country', 'country')?.toString(),
      emergencyContactName: get('emergencyContactName', 'emergency_contact_name')?.toString(),
      emergencyContactPhone: get('emergencyContactPhone', 'emergency_contact_phone')?.toString(),
      medicalHistory: get('medicalHistory', 'medical_history') != null 
          ? List<String>.from(get('medicalHistory', 'medical_history') as Iterable) 
          : [],
      allergies: get('allergies', 'allergies') != null 
          ? List<String>.from(get('allergies', 'allergies') as Iterable) 
          : [],
      currentMedications: get('currentMedications', 'current_medications') != null 
          ? List<String>.from(get('currentMedications', 'current_medications') as Iterable) 
          : [],
      insuranceProvider: get('insuranceProvider', 'insurance_provider')?.toString(),
      insuranceNumber: get('insuranceNumber', 'insurance_number')?.toString(),
      status: get('status', 'status') != null
          ? PatientStatus.values.firstWhere((e) => e.toString().split('.').last.toUpperCase() == get('status', 'status').toString().toUpperCase(),
              orElse: () => PatientStatus.active)
          : PatientStatus.active,
      lastVisit: get('lastVisit', 'last_visit') != null ? DateTime.tryParse(get('lastVisit', 'last_visit').toString()) : null,
      nextAppointment: get('nextAppointment', 'next_appointment') != null ? DateTime.tryParse(get('nextAppointment', 'next_appointment').toString()) : null,
      totalVisits: parseInt(get('totalVisits', 'total_visits')),
      totalAppointments: parseInt(get('totalAppointments', 'total_appointments')),
      assignedDoctor: get('assignedDoctor', 'assigned_doctor')?.toString(),
      notes: get('notes', 'notes')?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : 
                (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now() : 
                (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String().split('T')[0],
      'age': age,
      'gender': gender?.toString().split('.').last.toUpperCase(),
      'bloodType': bloodType?.toString().split('.').last.toUpperCase(),
      'profileImage': profileImage,
      'address': address,
      'city': city,
      'country': country,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'status': status.toString().split('.').last.toUpperCase(),
      'lastVisit': lastVisit?.toIso8601String(),
      'nextAppointment': nextAppointment?.toIso8601String(),
      'totalVisits': totalVisits,
      'totalAppointments': totalAppointments,
      'assignedDoctor': assignedDoctor,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
