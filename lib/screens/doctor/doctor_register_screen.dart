import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/auth_service.dart';
import '../../core/localization/app_localizations.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseController = TextEditingController();
  final _specializationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.registerDoctor(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        specialization: _specializationController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء حساب الطبيب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/doctor-login');
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          loc?.register ?? 'تسجيل حساب جديد',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.medical_services,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'انضم كطبيب',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Personal Info
                CustomTextField(
                  hintText: loc?.fullName ?? 'الاسم الكامل',
                  controller: _fullNameController,
                  prefixIcon: Icons.person,
                  validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hintText: loc?.email ?? 'البريد الإلكتروني',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  validator: (v) => v!.contains('@') ? null : 'بريد غير صحيح',
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hintText: loc?.phone ?? 'رقم الهاتف',
                  controller: _phoneController,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'الهاتف مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Professional Info
                CustomTextField(
                  hintText: 'رقم الترخيص الطبي',
                  controller: _licenseController,
                  prefixIcon: Icons.badge,
                  validator: (v) => v!.isEmpty ? 'رقم الترخيص مطلوب' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hintText: 'التخصص (مثال: طب عام)',
                  controller: _specializationController,
                  prefixIcon: Icons.work,
                  validator: (v) => v!.isEmpty ? 'التخصص مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  hintText: loc?.password ?? 'كلمة المرور',
                  controller: _passwordController,
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hintText: loc?.confirmPassword ?? 'تأكيد كلمة المرور',
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  validator: (v) => v != _passwordController.text
                      ? 'كلمات المرور غير متطابقة'
                      : null,
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: _isLoading
                      ? (loc?.loading ?? 'جاري التحميل...')
                      : (loc?.register ?? 'تسجيل الحساب'),
                  onPressed: _isLoading ? null : _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
