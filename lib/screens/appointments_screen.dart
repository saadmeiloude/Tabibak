import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../models/appointment.dart';
import '../core/models/enums.dart';
import '../core/localization/app_localizations.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDoctor = false;
  AppointmentStatus? _selectedStatus; // null means 'All'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'الرجاء تسجيل الدخول أولاً';
        });
        return;
      }

      final result = await DataService.getUserAppointments(userId: user.id);

      if (!mounted) return;

      if (result['success']) {
        final List<Appointment> appointments = result['appointments'];
        final now = DateTime.now();

        setState(() {
          _isDoctor = user.role == UserRole.doctor;
          _upcomingAppointments = appointments.where((apt) {
            bool matchesStatus = _selectedStatus == null || apt.status == _selectedStatus;
            
            return matchesStatus && 
                apt.status != AppointmentStatus.cancelled &&
                apt.status != AppointmentStatus.completed &&
                (apt.appointmentDate.isAfter(now) ||
                    (apt.appointmentDate.day == now.day &&
                        apt.appointmentDate.month == now.month &&
                        apt.appointmentDate.year == now.year));
          }).toList();

          _pastAppointments = appointments.where((apt) {
            bool matchesStatus = _selectedStatus == null || apt.status == _selectedStatus;

            return matchesStatus && (
                apt.status == AppointmentStatus.cancelled ||
                apt.status == AppointmentStatus.completed ||
                apt.appointmentDate.isBefore(
                  DateTime(now.year, now.month, now.day),
                ));
          }).toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'فشل تحميل المواعيد';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'حدث خطأ في الاتصال: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appointments ?? 'حجوزاتي'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/doctors',
              ).then((_) => _loadAppointments());
            },
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: AppLocalizations.of(context)?.upcoming ?? 'القادمة'),
            Tab(text: AppLocalizations.of(context)?.past ?? 'السابقة'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatusFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            onRefresh: _loadAppointments,
                            child: _buildUpcomingAppointments(),
                          ),
                          RefreshIndicator(
                            onRefresh: _loadAppointments,
                            child: _buildPastAppointments(),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _statusChip('الكل', null),
          _statusChip('المؤكدة', AppointmentStatus.confirmed),
          _statusChip('المكتملة', AppointmentStatus.completed),
          _statusChip('الملغاة', AppointmentStatus.cancelled),
        ],
      ),
    );
  }

  Widget _statusChip(String label, AppointmentStatus? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedStatus = status;
              _loadAppointments();
            });
          }
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'فشل تحميل المواعيد'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAppointments,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    if (_upcomingAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noUpcomingAppointments ??
                  'لا توجد مواعيد قادمة',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _upcomingAppointments[index];
        return _buildAppointmentCard(
          context,
          appointment: appointment,
          isPast: false,
        );
      },
    );
  }

  Widget _buildPastAppointments() {
    if (_pastAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noPastAppointments ??
                  'لا توجد مواعيد سابقة',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _pastAppointments[index];
        return _buildAppointmentCard(
          context,
          appointment: appointment,
          isPast: true,
        );
      },
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context, {
    required Appointment appointment,
    required bool isPast,
  }) {
    print(appointment.id);
    // Determine which name to show based on user role
    final doctorName = appointment.doctorName ?? (AppLocalizations.of(context)?.translate('doctor') ?? 'طبيب');
    final displayName = _isDoctor ? (appointment.patientName ?? 'مريض') : doctorName;
    final displayIcon = _isDoctor ? Icons.person : Icons.medical_services;

    final specialty = appointment.specialty ?? 'تخصص عام';
    final date =
        '${appointment.appointmentDate.year}-${appointment.appointmentDate.month}-${appointment.appointmentDate.day} ${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute}';
    final location = appointment.consultationType == 'online'
        ? (AppLocalizations.of(context)?.videoConsultation ?? 'استشارة عن بعد')
        : (AppLocalizations.of(context)?.medicalConsultation ?? 'عيادة');
    final locationIcon = appointment.consultationType == 'online'
        ? Icons.videocam
        : Icons.local_hospital_outlined;
    final isOnline = appointment.consultationType == 'online';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          // Header: Doctor/Patient Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                child: Icon(displayIcon, color: Colors.grey),
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
                      specialty,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          location,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          locationIcon,
                          size: 14,
                          color: isOnline ? Colors.green : AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Action Buttons
          if (!isPast) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showRescheduleDialog(context, doctorName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.reschedule ?? 'إعادة جدولة',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelDialog(context, appointment);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.cancel ?? 'إلغاء',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // For past appointments, show rating option
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showRatingDialog(context, doctorName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.rateDoctor ??
                          'تقييم الطبيب',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showReBookDialog(context, doctorName);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.newBooking ?? 'حجز جديد',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, String doctorName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.rescheduleDialogTitle ??
                'إعادة جدولة الموعد',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context)?.rescheduleDialogContent ?? "هل تريد إعادة جدولة موعدك مع"} $doctorName؟',
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.rescheduleRedirectNotice ??
                    'سيتم توجيهك إلى صفحة حجز المواعيد لتحديد موعد جديد',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/booking-calendar');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري إعادة جدولة الموعد...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(AppLocalizations.of(context)?.confirm ?? 'موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, Appointment appointment) {
    final doctorName = appointment.doctorName ?? 'الطبيب';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.cancelAppointmentTitle ??
                'إلغاء الموعد',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)?.cancelAppointmentConfirm ?? "هل أنت متأكد من إلغاء موعدك مع"} $doctorName؟',
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.cancellationFeeNotice ??
                    'ملاحظة: قد يتم تطبيق رسوم إلغاء حسب سياسة العيادة',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.noKeep ?? 'لا'),
            ),
            ElevatedButton(
              onPressed: () async {
                // We need to capture these before popping any context
                final parentNavigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // 1. Close the confirmation dialog
                parentNavigator.pop();

                // 2. Show loading dialog
                BuildContext? loadingContext;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) {
                    loadingContext = ctx;
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  final result = await DataService.cancelAppointment(
                    appointment.id,
                  );

                  // 3. Pop loading dialog
                  if (loadingContext != null && loadingContext!.mounted) {
                    Navigator.of(loadingContext!).pop();
                  }

                  if (!mounted) return;

                  if (result['success']) {
                    setState(() {
                      _loadAppointments();
                    });

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('تم إلغاء الموعد مع $doctorName'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'فشل الإلغاء'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  // Pop loading dialog if something goes wrong
                  if (loadingContext != null && loadingContext!.mounted) {
                    Navigator.of(loadingContext!).pop();
                  }
                  
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ في إلغاء الموعد: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                AppLocalizations.of(context)?.yesCancel ?? 'نعم، إلغاء',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, String doctorName) {
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.rateDoctor ?? 'تقييم الطبيب',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context)?.howWasYourExperience ?? "كيف كانت تجربتك مع"} $doctorName؟',
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  );
                },
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('شكراً لتقييمك: $rating نجوم')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                AppLocalizations.of(context)?.sendRating ?? 'إرسال التقييم',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReBookDialog(BuildContext context, String doctorName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.newBookingDialogTitle ??
                'حجز موعد جديد',
          ),
          content: Text(
            '${AppLocalizations.of(context)?.newBookingDialogContent ?? "هل تريد حجز موعد جديد مع"} $doctorName؟',
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
                Navigator.pushNamed(context, '/booking-calendar');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }
}
