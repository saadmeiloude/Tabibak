class TimeSlot {
  final int id;
  final String startTime; // HH:mm format
  final String endTime;
  final bool isAvailable;
  final bool isBooked;
  final int? appointmentId;
  final String? reason; // BREAK, UNAVAILABLE, etc.

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.isBooked = false,
    this.appointmentId,
    this.reason,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as int,
      startTime: json['startTime'] ?? json['start_time'] as String,
      endTime: json['endTime'] ?? json['end_time'] as String,
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      isBooked: json['isBooked'] ?? json['is_booked'] ?? false,
      appointmentId: json['appointmentId'] ?? json['appointment_id'] as int?,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'isBooked': isBooked,
      'appointmentId': appointmentId,
      'reason': reason,
    };
  }

  bool get canBook => isAvailable && !isBooked;
}

class DoctorAvailability {
  final String date; // ISO 8601 date
  final String dayOfWeek; // MONDAY, TUESDAY, etc.
  final List<TimeSlot> slots;

  DoctorAvailability({
    required this.date,
    required this.dayOfWeek,
    required this.slots,
  });

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      date: json['date'] as String,
      dayOfWeek: json['dayOfWeek'] ?? json['day_of_week'] as String,
      slots: (json['slots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayOfWeek': dayOfWeek,
      'slots': slots.map((slot) => slot.toJson()).toList(),
    };
  }

  List<TimeSlot> get availableSlots => slots.where((slot) => slot.canBook).toList();
  int get totalSlots => slots.length;
  int get bookedSlots => slots.where((slot) => slot.isBooked).toList().length;
}
