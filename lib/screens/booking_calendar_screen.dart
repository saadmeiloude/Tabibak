import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/colors.dart';
import '../core/constants/mauritanian_constants.dart';
import '../widgets/custom_button.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../services/availability_service.dart';
import '../models/time_slot.dart';
import '../models/appointment.dart';

class BookingCalendarScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;

  const BookingCalendarScreen({super.key, this.doctor});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _repeatBooking = false;
  String _repeatFrequency = 'weekly'; // 'weekly', 'monthly'

  final AvailabilityService _availabilityService = AvailabilityService();
  bool _isLoadingSlots = false;
  final Set<String> _bookedSlots = {};
  List<TimeSlot> _availableSlots = [];

  List<String> _morningSlots = [];
  List<String> _afternoonSlots = [];
  List<String> _eveningSlots = [];

  // ... (keep getters like _daysInMonth, _monthName, _getWeekdayName)
  List<DateTime> get _daysInMonth {
    final first = DateTime(_currentDate.year, _currentDate.month, 1);
    final last = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    return List.generate(
      last.day,
      (index) => DateTime(_currentDate.year, _currentDate.month, index + 1),
    );
  }

  String get _monthName {
    return DateFormat('MMMM yyyy', 'ar').format(_currentDate);
  }

  String _getWeekdayName(int weekday) {
    const days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    return days[weekday % 7];
  }

  bool _isDateAvailable(DateTime date) {
    // Only allow booking for future dates
    return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    final doctorIdRaw = widget.doctor?['id'];
    if (doctorIdRaw == null) return;

    final int doctorId = doctorIdRaw is int
        ? doctorIdRaw
        : int.tryParse(doctorIdRaw.toString()) ?? 0;

    if (doctorId == 0) return;

    // Generate Fixed Slots as requested: 9h-14h and 17h-22h
    // This provides a "fixed" schedule while still allowing backend integration support
    setState(() {
      _isLoadingSlots = true;
      _morningSlots = [];
      _afternoonSlots = [];
      _eveningSlots = [];
      _bookedSlots.clear();
      
      // Morning/Afternoon (9h - 14h)
      for (int h = 9; h < 14; h++) {
        final slot1 = _formatSlotTime("$h:00");
        final slot2 = _formatSlotTime("$h:30");
        
        if (h < 12) {
          _morningSlots.add(slot1);
          _morningSlots.add(slot2);
        } else {
          _afternoonSlots.add(slot1);
          _afternoonSlots.add(slot2);
        }
      }
      
      // Fixed: The user requested up to 14h, let's add 14:00 specifically
      _afternoonSlots.add(_formatSlotTime("14:00"));

      // Evening (17h - 22h)
      for (int h = 17; h < 22; h++) {
        _eveningSlots.add(_formatSlotTime("$h:00"));
        _eveningSlots.add(_formatSlotTime("$h:30"));
      }
      // Add 22:00 specifically
      _eveningSlots.add(_formatSlotTime("22:00"));

      _isLoadingSlots = false;
    });

    try {
      final slots = await _availabilityService.getAvailableSlotsForDate(
        doctorId: doctorId,
        date: date,
      );

      if (mounted) {
        setState(() {
          _availableSlots = slots;
          for (var slot in slots) {
            if (slot.isBooked) {
              _bookedSlots.add(_formatSlotTime(slot.startTime));
            }
          }
        });
      }
    } catch (e) {
      print('Error loading slots from backend: $e');
    }
  }

  String _formatSlotTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour == 0) return '12:$minute ص';
    if (hour < 12) return '$hour:$minute ص';
    if (hour == 12) return '12:$minute م';
    return '${hour - 12}:$minute م';
  }

  bool _isTimeSlotAvailable(DateTime date, String time) {
    // Check if the slot is in the booked set
    return !_bookedSlots.contains(time);
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.doctor?['name'] ?? 'د. أحمد المنصور';
    final doctorSpecialty = widget.doctor?['specialty'] ?? 'استشاري قلب';
    final doctorRating = widget.doctor?['rating'] ?? 4.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حجز موعد'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _shareBooking();
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    doctorSpecialty,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  Text(
                                    '$doctorRating',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calendar Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentDate = DateTime(
                              _currentDate.year,
                              _currentDate.month - 1,
                            );
                            _selectedDate = null;
                            _selectedTime = null;
                          });
                        },
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                      ),
                      Text(
                        _monthName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentDate = DateTime(
                              _currentDate.year,
                              _currentDate.month + 1,
                            );
                            _selectedDate = null;
                            _selectedTime = null;
                          });
                        },
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Calendar Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Week header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (index) {
                            const days = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
                            return Text(
                              days[index],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Calendar days
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _daysInMonth.map((date) {
                            final isSelected = _selectedDate == date;
                            final isAvailable = _isDateAvailable(date);
                            final isToday =
                                date.day == DateTime.now().day &&
                                date.month == DateTime.now().month &&
                                date.year == DateTime.now().year;

                            return GestureDetector(
                              onTap: isAvailable
                                  ? () {
                                      setState(() {
                                        _selectedDate = date;
                                        _selectedTime = null;
                                      });
                                      _loadAvailableSlots(date);
                                    }
                                  : null,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isToday && !isSelected
                                      ? Colors.blue.shade50
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: isToday && !isSelected
                                      ? Border.all(
                                          color: AppColors.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : !isAvailable
                                          ? Colors.grey
                                          : isToday && !isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight:
                                          isSelected || (isToday && !isSelected)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Time Slots
                  if (_selectedDate != null) ...[
                    Text(
                      'الأوقات المتاحة ليوم ${_getWeekdayName(_selectedDate!.weekday)} ${_selectedDate!.day}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingSlots)
                      const Center(child: CircularProgressIndicator())
                    else if (_morningSlots.isEmpty && _afternoonSlots.isEmpty && _eveningSlots.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('لا توجد مواعيد متاحة لهذا اليوم'),
                      ))
                    else ...[
                    if (_morningSlots.isNotEmpty) ...[
                      const Text(
                        'الصباح',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _morningSlots
                            .map((time) => _buildTimeChip(time))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Afternoon slots
                    if (_afternoonSlots.isNotEmpty) ...[
                      const Text(
                        'بعد الظهر',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _afternoonSlots
                            .map((time) => _buildTimeChip(time))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Evening slots
                    if (_eveningSlots.isNotEmpty) ...[
                      const Text(
                        'المساء',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _eveningSlots
                            .map((time) => _buildTimeChip(time))
                            .toList(),
                      ),
                    ],
                  ],
                  ],

                  // Repeat Booking Option
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Switch(
                              value: _repeatBooking,
                              onChanged: (value) {
                                setState(() {
                                  _repeatBooking = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تكرار الموعد ${value ? "مفعل" : "ملغى"}',
                                    ),
                                  ),
                                );
                              },
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('تكرار الموعد؟')),
                            const Icon(Icons.repeat),
                          ],
                        ),
                        if (_repeatBooking) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('التكرار:'),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'weekly',
                                      groupValue: _repeatFrequency,
                                      onChanged: (value) {
                                        setState(() {
                                          _repeatFrequency = value!;
                                        });
                                      },
                                    ),
                                    const Text('أسبوعي'),
                                    const SizedBox(width: 16),
                                    Radio<String>(
                                      value: 'monthly',
                                      groupValue: _repeatFrequency,
                                      onChanged: (value) {
                                        setState(() {
                                          _repeatFrequency = value!;
                                        });
                                      },
                                    ),
                                    const Text('شهري'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Payment Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'كشفية عبر الإنترنت: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      MauritanianConstants.formatPrice(
                        MauritanianConstants.appointmentPrice,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (_repeatBooking) ...[
                  const SizedBox(height: 4),
                  Text(
                    'سيتم تكرار الحجز ${_repeatFrequency == 'weekly' ? 'أسبوعياً' : 'شهرياً'}',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
                const SizedBox(height: 16),
                CustomButton(
                  text: 'احجز الآن والدفع',
                  onPressed: _selectedDate != null && _selectedTime != null
                      ? () => _confirmBooking()
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (keep _buildTimeChip and _confirmBooking)

  Widget _buildTimeChip(String time) {
    final isSelected = _selectedTime == time;
    final isAvailable = _selectedDate != null
        ? _isTimeSlotAvailable(_selectedDate!, time)
        : true;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedTime = time;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isAvailable
              ? Colors.green.shade50
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isAvailable
                ? Colors.green.shade300
                : Colors.grey.shade400,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isAvailable
                ? Colors.green.shade700
                : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _confirmBooking() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ والوقت')),
      );
      return;
    }

    final doctorName = widget.doctor?['name'] ?? 'د. أحمد المنصور';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحجز'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الطبيب: $doctorName'),
              Text(
                'التاريخ: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              Text('الوقت: $_selectedTime'),
              Text(
                'السعر: ${MauritanianConstants.formatPrice(MauritanianConstants.appointmentPrice)}',
              ),
              if (_repeatBooking) ...[
                const SizedBox(height: 8),
                Text(
                  'تكرار: ${_repeatFrequency == 'weekly' ? 'أسبوعي' : 'شهري'}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'هل تريد تأكيد الحجز؟',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('تأكيد الحجز'),
            ),
          ],
        );
      },
    );
  }

  void _processBooking() async {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Add to booked slots
    final slotKey =
        '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedTime}';
    _bookedSlots.add(slotKey);

    try {
      // Parse time string '10:00 ص' -> HH:mm
      String timeStr = _selectedTime!.replaceAll(' ص', '').replaceAll(' م', '');
      List<String> parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (_selectedTime!.contains('م') && hour != 12) {
        // PM
        hour += 12;
      } else if (_selectedTime!.contains('ص') && hour == 12) {
        // AM
        hour = 0;
      }

      DateTime appointmentTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

      // Validate doctor ID
      final doctorIdRaw = widget.doctor?['id'];
      if (doctorIdRaw == null) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار طبيب قبل الحجز'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final int doctorId = doctorIdRaw is int
          ? doctorIdRaw
          : int.tryParse(doctorIdRaw.toString()) ?? 0;

      if (doctorId == 0) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في معرف الطبيب'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final user = await AuthService.getCurrentUser();
      if (user == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
        );
        return;
      }

      // Try to get real patientId from userId
      int? patientId = await DataService.getPatientIdByUserId(user.id);
      
      // If not found, use userId as last resort (though backend might fail)
      patientId ??= user.id;

      print('DEBUG: Booking for UserId: ${user.id}, PatientId: $patientId');

      // Call API to create appointment
      final result = await DataService.createAppointment(
        doctorId: doctorId,
        patientId: patientId,
        appointmentDate: appointmentTime,
        notes: 'Booking via Calendar',
        doctorName: widget.doctor?['name'],
        patientName: user.fullName,
        specialty: widget.doctor?['specialty'],
        department: widget.doctor?['department'],
      );

      Navigator.pop(context); // Close progress dialog

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _repeatBooking
                  ? 'تم حجز الموعد بنجاح! سيتم تكراره ${_repeatFrequency == 'weekly' ? 'أسبوعياً' : 'شهرياً'}'
                  : 'تم حجز الموعد بنجاح!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to appointments tab in home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: 1,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل حجز الموعد'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في الحجز: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareBooking() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار موعد أولاً')));
      return;
    }

    final doctorName = widget.doctor?['name'] ?? 'د. أحمد المنصور';

    final shareText =
        'حجز موعد مع $doctorName\n'
        'التاريخ: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}\n'
        'الوقت: $_selectedTime\n'
        'السعر: ${MauritanianConstants.formatPrice(MauritanianConstants.appointmentPrice)}';

    // In a real app, you'd use the share package
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('مشاركة: $shareText')));
  }
}
