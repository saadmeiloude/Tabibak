import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';
import 'login_selection_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../core/localization/app_localizations.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && mounted) {
      if (user.userType == 'doctor') {
        Navigator.pushReplacementNamed(context, '/doctor-home');
      } else if (user.userType == 'patient') {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Language Switcher
              Align(
                alignment: Alignment.topRight,
                child: Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: languageService.currentLocale.languageCode,
                          icon: const Icon(
                            Icons.language,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text(
                                'العربية',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text(
                                'Français',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              languageService.changeLanguage(Locale(newValue));
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Illustration
                  Image.asset(
                    'assets/images/Medicine-hom.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  // Logo/Title
                  Text(
                    loc?.appName ?? 'طبيبي',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    loc?.welcomeSubtitle ??
                        'صحتك، مبسطة. احجز أطباء موثوقين، مواعيد، وأدر سجلاتك الصحية في مكان واحد.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Start Now Button
                  CustomButton(
                    text: loc?.startNow ?? 'ابدأ الآن',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Continue Without Login Button
                  CustomButton(
                    text: loc?.exploreApp ?? 'استكشاف التطبيق',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    isOutlined: true,
                    textColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  // Google Button
                  CustomButton(
                    text: loc?.continueGoogle ?? 'الاستمرار باستخدام Google',
                    onPressed: () => _handleSocialLogin('google'),
                    isOutlined: true,
                    textColor: AppColors.textPrimary,
                    icon: Image.asset(
                      'assets/icons/google.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Facebook Button
                  CustomButton(
                    text:
                        loc?.continueFacebook ?? 'الاستمرار باستخدام Facebook',
                    onPressed: () => _handleSocialLogin('facebook'),
                    isOutlined: true,
                    textColor: AppColors.textPrimary,
                    icon: Image.asset(
                      'assets/icons/facebook.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Watch Video
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc?.watchVideo ?? 'شاهد فيديو سريع عن كيفية الحجز',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Registration Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(loc?.dontHaveAccount ?? 'ليس لديك حساب؟'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(loc?.register ?? 'تسجيل جديد'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (provider == 'google') {
        result = await SocialAuthService.signInWithGoogle();
      } else if (provider == 'facebook') {
        result = await SocialAuthService.signInWithFacebook();
      } else {
        result = {'success': false, 'message': 'منصة غير مدعومة'};
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  bool _isLoading = false;
}
