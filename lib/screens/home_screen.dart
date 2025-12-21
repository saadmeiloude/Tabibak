import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../core/localization/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  List<Appointment> _upcomingAppointments = [];
  List<Map<String, dynamic>> _recentNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = await AuthService.getCurrentUser();
    await DataService.init();
    final appointmentsResult = await DataService.getUserAppointments();

    if (mounted) {
      setState(() {
        _userName = user?.fullName ?? '';
        if (appointmentsResult['success']) {
          _upcomingAppointments =
              (appointmentsResult['appointments'] as List<Appointment>)
                  .take(2)
                  .toList();
        }

        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getMockNotifications(BuildContext context) {
    if (_recentNotifications.isNotEmpty) return _recentNotifications;

    var loc = AppLocalizations.of(context);
    return [
      {
        'title': loc?.confirmAppointment ?? 'تأكيد الموعد',
        'message': loc?.notifConfirmSara ?? 'تم تأكيد موعدك بنجاح',
        'time': loc?.time1HourAgo ?? 'منذ ساعة',
        'type': 'appointment',
      },
      {
        'title': loc?.reminder ?? 'تذكير',
        'message': loc?.notifReminderAhmed ?? 'موعدك غداً في الساعة 10:00 ص',
        'time': loc?.time3HoursAgo ?? 'منذ 3 ساعات',
        'type': 'reminder',
      },
      {
        'title': loc?.specialOffer ?? 'عرض خاص',
        'message': loc?.notifOffer20 ?? 'خصم 20% على الاستشارات الطبية',
        'time': loc?.timeYesterday ?? 'أمس',
        'type': 'offer',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.appName ?? 'طبيبي',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: Container(), // Hide back button if any
        actions: [
          IconButton(
            onPressed: () {
              _showNotifications();
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.account_circle_outlined,
                color: AppColors.textPrimary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    '${AppLocalizations.of(context)?.welcome ?? 'مرحباً'}، $_userName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Big CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/doctors');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.bookAppointment ??
                            'حجز موعد أو استشارة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Upcoming Appointments
                  _buildSectionHeader(
                    context,
                    AppLocalizations.of(context)?.upcoming ??
                        'المواعيد القادمة',
                    AppLocalizations.of(context)?.all ?? 'عرض الكل',
                    () {
                      Navigator.pushNamed(context, '/appointments');
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/appointments');
                    },
                    child: Container(
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
                      child: _upcomingAppointments.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 48,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.noUpcomingAppointments ??
                                        'لا توجد مواعيد قادمة',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _upcomingAppointments[0].doctorName ??
                                            '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _upcomingAppointments[0]
                                            .consultationType,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${_upcomingAppointments[0].appointmentDate.day}/${_upcomingAppointments[0].appointmentDate.month} ${_upcomingAppointments[0].appointmentTime.hour}:${_upcomingAppointments[0].appointmentTime.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildSectionHeader(
                    context,
                    AppLocalizations.of(context)?.quickActions ??
                        'الإجراءات السريعة',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          AppLocalizations.of(context)?.doctorProfile ??
                              'البحث عن طبيب',
                          Icons.search,
                          () => Navigator.pushNamed(context, '/doctors'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          AppLocalizations.of(context)?.appointments ??
                              'المواعيد',
                          Icons.calendar_today,
                          () => Navigator.pushNamed(context, '/appointments'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          AppLocalizations.of(context)?.profile ??
                              'الملف الشخصي',
                          Icons.person,
                          () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          AppLocalizations.of(context)?.consultation ??
                              'الاستشارة',
                          Icons.chat,
                          () {
                            Navigator.pushNamed(
                              context,
                              '/consultation',
                              arguments: {
                                'name': '',
                                'specialty': '',
                                'rating': 5.0,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          AppLocalizations.of(context)?.wallet ?? 'المحفظة',
                          Icons.account_balance_wallet,
                          () => Navigator.pushNamed(context, '/wallet'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          AppLocalizations.of(context)?.myOrders ?? 'طلباتي',
                          Icons.shopping_bag,
                          () => Navigator.pushNamed(context, '/orders'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Daily Health Tips
                  _buildSectionHeader(
                    context,
                    AppLocalizations.of(context)?.todaysTip ??
                        'نصائح صحية يومية',
                  ),
                  const SizedBox(height: 8),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.todaysTip ??
                                    'نصيحة اليوم',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)?.dailyTipContent ??
                                    'تناول 8 أكواب من الماء يومياً للحفاظ على الترطيب.',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Notifications
                  _buildSectionHeader(
                    context,
                    AppLocalizations.of(context)?.recentNotifications ??
                        'الإشعارات الحديثة',
                    AppLocalizations.of(context)?.viewAll ?? 'عرض الكل',
                    () {
                      _showNotifications();
                    },
                  ),
                  const SizedBox(height: 8),
                  ..._getMockNotifications(context).take(3).map((notification) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(
                                notification['type'],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getNotificationIcon(notification['type']),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification['message'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification['time'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ... (keep helper methods like _buildSectionHeader, _buildQuickActionCard, etc. same as they are UI only)
  Widget _buildSectionHeader(
    BuildContext context,
    String title, [
    String? action,
    VoidCallback? onAction,
  ]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (action != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(action, style: TextStyle(color: AppColors.primary)),
          ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'appointment':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'offer':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'reminder':
        return Icons.alarm;
      case 'offer':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  void _showNotifications() {
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
                AppLocalizations.of(context)?.notificationSettings ??
                    'الإشعارات',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_recentNotifications.isEmpty) ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.noNotifications ??
                            'لا توجد إشعارات',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // ... list notifications
                Expanded(
                  child: ListView(
                    children: _getMockNotifications(context).map((
                      notification,
                    ) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _getNotificationColor(
                                  notification['type'],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getNotificationIcon(notification['type']),
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    notification['message'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    notification['time'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (_recentNotifications.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _recentNotifications.clear();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم مسح جميع الإشعارات')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.clearAllNotifications ??
                          'مسح جميع الإشعارات',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
