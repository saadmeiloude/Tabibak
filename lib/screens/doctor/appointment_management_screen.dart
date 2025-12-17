import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  List<Appointment> _appointments = [];
  String _selectedFilter = 'اليوم';
  bool _isListView = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    await DataService.init();
    final result = await DataService.getUserAppointments();

    if (mounted) {
      setState(() {
        if (result['success']) {
          _appointments = result['appointments'] as List<Appointment>;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddAppointmentDialog() async {
    // Note: Creating appointment usually requires selecting a patient and doctor.
    // This dialog is simplified and might need further implementation for full support.

    final nameController = TextEditingController();
    final descriptionController = TextEditingController(); // acts as symptoms
    // Time picker would be better

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إنشاء موعد جديد (تجريبي)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ملاحظة: هذا يتطلب تحديد مريض مسجل',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المريض',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'السبب/النوع',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // Stub for now as we lack API to create appointment by just name
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الإنشاء غير مدعوم حالياً في هذه الواجهة'),
                  ),
                );
              },
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAppointment(Appointment appointment) async {
    // API might not have confirm endpoint, simulated or mock
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خاصية التأكيد غير متوفرة في API حالياً')),
    );
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final result = await DataService.cancelAppointment(appointment.id);
    if (result['success']) {
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إلغاء الموعد')));
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
    // Placeholder for reschedule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خاصية إعادة الجدولة غير متوفرة بعد')),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    // Simple filter logic
    return _appointments.where((appointment) {
      if (appointment.status == 'cancelled') return false; // Hide cancelled?
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة المواعيد'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
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
                                  'قائمة',
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
                      _buildFilterChip('اليوم', _selectedFilter == 'اليوم'),
                      const SizedBox(width: 8),
                      _buildFilterChip('غداً', _selectedFilter == 'غداً'),
                      const SizedBox(width: 8),
                      _buildFilterChip('السبت', _selectedFilter == 'السبت'),
                      // Add more logic to actually filter by date if needed
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
      return const Center(
        child: Text(
          'لا توجد مواعيد',
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
    return const Center(
      child: Text(
        'عرض التقويم قيد التطوير',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
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
                        'تأكيد الحضور',
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
                        'إلغاء',
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
                        'إلغاء',
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
