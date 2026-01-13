import '../core/models/enums.dart';

class Department {
  final int id;
  final String name;
  final String? icon;
  final DepartmentStatus status;
  final int bedsTotal;
  final int bedsOccupied;
  final String? description;
  final int? headDoctorId;
  final int patientsCount;
  final int doctorsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    required this.id,
    required this.name,
    this.icon,
    this.status = DepartmentStatus.active,
    this.bedsTotal = 0,
    this.bedsOccupied = 0,
    this.description,
    this.headDoctorId,
    this.patientsCount = 0,
    this.doctorsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      icon: json['icon'],
      status: json['status'] != null
          ? DepartmentStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['status'].toString().toUpperCase(),
              orElse: () => DepartmentStatus.active)
          : DepartmentStatus.active,
      bedsTotal: json['bedsTotal'] != null ? int.parse(json['bedsTotal'].toString()) : 0,
      bedsOccupied: json['bedsOccupied'] != null ? int.parse(json['bedsOccupied'].toString()) : 0,
      description: json['description'],
      headDoctorId: json['headDoctorId'] != null ? int.parse(json['headDoctorId'].toString()) : null,
      patientsCount: json['patientsCount'] != null ? int.parse(json['patientsCount'].toString()) : 0,
      doctorsCount: json['doctorsCount'] != null ? int.parse(json['doctorsCount'].toString()) : 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'status': status.toString().split('.').last.toUpperCase(),
      'bedsTotal': bedsTotal,
      'bedsOccupied': bedsOccupied,
      'description': description,
      'headDoctorId': headDoctorId,
      'patientsCount': patientsCount,
      'doctorsCount': doctorsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get bedsAvailable => bedsTotal - bedsOccupied;
  double get occupancyRate => bedsTotal > 0 ? (bedsOccupied / bedsTotal) * 100 : 0;
}
