import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'doctor_home_screen.dart';
import 'appointment_management_screen.dart';
import 'patient_list_screen.dart';
import 'doctor_settings_screen.dart'; // Import Settings Screen
import '../wallet_screen.dart'; // Import Wallet Screen
import '../../core/localization/app_localizations.dart';

class DoctorLayout extends StatefulWidget {
  const DoctorLayout({super.key});

  @override
  State<DoctorLayout> createState() => _DoctorLayoutState();
}

class _DoctorLayoutState extends State<DoctorLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DoctorHomeScreen(),
    const AppointmentManagementScreen(), // Calendar/Appointments
    const PatientListScreen(), // Patients List
    const WalletScreen(), // Wallet/Payments
    const DoctorSettingsScreen(), // Profile/Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: AppLocalizations.of(context)?.home ?? 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: AppLocalizations.of(context)?.calendar ?? 'التقويم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: AppLocalizations.of(context)?.patientsTitle ?? 'المرضى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: AppLocalizations.of(context)?.wallet ?? 'المحفظة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)?.myProfile ?? 'ملفي',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show quick action menu
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إضافة جديدة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          Icons.calendar_today,
                          'موعد جديد',
                          Colors.blue.shade100,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          Icons.person_add,
                          'مريض جديد',
                          Colors.green.shade100,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        heroTag: "doctor_layout_fab",
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (label == 'موعد جديد') {
          // Navigate to appointment creation
          setState(() => _currentIndex = 1);
        } else if (label == 'مريض جديد') {
          // Navigate to patient creation
          setState(() => _currentIndex = 2);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
