import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد كلمة المرور'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Success Illustration
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              // Success Text
              Text(
                'تم تغيير كلمة المرور بنجاح.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondary, // Blue color as in image
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Advice Text
              Text(
                'نصيحة أمنية: استخدم دائماً كلمة مرور قوية تتضمن مزيجاً من الأحرف الكبيرة والصغيرة والأرقام والرموز لحماية حسابك الطبي.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              // Back to Login Button
              CustomButton(
                text: 'العودة إلى تسجيل الدخول',
                onPressed: () {
                  // Navigate back to Login (pop until first route usually)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              const SizedBox(height: 20),
              Text(
                '© 2024 تطبيق طبيبي. جميع الحقوق محفوظة.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
