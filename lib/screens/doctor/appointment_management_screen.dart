import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../core/models/enums.dart';
import '../../core/localization/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  List<Appointment> _appointments = [];
  List<dynamic> _patients = [];
  String _selectedFilter = 'today';
  bool _isListView = true;
  bool _isLoading = true;
  int? _currentDoctorId;
  String? _doctorName;
  
  // Calendar specific
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await DataService.init();

    // Get Current User (to check role)
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      // Fetch the real doctor ID from the doctor profile
      final doctorResult = await DataService.getDoctorProfile();
      if (doctorResult['success']) {
        final doctor = doctorResult['doctor'] as Doctor;
        _currentDoctorId = doctor.id;
        _doctorName = doctor.name;
        debugPrint('DEBUG: Initialized with Doctor ID: $_currentDoctorId (User ID was: ${user.id})');
      } else {
        // Fallback or error handling
        debugPrint('DEBUG: Failed to fetch doctor profile, falling back to user.id: ${user.id}');
        _currentDoctorId = user.id;
        _doctorName = user.fullName;
      }
    }

    // Load Data
    await Future.wait([_loadAppointments(), _loadPatients()]);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadAppointments() async {
    final result = await DataService.getUserAppointments();
    if (mounted && result['success']) {
      setState(() {
         _appointments = result['appointments'] as List<Appointment>;
      });
    }
  }

  Future<void> _loadPatients() async {
    final result = await DataService.getPatients();
    if (mounted && result['success']) {
      _patients = result['patients'] as List<dynamic>;
    }
  }

  Future<void> _showAddAppointmentDialog() async {
    if (_patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.noCustomersWarning ??
                'لا يوجد مرضى مسجلين. الرجاء إضافة مريض أولاً.',
          ),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? selectedPatientId;
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)?.createAppointmentTitle ??
                    'إنشاء موعد جديد',
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(
                                context,
                              )?.selectPatientLabel ??
                              'اختر المريض',
                          border: const OutlineInputBorder(),
                        ),
                        items: _patients
                            .map(
                              (p) => DropdownMenuItem<int>(
                                value: int.tryParse(p['id'].toString()),
                                child: Text(p['full_name'] ?? 'Unknown'),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => selectedPatientId = val,
                        validator: (val) => val == null ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)?.symptomsLabel ??
                              'السبب / الأعراض',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          '${AppLocalizations.of(context)?.date ?? 'التاريخ'}: ${selectedDate.toString().split(' ')[0]}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                      ListTile(
                        title: Text(
                          '${AppLocalizations.of(context)?.time ?? 'الوقت'}: ${selectedTime.format(context)}',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) setState(() => selectedTime = time);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)?.cancel ?? 'إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate() &&
                        _currentDoctorId != null) {
                      Navigator.pop(context);
                      _createAppointment(
                        doctorId: _currentDoctorId!,
                        patientId: selectedPatientId!,
                        date: selectedDate,
                        time: selectedTime,
                        symptoms: descriptionController.text,
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)?.create ?? 'إنشاء'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createAppointment({
    required int doctorId,
    required int patientId,
    required DateTime date,
    required TimeOfDay time,
    String? symptoms,
  }) async {
    setState(() => _isLoading = true);

    // Combine date and time
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Get selected patient name
    final patient = _patients.firstWhere(
      (p) => int.tryParse(p['id'].toString()) == patientId,
      orElse: () => {},
    );
    final patientName = patient['full_name'] ?? 'Unknown Patient';

    final result = await DataService.createAppointment(
      doctorId: doctorId,
      patientId: patientId,
      appointmentDate: dateTime,
      notes: symptoms,
      doctorName: _doctorName,
      patientName: patientName,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.appointmentBookedSuccess ??
                  'تم حجز الموعد بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadAppointments();
        setState(() {}); // Force UI refresh
      } else {
        final errorMsg =
            result['message'] ??
            result['error'] ??
            (AppLocalizations.of(context)?.bookingFailed ?? 'فشل الحجز');
        debugPrint('Appointment creation failed: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmAppointment(Appointment appointment) async {
    final result = await DataService.updateAppointment(
      appointmentId: appointment.id,
      status: 'confirmed',
    );

    if (!mounted) return;

    if (result['success']) {
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.appointmentConfirmed ??
                  'تم قبول الموعد',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'فشل قبول الموعد'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final result = await DataService.cancelAppointment(appointment.id);
    if (result['success']) {
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.appointmentCancelled ??
                  'تم إلغاء الموعد',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'فشل الإلغاء')),
        );
      }
    }
  }

  Future<void> _rescheduleAppointment(Appointment appointment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: appointment.appointmentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Parse initial time from string "HH:mm"
      TimeOfDay initialTime = TimeOfDay.now();
      try {
        final parts = appointment.time.split(':');
        if (parts.length == 2) {
          initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      } catch (e) {
        debugPrint('Error parsing time: $e');
      }

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        // ... (rest of the logic)
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final result = await DataService.updateAppointment(
          appointmentId: appointment.id,
          appointmentDate: newDateTime,
          status: 'rescheduled', 
        );

        if (mounted) {
          if (result['success']) {
            await _loadAppointments();
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text(
                  // AppLocalizations.of(context)?.rescheduleSuccess ?? 
                  'تم إعادة جدولة الموعد بنجاح',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'فشل إعادة الجدولة'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  List<Appointment> _getFilteredAppointments() {
    return _appointments.where((appointment) {
      // Filter by Calendar selection if not list view or if explicit filter
      if (!_isListView && _selectedDay != null) {
         return isSameDay(appointment.appointmentDate, _selectedDay);
      }

      if (_selectedFilter == 'custom' && _selectedDay != null) {
        return isSameDay(appointment.appointmentDate, _selectedDay);
      }
      
      if (_selectedFilter == 'today') {
        final now = DateTime.now();
        return isSameDay(appointment.appointmentDate, now);
      }
      
      if (_selectedFilter == 'tomorrow') {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return isSameDay(appointment.appointmentDate, tomorrow);
      }
      return true;
    }).toList();
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return _appointments.where((appointment) {
      return isSameDay(appointment.appointmentDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.appointmentManagement ??
              'إدارة المواعيد',
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _initData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Toggle View (List/Calendar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isListView = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isListView
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)?.list ?? 'قائمة',
                                  style: TextStyle(
                                    color: _isListView
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isListView = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isListView
                                    ? AppColors.primary
                                    : Colors.transparent, // Corrected logic
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)?.calendar ??
                                      'تقويم',
                                  style: TextStyle(
                                    color: !_isListView
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: !_isListView
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Horizontal Filter Chips (Only show in List View for clarity, or adapt behavior)
                if (_isListView) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          AppLocalizations.of(context)?.all ?? 'الكل',
                          'all',
                          _selectedFilter == 'all',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppLocalizations.of(context)?.today ?? 'اليوم',
                          'today',
                          _selectedFilter == 'today',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppLocalizations.of(context)?.tomorrow ?? 'غداً',
                          'tomorrow',
                          _selectedFilter == 'tomorrow',
                        ),
                        const SizedBox(width: 8),
                         GestureDetector(
                          onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDay ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDay = date;
                                  _selectedFilter = 'custom';
                                });
                              }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedFilter == 'custom' ? AppColors.primary : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, size: 16, color: _selectedFilter == 'custom' ? Colors.white : AppColors.textPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  'تاريخ',
                                  style: TextStyle(
                                    color: _selectedFilter == 'custom' ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Appointments List or Calendar
                Expanded(
                  child: _isListView
                      ? _buildAppointmentsList()
                      : _buildCalendarView(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        heroTag: "appointment_management_fab",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final filteredAppointments = _getFilteredAppointments();
    
    // Reverse events to show upcoming events correctly if needed, or sort
    // filteredAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noAppointments ?? 'لا توجد مواعيد',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildAppointmentCard(context: context, appointment: appointment),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar<Appointment>(
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            markerDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: _getEventsForDay(_selectedDay ?? _focusedDay).isEmpty 
          ? Center(child: Text('لا توجد مواعيد لهذا اليوم', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getEventsForDay(_selectedDay ?? _focusedDay).length,
              itemBuilder: (context, index) {
                return Padding(
                   padding: const EdgeInsets.only(bottom: 16.0),
                   child: _buildAppointmentCard(
                    context: context, 
                    appointment: _getEventsForDay(_selectedDay ?? _focusedDay)[index]
                  ),
                );
              },
            ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required BuildContext context,
    required Appointment appointment,
  }) {
    Color statusColor = Colors.green;
    bool isPending = appointment.status == AppointmentStatus.pending;
    bool isCancelled = appointment.status == AppointmentStatus.cancelled;

    if (isPending) statusColor = Colors.orange;
    if (isCancelled) statusColor = Colors.grey;

    final displayName =
        appointment.patientName ?? appointment.doctorName ?? 'غير محدد';
    final displayTime =
        '${appointment.appointmentDate.day}/${appointment.appointmentDate.month} ${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      appointment.consultationType,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    displayTime,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.status.toString().split('.').last,
                        style: TextStyle(color: statusColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isCancelled)
            Row(
              children: [
                if (isPending) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _confirmAppointment(appointment),
                      child: _buildActionButton(
                        AppLocalizations.of(context)?.confirmAttendance ??
                            'قبول',
                        Colors.green.shade100,
                        Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _cancelAppointment(appointment),
                      child: _buildActionButton(
                        AppLocalizations.of(context)?.cancel ?? 'إلغاء',
                        Colors.red.shade100,
                        Colors.red,
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _rescheduleAppointment(appointment),
                      child: _buildActionButton(
                        AppLocalizations.of(context)?.reschedule ??
                            'إعادة جدولة',
                        Colors.blue.shade100,
                        Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _cancelAppointment(appointment),
                      child: _buildActionButton(
                        AppLocalizations.of(context)?.cancel ?? 'إلغاء',
                        Colors.grey.shade100,
                        Colors.black,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: text, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
