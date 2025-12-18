import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../core/localization/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await DataService.init();

    // Get Current User (Doctor)
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      _currentDoctorId = user.id;
    }

    // Load Data
    await Future.wait([_loadAppointments(), _loadPatients()]);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadAppointments() async {
    final result = await DataService.getUserAppointments();
    if (mounted && result['success']) {
      _appointments = result['appointments'] as List<Appointment>;
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

    final result = await DataService.createAppointment(
      doctorId: doctorId,
      patientId: patientId,
      appointmentDate: date,
      appointmentTime: dateTime,
      symptoms: symptoms,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.calendarViewUnderDev ??
              'خاصية إعادة الجدولة قيد التطوير',
        ),
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    return _appointments.where((appointment) {
      if (_selectedFilter == 'today') {
        final now = DateTime.now();
        return appointment.appointmentDate.year == now.year &&
            appointment.appointmentDate.month == now.month &&
            appointment.appointmentDate.day == now.day;
      }
      // Add 'Tomorrow' etc.
      if (_selectedFilter == 'tomorrow') {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return appointment.appointmentDate.year == tomorrow.year &&
            appointment.appointmentDate.month == tomorrow.month &&
            appointment.appointmentDate.day == tomorrow.day;
      }
      return true;
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
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)?.calendar ??
                                      'تقويم',
                                  style: TextStyle(
                                    color: _isListView
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                    fontWeight: _isListView
                                        ? FontWeight.normal
                                        : FontWeight.bold,
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

                // Horizontal Filter Chips
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Appointments List
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

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.noAppointments ?? 'لا توجد مواعيد',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
          child: _buildAppointmentCard(context, appointment: appointment),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.calendarViewUnderDev ??
            'عرض التقويم قيد التطوير',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
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

  Widget _buildAppointmentCard(
    BuildContext context, {
    required Appointment appointment,
  }) {
    Color statusColor = Colors.green;
    bool isPending = appointment.status == 'pending';
    bool isCancelled = appointment.status == 'cancelled';

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
                        appointment.status,
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
