import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'core/localization/app_localizations.dart';
import 'services/data_service.dart';
import 'services/language_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/password_changed_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/consultation_screen.dart';
import 'screens/booking_calendar_screen.dart';
import 'screens/doctor_profile_screen.dart';
import 'screens/main_layout.dart';
import 'screens/doctor/doctor_login_screen.dart';
import 'screens/doctor/doctor_layout.dart';
import 'screens/doctor/appointment_management_screen.dart';
import 'screens/doctor/patient_file_screen.dart';
import 'screens/doctor/doctor_chat_screen.dart';
import 'screens/doctor/patient_list_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.init();

  // Initialize language service
  final languageService = LanguageService();
  await languageService.init();

  runApp(
    ChangeNotifierProvider.value(value: languageService, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          title: 'Tabibek',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            scaffoldBackgroundColor: AppColors.background,
            useMaterial3: true,
            textTheme: _buildTextTheme(),
          ),
          // Localization setup
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageService.supportedLocales,
          locale: languageService.currentLocale,
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const MainLayout(),
            '/doctors': (context) => const DoctorsScreen(),
            '/appointments': (context) => const AppointmentsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/consultation': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>?;
              return ConsultationScreen(doctor: args);
            },
            '/booking-calendar': (context) => const BookingCalendarScreen(),
            '/doctor-profile': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>; // Assume required
              return DoctorProfileScreen(doctor: args);
            },
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/password-changed': (context) => const PasswordChangedScreen(),
            '/doctor-login': (context) => const DoctorLoginScreen(),
            '/doctor-home': (context) => const DoctorLayout(),
            '/doctor-appointments': (context) =>
                const AppointmentManagementScreen(),
            '/patient-file': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>?;
              return PatientFileScreen(patient: args ?? {});
            },
            '/doctor-chat': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>?;
              return DoctorChatScreen(patient: args ?? {});
            },
            '/patient-list': (context) => const PatientListScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/cards': (context) => const CardsScreen(),
            '/orders': (context) => const OrdersScreen(),
          },
        );
      },
    );
  }

  TextTheme _buildTextTheme() {
    try {
      // Try to use Google Fonts with fallback
      return GoogleFonts.cairoTextTheme().copyWith(
        // Ensure all text styles have fallback fonts
        displayLarge: const TextStyle(fontFamily: 'Arial, sans-serif'),
        displayMedium: const TextStyle(fontFamily: 'Arial, sans-serif'),
        displaySmall: const TextStyle(fontFamily: 'Arial, sans-serif'),
        headlineLarge: const TextStyle(fontFamily: 'Arial, sans-serif'),
        headlineMedium: const TextStyle(fontFamily: 'Arial, sans-serif'),
        headlineSmall: const TextStyle(fontFamily: 'Arial, sans-serif'),
        titleLarge: const TextStyle(fontFamily: 'Arial, sans-serif'),
        titleMedium: const TextStyle(fontFamily: 'Arial, sans-serif'),
        titleSmall: const TextStyle(fontFamily: 'Arial, sans-serif'),
        bodyLarge: const TextStyle(fontFamily: 'Arial, sans-serif'),
        bodyMedium: const TextStyle(fontFamily: 'Arial, sans-serif'),
        bodySmall: const TextStyle(fontFamily: 'Arial, sans-serif'),
        labelLarge: const TextStyle(fontFamily: 'Arial, sans-serif'),
        labelMedium: const TextStyle(fontFamily: 'Arial, sans-serif'),
        labelSmall: const TextStyle(fontFamily: 'Arial, sans-serif'),
      );
    } catch (e) {
      // Fallback to system fonts if Google Fonts fail
      debugPrint('Google Fonts failed, using system fonts: $e');
      return const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Arial, sans-serif'),
        displayMedium: TextStyle(fontFamily: 'Arial, sans-serif'),
        displaySmall: TextStyle(fontFamily: 'Arial, sans-serif'),
        headlineLarge: TextStyle(fontFamily: 'Arial, sans-serif'),
        headlineMedium: TextStyle(fontFamily: 'Arial, sans-serif'),
        headlineSmall: TextStyle(fontFamily: 'Arial, sans-serif'),
        titleLarge: TextStyle(fontFamily: 'Arial, sans-serif'),
        titleMedium: TextStyle(fontFamily: 'Arial, sans-serif'),
        titleSmall: TextStyle(fontFamily: 'Arial, sans-serif'),
        bodyLarge: TextStyle(fontFamily: 'Arial, sans-serif'),
        bodyMedium: TextStyle(fontFamily: 'Arial, sans-serif'),
        bodySmall: TextStyle(fontFamily: 'Arial, sans-serif'),
        labelLarge: TextStyle(fontFamily: 'Arial, sans-serif'),
        labelMedium: TextStyle(fontFamily: 'Arial, sans-serif'),
        labelSmall: TextStyle(fontFamily: 'Arial, sans-serif'),
      );
    }
  }
}
