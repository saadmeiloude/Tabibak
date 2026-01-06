class Doctor {
  final int id;
  final int userId;
  final String? name; // Doctor's full name from users table
  final String licenseNumber;
  final String specialization;
  final int experienceYears;
  final String? education;
  final String? certifications;
  final double consultationFee;
  final String? availabilitySchedule;
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.userId,
    this.name,
    required this.licenseNumber,
    required this.specialization,
    required this.experienceYears,
    this.education,
    this.certifications,
    required this.consultationFee,
    this.availabilitySchedule,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Helper for safe double parsing
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return Doctor(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      name: json['name'],
      licenseNumber: json['license_number'],
      specialization: json['specialization'],
      experienceYears: int.parse((json['experience_years'] ?? 0).toString()),
      education: json['education'],
      certifications: json['certifications'],
      consultationFee: parseDouble(json['consultation_fee']),
      availabilitySchedule: json['availability_schedule'],
      rating: parseDouble(json['rating']),
      totalReviews: int.parse((json['total_reviews'] ?? 0).toString()),
      isAvailable:
          json['is_available'] == 1 ||
          json['is_available'] == '1' ||
          json['is_available'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'license_number': licenseNumber,
      'specialization': specialization,
      'experience_years': experienceYears,
      'education': education,
      'certifications': certifications,
      'consultation_fee': consultationFee,
      'availability_schedule': availabilitySchedule,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
