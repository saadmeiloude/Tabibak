import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment.dart';
import '../../core/models/enums.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart' as app_notification;
import '../../models/doctor.dart';

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
  num _totalEarnings = 0;
  List<Appointment> _upcomingAppointments = [];
  List<Map<String, dynamic>> _recentPatients = [];
  List<Map<String, dynamic>> _recentlyAddedPatients = [];
  String _doctorName = 'د. أحمد';
  int? _realDoctorId;

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

      // Fetch the real doctor ID 
      final doctorResult = await DataService.getDoctorProfile();
      if (doctorResult['success']) {
        final doctor = doctorResult['doctor'] as Doctor;
        _realDoctorId = doctor.id;
        _doctorName = doctor.name ?? user.fullName;
      } else {
        _realDoctorId = user.id;
        _doctorName = user.fullName;
      }

      final statsResult = await DataService.getDoctorDashboardStats();
      print('DEBUG: Doctor stats raw response: $statsResult');

      if (mounted) {
        setState(() {
          _doctorName = user.fullName;

          if (statsResult['success'] == true) {
            final data = statsResult['data'];
            if (data != null) {
              final stats = data['stats'] ?? data;
              
              _todayAppointments = int.tryParse(stats['todayAppointments']?.toString() ?? stats['today_appointments']?.toString() ?? '0') ?? 0;
              _newPatients = int.tryParse(stats['newPatients']?.toString() ?? stats['new_patients']?.toString() ?? '0') ?? 0;
              _totalPatients = int.tryParse(stats['totalPatients']?.toString() ?? stats['total_patients']?.toString() ?? '0') ?? 0;
              _totalEarnings = num.tryParse(stats['totalEarnings']?.toString() ?? stats['total_earnings']?.toString() ?? '0') ?? 0;

              // Map recently added patients
              final recentPatientsList = stats['recentlyAddedPatients'] ?? stats['recently_added_patients'] ?? [];
              _recentlyAddedPatients = (recentPatientsList as List? ?? [])
                      .map((item) => {
                          'id': item['id'],
                          'name': item['name'] ?? '${item['firstName'] ?? ''} ${item['lastName'] ?? ''}'.trim(),
                          'phone': item['phone'],
                          'created_at': item['created_at'] ?? item['createdAt'],
                        })
                      .toList()
                      .cast<Map<String, dynamic>>();

              // Map upcoming appointments
              final upcomingList = stats['upcomingAppointments'] ?? stats['upcoming_appointments'] ?? [];
              _upcomingAppointments = (upcomingList as List? ?? [])
                  .map((item) => Appointment.fromJson(item))
                  .toList();
            }
          }
        });

        // 🚀 FALLBACK: If stats are zero/empty, try to calculate from direct lists
        if (_totalPatients == 0 || _todayAppointments == 0) {
          final patientsResult = await DataService.getPatients();
          final appointmentsResult = await DataService.getUserAppointments();
          
          if (mounted) {
            setState(() {
              if (patientsResult['success'] == true) {
                final List patients = patientsResult['patients'] ?? [];
                if (_totalPatients == 0) _totalPatients = patients.length;
                
                // Calculate new patients (e.g., added today)
                if (_newPatients == 0) {
                  final now = DateTime.now();
                  _newPatients = patients.where((p) {
                    final createdAtStr = p['createdAt'] ?? p['created_at'];
                    if (createdAtStr != null) {
                      final createdAt = DateTime.tryParse(createdAtStr.toString());
                      return createdAt != null && 
                             createdAt.year == now.year && 
                             createdAt.month == now.month && 
                             createdAt.day == now.day;
                    }
                    return false;
                  }).length;
                }
              }

              if (appointmentsResult['success'] == true) {
                final List<Appointment> allApts = appointmentsResult['appointments'] ?? [];
                if (_todayAppointments == 0) {
                  final now = DateTime.now();
                  _todayAppointments = allApts.where((apt) => 
                    apt.appointmentDate.year == now.year &&
                    apt.appointmentDate.month == now.month &&
                    apt.appointmentDate.day == now.day
                  ).length;
                }
                
                if (_upcomingAppointments.isEmpty) {
                  _upcomingAppointments = allApts.where((apt) => apt.status == AppointmentStatus.confirmed).toList();
                }
              }
            });
          }
        }
      }
      
      if (mounted) setState(() => _isLoading = false);
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
    final loc = AppLocalizations.of(context);
    final notificationService = NotificationService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc?.recentNotifications ?? 'الإشعارات الأخيرة',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/notifications'),
                      child: Text(loc?.viewAll ?? 'عرض الكل'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: notificationService.getNotifications(limit: 10),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError || snapshot.data?['success'] != true) {
                      return Center(child: Text(loc?.errorLoadingData ?? 'خطأ في تحميل البيانات'));
                    }

                    final notifications = snapshot.data?['notifications'] as List<app_notification.Notification>? ?? [];

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(loc?.noNotifications ?? 'لا توجد إشعارات'),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getNotificationColor(notification.type.toString()).withOpacity(0.1),
                            child: Icon(_getNotificationIcon(notification.type.toString()),
                                color: _getNotificationColor(notification.type.toString()), size: 20),
                          ),
                          title: Text(
                            notification.title,
                            style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
                          ),
                          subtitle: Text(notification.message),
                          trailing: Text(
                            _formatTimeAgo(notification.timestamp), // Retained original logic as _formatDate and room.createdAt are not defined here.
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appointment': return Icons.calendar_today;
      case 'chat': return Icons.chat;
      case 'system': return Icons.info_outline;
      case 'medical': return Icons.medical_services_outlined;
      default: return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'appointment': return Colors.blue;
      case 'chat': return Colors.green;
      case 'system': return Colors.orange;
      case 'medical': return Colors.red;
      default: return AppColors.primary;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'قبل ${difference.inMinutes} د';
    if (difference.inHours < 24) return 'قبل ${difference.inHours} سا';
    if (difference.inDays < 7) return 'قبل ${difference.inDays} يوم';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
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
                if (todayStats is Map)
                  ...todayStats.entries
                      .map<Widget>(
                        (e) => ListTile(
                          dense: true,
                          title: Text(e.key.toString().toUpperCase()),
                          trailing: Text(e.value.toString()),
                        ),
                      )
                      .toList(),
                if (todayStats == null ||
                    (todayStats is Map && todayStats.isEmpty) ||
                    (todayStats is List && todayStats.isEmpty))
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
              Navigator.pushNamed(context, '/doctor-chat-rooms');
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textPrimary,
            ),
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
                        title: loc?.todayAppointments ?? 'طلبات معلقة',
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
                // Total Patients and Revenue Row
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
                    const SizedBox(width: 16),
                    Builder(
                      builder: (context) {
                        // Extra robust check for Dart Web
                        final currentEarnings = _totalEarnings;
                        final String displayValue = (currentEarnings is num) 
                          ? currentEarnings.toStringAsFixed(0) 
                          : '0';
                        
                        return Expanded(
                          child: _buildStatCard(
                            context,
                            title: loc?.totalEarnings ?? 'إجمالي الدخل',
                            value: '$displayValue ${loc?.currencyMru ?? 'د.ج'}',
                            icon: Icons.account_balance_wallet,
                            color: Colors.orange,
                            onTap: () => Navigator.pushNamed(context, '/wallet'),
                          ),
                        );
                      }
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
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        loc?.reportsAction ?? 'التقارير',
                        Icons.analytics,
                        Colors.orange,
                        () => _showReportsDialog(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        loc?.wallet ?? 'المحفظة',
                        Icons.account_balance_wallet,
                        Colors.purple,
                        () => Navigator.pushNamed(context, '/wallet'),
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
                          id: _recentPatients[index]['id'],
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
        Navigator.pushNamed(context, '/doctor-chat', arguments: {
          'name': name, 
          'id': appointment.patientId,
          'patient_id': appointment.patientId
        });
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
    dynamic id,
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
              arguments: {'name': name, 'id': id},
            );
          },
          child: Text(loc?.viewFileAction ?? 'عرض الملف'),
        ),
      ),
    );
  }
}
