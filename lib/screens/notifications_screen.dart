import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/localization/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [
    {
      'title':
          'appointment_title', // Will be ignored as we handle title by type
      'message': 'notif_confirm_sara',
      'time': 'time_1_hour_ago',
      'type': 'appointment',
      'isRead': false,
    },
    {
      'title': 'reminder_title',
      'message': 'notif_reminder_ahmed',
      'time': 'time_3_hours_ago',
      'type': 'reminder',
      'isRead': false,
    },
    {
      'title': 'offer_title',
      'message': 'notif_offer_20',
      'time': 'time_yesterday',
      'type': 'offer',
      'isRead': true,
    },
    {
      'title': 'rating_title',
      'message': 'notif_rate_ahmed',
      'time': 'time_2_days_ago',
      'type': 'rating',
      'isRead': true,
    },
    {
      'title': 'security_title',
      'message': 'notif_security_login',
      'time': 'time_3_days_ago',
      'type': 'security',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc?.recentNotifications ?? 'الإشعارات'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              onPressed: () {
                _markAllAsRead();
              },
              icon: const Icon(Icons.done_all),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification, index);
              },
            ),
    );
  }

  String _getLocalizedMessage(BuildContext context, String key) {
    var loc = AppLocalizations.of(context);
    switch (key) {
      case 'notif_confirm_sara':
        return loc?.notifConfirmSara ?? key;
      case 'notif_reminder_ahmed':
        return loc?.notifReminderAhmed ?? key;
      case 'notif_offer_20':
        return loc?.notifOffer20 ?? key;
      case 'notif_rate_ahmed':
        return loc?.notifRateAhmed ?? key;
      case 'notif_security_login':
        return loc?.notifSecurityLogin ?? key;
      default:
        return key;
    }
  }

  String _getLocalizedTime(BuildContext context, String key) {
    var loc = AppLocalizations.of(context);
    switch (key) {
      case 'time_1_hour_ago':
        return loc?.time1HourAgo ?? key;
      case 'time_3_hours_ago':
        return loc?.time3HoursAgo ?? key;
      case 'time_yesterday':
        return loc?.timeYesterday ?? key;
      case 'time_2_days_ago':
        return loc?.time2DaysAgo ?? key;
      case 'time_3_days_ago':
        return loc?.time3DaysAgo ?? key;
      default:
        return key;
    }
  }

  Widget _buildEmptyState() {
    var loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            loc?.notificationsEmptyTitle ?? 'لا توجد إشعارات',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc?.notificationsEmptyDesc ?? 'ستظهر هنا جميع إشعاراتك المهمة',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    var loc = AppLocalizations.of(context);

    String title = notification['title'];
    String message = _getLocalizedMessage(context, notification['message']);
    String time = _getLocalizedTime(context, notification['time']);

    // Localize title based on type
    if (loc != null) {
      switch (type) {
        case 'appointment':
          title = loc.confirmAppointment;
          break;
        case 'reminder':
          title = loc.reminder;
          break;
        case 'offer':
          title = loc.specialOffer;
          break;
        case 'rating':
          title = loc.ratingRequest;
          break;
        case 'security':
          title = loc.securityAlert;
          break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : Colors.blue.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(type),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? AppColors.textPrimary : Colors.blue.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          _markAsRead(index);
        },
        onLongPress: () {
          _showOptionsDialog(index);
        },
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
      case 'rating':
        return Colors.purple;
      case 'security':
        return Colors.red;
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
      case 'rating':
        return Icons.star;
      case 'security':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.markAllRead ?? 'تم تحديد الكل كمقروء',
        ),
      ),
    );
  }

  void _showOptionsDialog(int index) {
    var loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.done),
                title: Text(loc?.markAsRead ?? 'مقروء'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(loc?.delete ?? 'حذف'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteNotification(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(loc?.share ?? 'مشاركة'),
                onTap: () {
                  Navigator.pop(context);
                  _shareNotification(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.notificationDeleted ?? 'تم حذف الإشعار',
        ),
      ),
    );
  }

  void _shareNotification(int index) {
    final notification = _notifications[index];
    final shareText =
        '${notification['title']}\n${notification['message']}\n${notification['time']}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context)?.share}: $shareText'),
      ),
    );
  }
}
