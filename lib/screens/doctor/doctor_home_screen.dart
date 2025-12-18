import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../core/localization/app_localizations.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _isLoading = true;
  int _todayAppointments = 0;
  int _newPatients = 0;
  int _totalPatients = 0;
  List<Appointment> _upcomingAppointments = [];
  List<Map<String, dynamic>> _recentPatients = [];
  List<Map<String, dynamic>> _recentlyAddedPatients = [];
  String _doctorName = 'د. أحمد';

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return;

      final statsResult = await DataService.getDoctorDashboardStats();

      setState(() {
        _doctorName = user.fullName;

        if (statsResult['success'] == true) {
          final data = statsResult['data'];
          _todayAppointments =
              int.tryParse(data['today_appointments'].toString()) ?? 0;
          _newPatients = int.tryParse(data['new_patients'].toString()) ?? 0;
          _totalPatients = int.tryParse(data['total_patients'].toString()) ?? 0;

          // Map recently added patients
          _recentlyAddedPatients =
              (data['recently_added_patients'] as List? ?? [])
                  .map(
                    (item) => {
                      'id': item['id'],
                      'name': item['name'],
                      'phone': item['phone'],
                      'created_at': item['created_at'],
                    },
                  )
                  .toList()
                  .cast<Map<String, dynamic>>();

          // Map upcoming appointments
          _upcomingAppointments = (data['upcoming_appointments'] as List)
              .map((item) {
                return Appointment(
                  id: int.parse(item['id'].toString()),
                  patientId: int.parse(item['patient_id'].toString()),
                  doctorId: user.id,
                  doctorName: _doctorName,
                  patientName: item['patient_name'],
                  appointmentDate: DateTime.parse(item['appointment_date']),
                  appointmentTime: DateTime.parse(
                    '1970-01-01 ${item['appointment_time']}',
                  ),
                  status: item['status'],
                  consultationType: item['consultation_type'] ?? 'General',
                  durationMinutes: 30, // Default
                  feePaid: 0.0, // Default
                  paymentStatus: 'pending', // Default
                  createdAt: DateTime.now(), // Default
                  updatedAt: DateTime.now(), // Default
                );
              })
              .cast<Appointment>()
              .toList();

          // Map recent patients
          _recentPatients = (data['recent_patients'] as List)
              .map(
                (item) => {
                  'name': item['name'],
                  'lastVisit': item['last_visit'] ?? 'N/A',
                  'isNew': false, // Logic handled in query if needed
                },
              )
              .toList()
              .cast<Map<String, dynamic>>();
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDoctorData();
  }

  void _showNotifications() {
    var loc = AppLocalizations.of(context);
    // ... (Keep existing implementation)
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc?.recentNotifications ?? 'الإشعارات',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text('موعد جديد مجدول'),
                subtitle: const Text('علي محمد - غداً 10:00 ص'),
                trailing: const Text('جديد'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showReportsDialog() async {
    var loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder<Map<String, dynamic>>(
        future: DataService.getReportStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }

          final data = snapshot.data?['data'] ?? {};
          final todayStats = data['today_stats'] ?? {};
          final revenue = data['revenue_today'] ?? 0;

          return AlertDialog(
            title: Text(
              loc?.reportsDialogTitle ?? 'تقارير اليوم',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.show_chart, color: Colors.blue),
                  title: Text(loc?.totalIncomeToday ?? 'إجمالي الدخل اليوم'),
                  trailing: Text(
                    '$revenue ${loc?.currencyMru ?? 'د.ج'}', // Using currency key
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.green),
                  title: Text(loc?.totalPatients ?? 'إجمالي المرضى'),
                  trailing: Text(
                    '${data['total_patients'] ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Text(
                  loc?.appointmentStatusTitle ?? 'حالة المواعيد',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ...todayStats.entries
                    .map<Widget>(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.key.toString().toUpperCase()),
                        trailing: Text(e.value.toString()),
                      ),
                    )
                    .toList(),
                if (todayStats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      loc?.noAppointmentsToday ?? 'لا توجد مواعيد اليوم',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc?.close ?? 'إغلاق'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${loc?.welcome ?? 'أهلاً بك'}، $_doctorName'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _refreshData();
            },
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () {
              _showNotifications();
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading) ...[
                const SizedBox(height: 50),
                Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
                Center(child: Text('جاري تحميل البيانات...')),
              ] else ...[
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: loc?.todayAppointments ?? 'مواعيد اليوم',
                        value: _todayAppointments.toString(),
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/doctor-appointments',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: loc?.newPatients ?? 'مرضى جدد',
                        value: _newPatients.toString(),
                        icon: Icons.person_add,
                        color: Colors.green,
                        onTap: () =>
                            Navigator.pushNamed(context, '/patient-list'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Total Patients Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: loc?.totalPatients ?? 'إجمالي المرضى',
                        value: _totalPatients.toString(),
                        icon: Icons.people,
                        color: Colors.purple,
                        onTap: () =>
                            Navigator.pushNamed(context, '/patient-list'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recently Added Patients
                if (_recentlyAddedPatients.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc?.recentlyAddedPatients ?? 'المرضى المضافون حديثاً',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/patient-list'),
                        child: Text(loc?.viewAll ?? 'عرض الكل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentlyAddedPatients.length,
                      itemBuilder: (context, index) {
                        final patient = _recentlyAddedPatients[index];
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.green.shade100,
                                    child: const Icon(
                                      Icons.person_add,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      patient['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                patient['phone'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick Actions
                Text(
                  loc?.quickActions ?? 'الإجراءات السريعة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        loc?.newAppointmentAction ?? 'موعد جديد',
                        Icons.add_circle,
                        Colors.blue,
                        () => Navigator.pushNamed(
                          context,
                          '/doctor-appointments',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        loc?.newPatientAction ?? 'مريض جديد',
                        Icons.person_add,
                        Colors.green,
                        () => Navigator.pushNamed(context, '/patient-list'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        loc?.reportsAction ?? 'التقارير',
                        Icons.analytics,
                        Colors.orange,
                        () => _showReportsDialog(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upcoming Appointments
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc?.upcoming ?? 'المواعيد القادمة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/doctor-appointments'),
                      child: Text(loc?.viewAll ?? 'عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_upcomingAppointments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc?.noUpcomingAppointments ?? 'لا توجد مواعيد قادمة',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _upcomingAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _upcomingAppointments[index];
                        return _buildAppointmentCard(
                          context,
                          appointment: appointment,
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Recent Patients
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc?.patientsTitle ?? 'المرضى',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/patient-list'),
                      child: Text(loc?.viewAll ?? 'عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_recentPatients.isEmpty)
                  Text(loc?.noPatientsData ?? 'لا توجد بيانات مرضى')
                else
                  ...List.generate(
                    _recentPatients.length.clamp(0, 3),
                    (index) => Column(
                      children: [
                        _buildPatientListItem(
                          context,
                          _recentPatients[index]['name'],
                          '${loc?.lastVisitLabel ?? 'آخر زيارة'}: ${_recentPatients[index]['lastVisit']}',
                          isNew: _recentPatients[index]['isNew'] ?? false,
                        ),
                        if (index < _recentPatients.length.clamp(0, 3) - 1)
                          const SizedBox(height: 12),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets ...
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    // ... (Keep existing implementation)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    // ... (Keep existing implementation)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context, {
    required Appointment appointment,
  }) {
    final name = appointment.patientName ?? appointment.doctorName ?? 'Unknown';
    final time =
        '${appointment.appointmentDate.day}/${appointment.appointmentDate.month} ${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}';
    final type = appointment.consultationType;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/doctor-chat', arguments: {'name': name});
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '$time - $type',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientListItem(
    BuildContext context,
    String name,
    String subtitle, {
    bool isNew = false,
  }) {
    var loc = AppLocalizations.of(context);
    // ... (Keep existing implementation)
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNew ? Colors.green : Colors.grey,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/patient-file',
              arguments: {'name': name},
            );
          },
          child: Text(loc?.viewFileAction ?? 'عرض الملف'),
        ),
      ),
    );
  }
}
