class Doctor {
  final int id;
  final int userId;
  final String? email;
  final String? name;
  final String? specialty;
  final String? location;
  final double rating;
  final int reviewCount;
  final String? profileImage;
  final String? qualifications;
  final int experienceYears;
  final String? bio;
  final String? clinicAddress;
  final double consultationFee;
  final bool isAvailable;
  final bool isVerified;
  final String licenseNumber;
  final String? licenseAuthority;
  final String? medicalSchool;
  final int? graduationYear;
  final String? phone;
  final String? education;
  final String? certifications;
  final String? availabilitySchedule;
  final int? departmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.userId,
    this.email,
    this.name,
    this.specialty,
    this.location,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.profileImage,
    this.qualifications,
    this.experienceYears = 0,
    this.bio,
    this.clinicAddress,
    this.consultationFee = 0.0,
    this.isAvailable = true,
    this.isVerified = false,
    required this.licenseNumber,
    this.licenseAuthority,
    this.medicalSchool,
    this.graduationYear,
    this.phone,
    this.education,
    this.certifications,
    this.availabilitySchedule,
    this.departmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Helper to get value from either camelCase or snake_case
    dynamic get(String camelKey, String snakeKey) => json[camelKey] ?? json[snakeKey];

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

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

    return Doctor(
      id: parseInt(get('id', 'id')),
      userId: parseInt(get('userId', 'user_id')),
      email: get('email', 'email')?.toString() ?? '',
      name: get('name', 'name')?.toString() ?? 'Dr. Unknown',
      specialty: (get('specialty', 'specialty') ?? get('specialization', 'specialization'))?.toString() ?? 'General',
      location: get('location', 'location')?.toString() ?? '',
      rating: parseDouble(get('rating', 'rating')),
      reviewCount: parseInt(get('reviewCount', 'review_count')),
      profileImage: (get('profileImage', 'profile_image') ?? get('avatarUrl', 'avatar_url'))?.toString(),
      qualifications: get('qualifications', 'qualifications')?.toString(),
      experienceYears: parseInt(get('experienceYears', 'experience_years')),
      bio: get('bio', 'bio')?.toString(),
      clinicAddress: get('clinicAddress', 'clinic_address')?.toString(),
      consultationFee: parseDouble(get('consultationFee', 'consultation_fee')),
      isAvailable: json['isAvailable'] == true || json['isAvailable'] == 1 || 
                  json['is_available'] == true || json['is_available'] == 1,
      isVerified: json['isVerified'] == true || json['isVerified'] == 1 ||
                 json['is_verified'] == true || json['is_verified'] == 1,
      licenseNumber: get('licenseNumber', 'license_number')?.toString() ?? '',
      licenseAuthority: get('licenseAuthority', 'license_authority')?.toString(),
      medicalSchool: get('medicalSchool', 'medical_school')?.toString(),
      graduationYear: parseIntOrNull(get('graduationYear', 'graduation_year')),
      phone: get('phone', 'phone')?.toString(),
      education: get('education', 'education')?.toString(),
      certifications: get('certifications', 'certifications')?.toString(),
      availabilitySchedule: get('availabilitySchedule', 'availability_schedule')?.toString(),
      departmentId: parseIntOrNull(get('departmentId', 'department_id')),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : 
                (json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : 
                (json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'name': name,
      'specialty': specialty,
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'profileImage': profileImage,
      'qualifications': qualifications,
      'experienceYears': experienceYears,
      'bio': bio,
      'clinicAddress': clinicAddress,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'licenseNumber': licenseNumber,
      'licenseAuthority': licenseAuthority,
      'medicalSchool': medicalSchool,
      'graduationYear': graduationYear,
      'phone': phone,
      'education': education,
      'certifications': certifications,
      'availabilitySchedule': availabilitySchedule,
      'departmentId': departmentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get yearsOfExperience => experienceYears;
  bool get hasHighRating => rating >= 4.0;
  String get displayName => name ?? 'Dr. Unknown';
  
  // Backward compatibility
  String get specialization => specialty ?? 'General';
  int get totalReviews => reviewCount;
}

