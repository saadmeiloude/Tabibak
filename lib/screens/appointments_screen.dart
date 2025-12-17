import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return;

      final result = await DataService.getUserAppointments(userId: user.id);

      if (!mounted) return;

      if (result['success']) {
        final List<Appointment> appointments =
            result['appointments']; // Assumes cast works or is typed
        final now = DateTime.now();

        setState(() {
          _upcomingAppointments = appointments.where((apt) {
            return apt.status != 'cancelled' &&
                apt.status != 'completed' &&
                (apt.appointmentDate.isAfter(now) ||
                    (apt.appointmentDate.day == now.day &&
                        apt.appointmentDate.month == now.month &&
                        apt.appointmentDate.year == now.year));
          }).toList();

          _pastAppointments = appointments.where((apt) {
            return apt.status == 'cancelled' ||
                apt.status == 'completed' ||
                apt.appointmentDate.isBefore(
                  DateTime(now.year, now.month, now.day),
                );
          }).toList();

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'فشل تحميل المواعيد')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingAppointments(),
                _buildPastAppointments(),
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
    final doctorName = appointment.doctorName ?? 'طبيب';
    final specialty =
        'تخصص عام'; // we might need to fetch this or include in query
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
          // Header: Doctor Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                Navigator.of(context).pop();

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  final result = await DataService.cancelAppointment(
                    appointment.id,
                  );

                  Navigator.of(context).pop(); // Close loading dialog

                  if (result['success']) {
                    setState(() {
                      // Refresh list
                      _loadAppointments();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم إلغاء الموعد مع $doctorName'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'فشل الإلغاء'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop(); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
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
