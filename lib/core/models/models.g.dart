// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  isActive: json['isActive'] as bool?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'role': _$UserRoleEnumMap[instance.role]!,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.patient: 'PATIENT',
  UserRole.doctor: 'DOCTOR',
  UserRole.admin: 'ADMIN',
  UserRole.staff: 'STAFF',
};

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  phone: json['phone'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  age: (json['age'] as num?)?.toInt(),
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  bloodType: $enumDecodeNullable(_$BloodTypeEnumMap, json['bloodType']),
  profileImage: json['profileImage'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  emergencyContactName: json['emergencyContactName'] as String?,
  emergencyContactPhone: json['emergencyContactPhone'] as String?,
  medicalHistory: (json['medicalHistory'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  allergies: (json['allergies'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  currentMedications: (json['currentMedications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  insuranceProvider: json['insuranceProvider'] as String?,
  insuranceNumber: json['insuranceNumber'] as String?,
  status: $enumDecodeNullable(_$PatientStatusEnumMap, json['status']),
  lastVisit: json['lastVisit'] == null
      ? null
      : DateTime.parse(json['lastVisit'] as String),
  nextAppointment: json['nextAppointment'] == null
      ? null
      : DateTime.parse(json['nextAppointment'] as String),
  totalVisits: (json['totalVisits'] as num?)?.toInt(),
  totalAppointments: (json['totalAppointments'] as num?)?.toInt(),
  assignedDoctor: json['assignedDoctor'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'phone': instance.phone,
  'birthDate': instance.birthDate?.toIso8601String(),
  'age': instance.age,
  'gender': _$GenderEnumMap[instance.gender],
  'bloodType': _$BloodTypeEnumMap[instance.bloodType],
  'profileImage': instance.profileImage,
  'address': instance.address,
  'city': instance.city,
  'country': instance.country,
  'emergencyContactName': instance.emergencyContactName,
  'emergencyContactPhone': instance.emergencyContactPhone,
  'medicalHistory': instance.medicalHistory,
  'allergies': instance.allergies,
  'currentMedications': instance.currentMedications,
  'insuranceProvider': instance.insuranceProvider,
  'insuranceNumber': instance.insuranceNumber,
  'status': _$PatientStatusEnumMap[instance.status],
  'lastVisit': instance.lastVisit?.toIso8601String(),
  'nextAppointment': instance.nextAppointment?.toIso8601String(),
  'totalVisits': instance.totalVisits,
  'totalAppointments': instance.totalAppointments,
  'assignedDoctor': instance.assignedDoctor,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$GenderEnumMap = {Gender.male: 'MALE', Gender.female: 'FEMALE'};

const _$BloodTypeEnumMap = {
  BloodType.aPositive: 'A_POSITIVE',
  BloodType.aNegative: 'A_NEGATIVE',
  BloodType.bPositive: 'B_POSITIVE',
  BloodType.bNegative: 'B_NEGATIVE',
  BloodType.oPositive: 'O_POSITIVE',
  BloodType.oNegative: 'O_NEGATIVE',
  BloodType.abPositive: 'AB_POSITIVE',
  BloodType.abNegative: 'AB_NEGATIVE',
};

const _$PatientStatusEnumMap = {
  PatientStatus.active: 'ACTIVE',
  PatientStatus.inactive: 'INACTIVE',
  PatientStatus.banned: 'BANNED',
};

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  email: json['email'] as String,
  name: json['name'] as String,
  specialty: json['specialty'] as String,
  location: json['location'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  profileImage: json['profileImage'] as String?,
  qualifications: json['qualifications'] as String?,
  experienceYears: (json['experienceYears'] as num?)?.toInt(),
  bio: json['bio'] as String?,
  clinicAddress: json['clinicAddress'] as String?,
  consultationFee: (json['consultationFee'] as num?)?.toDouble(),
  isAvailable: json['isAvailable'] as bool?,
  isVerified: json['isVerified'] as bool?,
  licenseNumber: json['licenseNumber'] as String?,
  licenseAuthority: json['licenseAuthority'] as String?,
  medicalSchool: json['medicalSchool'] as String?,
  graduationYear: (json['graduationYear'] as num?)?.toInt(),
  phone: json['phone'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'email': instance.email,
  'name': instance.name,
  'specialty': instance.specialty,
  'location': instance.location,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'profileImage': instance.profileImage,
  'qualifications': instance.qualifications,
  'experienceYears': instance.experienceYears,
  'bio': instance.bio,
  'clinicAddress': instance.clinicAddress,
  'consultationFee': instance.consultationFee,
  'isAvailable': instance.isAvailable,
  'isVerified': instance.isVerified,
  'licenseNumber': instance.licenseNumber,
  'licenseAuthority': instance.licenseAuthority,
  'medicalSchool': instance.medicalSchool,
  'graduationYear': instance.graduationYear,
  'phone': instance.phone,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
