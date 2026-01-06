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
