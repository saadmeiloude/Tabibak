import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

import '../../services/auth_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/user.dart';
import '../../core/models/enums.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  Image.asset(
                    'assets/images/Doctors-pana.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc?.appName ?? 'طبيبي',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Welcome Text
                  Text(
                    loc?.welcomeBackDoctor ?? 'مرحباً بعودتك، دكتور',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Fields
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      loc?.emailOrPhoneLabel ??
                          'البريد الإلكتروني أو رقم الهاتف',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText:
                        loc?.emailOrPhoneHint ??
                        'أدخل بريدك الإلكتروني أو رقم هاتفك',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc?.emailOrPhoneLabel ??
                            'يرجى إدخال البريد الإلكتروني';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      loc?.password ?? 'كلمة المرور',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: loc?.enterPasswordHint ?? 'أدخل كلمة المرور',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixIconPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc?.enterPasswordHint ??
                            'يرجى إدخال كلمة المرور';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        activeColor: AppColors.primary,
                      ),
                      Text(loc?.rememberMe ?? 'تذكرني'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Navigate to forgot password screen
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: Text(loc?.forgotPassword ?? 'نسيت كلمة المرور؟'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: _isLoading
                        ? (loc?.loading ?? 'جاري التحميل...')
                        : (loc?.login ?? 'تسجيل الدخول'),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                final result = await AuthService.login(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );

                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                    if (result['success']) {
                                      // Check if user is actually a doctor
                                      final userMap = result['user'];
                                      print('DEBUG: Doctor login - user map: $userMap');
                                      final user = User.fromJson(userMap);
                                      print('DEBUG: Doctor login - parsed user.role: ${user.role}');
                                      print('DEBUG: Doctor login - parsed user.userType: ${user.userType}');
                                      
                                      // Check both userType and role (case insensitive)
                                      final isDoctor = (user.userType?.toLowerCase() == 'doctor') || 
                                                      (user.role == UserRole.doctor);
                                      print('DEBUG: Doctor login - isDoctor: $isDoctor');
                                      
                                      if (isDoctor) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/doctor-home',
                                        );
                                      } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            loc?.notDoctorAccountError ??
                                                'هذا الحساب ليس حساب طبيب',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      await AuthService.logout();
                                      if (context.mounted) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/',
                                          (route) => false,
                                        );
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message']),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(loc?.dontHaveAccount ?? 'ليس لديك حساب؟'),
                      TextButton(
                        onPressed: () {
                          // Navigate to doctor registration screen
                          Navigator.pushNamed(context, '/doctor-register');
                        },
                        child: Text(loc?.registerNow ?? 'سجل الآن'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
