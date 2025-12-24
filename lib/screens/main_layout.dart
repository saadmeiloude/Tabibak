import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'home_screen.dart';
import 'doctors_screen.dart';
import 'profile_screen.dart';
import 'appointments_screen.dart';
import 'notifications_screen.dart';
import '../core/localization/app_localizations.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const AppointmentsScreen(), // Calendar/Appointments
    const NotificationsScreen(), // Notifications
    const DoctorsScreen(), // Search/Doctors
    const ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            label: AppLocalizations.of(context)?.home ?? 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            label: AppLocalizations.of(context)?.appointments ?? 'التقويم',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_none_outlined),
            label:
                AppLocalizations.of(context)?.notificationSettings ??
                'الإشعارات',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppLocalizations.of(context)?.search ?? 'البحث',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: AppLocalizations.of(context)?.profile ?? 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}
