import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'models.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final bool? isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
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
  final List<String>? medicalHistory;
  final List<String>? allergies;
  final List<String>? currentMedications;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final PatientStatus? status;
  final DateTime? lastVisit;
  final DateTime? nextAppointment;
  final int? totalVisits;
  final int? totalAppointments;
  final String? assignedDoctor; // ID or Name? UML says String
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    this.medicalHistory,
    this.allergies,
    this.currentMedications,
    this.insuranceProvider,
    this.insuranceNumber,
    this.status,
    this.lastVisit,
    this.nextAppointment,
    this.totalVisits,
    this.totalAppointments,
    this.assignedDoctor,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}

@JsonSerializable()
class Doctor {
  final int id;
  final int userId;
  final String email;
  final String name;
  final String specialty;
  final String? location;
  final double? rating;
  final int? reviewCount;
  final String? profileImage;
  final String? qualifications;
  final int? experienceYears;
  final String? bio;
  final String? clinicAddress;
  final double? consultationFee;
  final bool? isAvailable;
  final bool? isVerified;
  final String? licenseNumber;
  final String? licenseAuthority;
  final String? medicalSchool;
  final int? graduationYear;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Doctor({
    required this.id,
    required this.userId,
    required this.email,
    required this.name,
    required this.specialty,
    this.location,
    this.rating,
    this.reviewCount,
    this.profileImage,
    this.qualifications,
    this.experienceYears,
    this.bio,
    this.clinicAddress,
    this.consultationFee,
    this.isAvailable,
    this.isVerified,
    this.licenseNumber,
    this.licenseAuthority,
    this.medicalSchool,
    this.graduationYear,
    this.phone,
    required this.createdAt,
    this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}
