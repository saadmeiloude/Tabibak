import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('PATIENT')
  patient,
  @JsonValue('DOCTOR')
  doctor,
  @JsonValue('ADMIN')
  admin,
}

@JsonSerializable()
class UserModel {
  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String email;
  @JsonKey(name: 'user_type')
  final UserRole role;
  
  // Use String for ISO8601 compatibility or setup a converter if strictly needed,
  // but json_serializable handles DateTime well by default (toIso8601String).
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
