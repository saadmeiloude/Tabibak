import '../core/models/enums.dart';

class Appointment {
  final int id;
  final int? patientId;
  final int? doctorId;
  final String? patientName;
  final String? patientPhoto;
  final String? doctorName;
  final String? department;
  final String? specialty;
  final DateTime appointmentDate;
  final String time;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    this.patientId,
    this.doctorId,
    this.patientName,
    this.patientPhoto,
    this.doctorName,
    this.department,
    this.specialty,
    required this.appointmentDate,
    required this.time,
    this.status = AppointmentStatus.pending,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
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

    return Appointment(
      id: parseInt(get('id', 'id')),
      patientId: parseIntOrNull(get('patientId', 'patient_id')),
      doctorId: parseIntOrNull(get('doctorId', 'doctor_id')),
      patientName: ((){
          // 1. Direct keys at top level
          final direct = get('patientName', 'patient_name') ?? 
                        get('patient_full_name', 'patientFullName');
          if (direct != null && direct.toString().isNotEmpty) return direct.toString();
          
          // 2. Concatenated keys at top level
          final fName = get('patientFirstName', 'patient_first_name');
          final lName = get('patientLastName', 'patient_last_name');
          if (fName != null || lName != null) {
            return '${fName ?? ''} ${lName ?? ''}'.trim();
          }

          // 3. Nested 'patient' object
          if (json['patient'] is Map) {
            final p = json['patient'];
            // 3a. Direct name in patient
            if (p['name'] != null) return p['name'].toString();
            if (p['full_name'] != null) return p['full_name'].toString();
            if (p['fullName'] != null) return p['fullName'].toString();
            
            // 3b. firstName/lastName in patient
            if (p['first_name'] != null || p['last_name'] != null) {
               return '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim();
            }
            if (p['firstName'] != null || p['lastName'] != null) {
               return '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim();
            }
            
            // 3c. Nested 'user' in patient
            if (p['user'] is Map) {
               final u = p['user'];
               if (u['name'] != null) return u['name'].toString();
               if (u['full_name'] != null) return u['full_name'].toString();
               if (u['fullName'] != null) return u['fullName'].toString();
               
               if (u['first_name'] != null || u['last_name'] != null) {
                 return '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
               }
               if (u['firstName'] != null || u['lastName'] != null) {
                 return '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
               }
            }
          }
          return null;
      })()?.toString(),
      patientPhoto: (get('patientPhoto', 'patient_photo') ?? get('patientAvatar', 'patient_avatar'))?.toString(),
      doctorName: ((){
          // 1. Check nested 'doctor' object
          if (json['doctor'] is Map) {
            final d = json['doctor'];
            // 1a. firstName/lastName in doctor
            if (d['firstName'] != null || d['lastName'] != null) {
              return '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
            }
            if (d['first_name'] != null || d['last_name'] != null) {
              return '${d['first_name'] ?? ''} ${d['last_name'] ?? ''}'.trim();
            }
            // 1b. name/fullName in doctor
            if (d['name'] != null) return d['name'].toString();
            if (d['full_name'] != null) return d['full_name'].toString();
            if (d['fullName'] != null) return d['fullName'].toString();
            
            // 1c. Nested 'user' object in doctor
            if (d['user'] is Map) {
               final u = d['user'];
               if (u['firstName'] != null || u['lastName'] != null) {
                 return '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
               }
               if (u['first_name'] != null || u['last_name'] != null) {
                 return '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
               }
               if (u['name'] != null) return u['name'].toString();
               if (u['full_name'] != null) return u['full_name'].toString();
               if (u['fullName'] != null) return u['fullName'].toString();
            }
          }
          
          // 2. Check top-level doctor fields
          final topLevelName = get('doctorName', 'doctor_name') ?? get('doctor_full_name', 'doctorFullName');
          if (topLevelName != null) return topLevelName.toString();
          
          // 3. Check top-level firstName/lastName
          final topLevelFirst = get('doctorFirstName', 'doctor_first_name');
          final topLevelLast = get('doctorLastName', 'doctor_last_name');
          if (topLevelFirst != null || topLevelLast != null) {
            return '${topLevelFirst ?? ''} ${topLevelLast ?? ''}'.trim();
          }
          
          return null;
      })(),
      department: get('department', 'department')?.toString(),
      specialty: ((){
          final s = get('specialty', 'specialty') ?? get('specialization', 'specialization') ?? 
                   get('doctorSpecialty', 'doctor_specialty') ?? get('doctorSpecialization', 'doctor_specialization');
          if (s != null) return s.toString();
          
          if (json['doctor'] is Map) {
            final ds = json['doctor']['specialty'] ?? json['doctor']['specialization'];
            if (ds != null) return ds.toString();
          }
          return null;
      })(),
      appointmentDate: get('appointmentDate', 'appointment_date') != null 
          ? DateTime.tryParse(get('appointmentDate', 'appointment_date').toString()) ?? DateTime.now()
          : DateTime.now(),
      time: get('time', 'time')?.toString() ?? '00:00',
      status: get('status', 'status') != null
          ? AppointmentStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == get('status', 'status').toString().toUpperCase(),
              orElse: () => AppointmentStatus.pending)
          : AppointmentStatus.pending,
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
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'doctorName': doctorName,
      'department': department,
      'specialty': specialty,
      'appointmentDate': appointmentDate.toIso8601String(),
      'time': time,
      'status': status.toString().split('.').last.toUpperCase(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == AppointmentStatus.pending;
  bool get isConfirmed => status == AppointmentStatus.confirmed;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  
  DateTime get fullDateTime {
    final timeParts = time.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      hour,
      minute,
    );
  }

  // Backward compatibility helpers
  DateTime get appointmentTime => fullDateTime;
  String get consultationType => 'online'; // Default for compatibility
  String? get symptoms => notes; // Map notes to symptoms for compatibility
  double get feePaid => 0.0; // Default for compatibility
}

