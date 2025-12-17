import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'password_changed_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _resetMethod = 'email'; // 'email' or 'phone'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعادة تعيين كلمة المرور'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Illustration Placeholder
              Icon(
                Icons.lock_reset, // Placeholder icon
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'أدخل البريد الإلكتروني أو رقم الهاتف المرتبط بحسابك لإعادة تعيين كلمة المرور.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Toggle Method
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _resetMethod = 'phone'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _resetMethod == 'phone'
                                    ? AppColors.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                _resetMethod == 'phone'
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Center(
                            child: Text(
                              'رقم الهاتف',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _resetMethod == 'phone'
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _resetMethod = 'email'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _resetMethod == 'email'
                                    ? AppColors.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                _resetMethod == 'email'
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Center(
                            child: Text(
                              'البريد الإلكتروني',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _resetMethod == 'email'
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Input Field
              if (_resetMethod == 'email')
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'البريد الإلكتروني',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'example@email.com',
                      suffixIcon: Icons.email_outlined,
                    ),
                  ],
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم الهاتف',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: '00000000',
                      suffixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              // Send Button
              CustomButton(
                text: 'إرسال رابط التعيين',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordChangedScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Back to Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('رجوع إلى صفحة الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
