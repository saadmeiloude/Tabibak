import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'auth_service.dart';

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return {'success': false, 'message': 'تم إلغاء تسجيل الدخول'};
      }

      // Get user details
      final String email = googleUser.email;
      final String displayName = googleUser.displayName ?? 'Google User';

      // Call our backend API
      final result = await AuthService.loginWithSocial(
        'google',
        email,
        displayName,
      );

      return result;
    } catch (e) {
      return {'success': false, 'message': 'خطأ في تسجيل الدخول: $e'};
    }
  }

  /// Sign in with Facebook
  static Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      // Trigger Facebook Sign In flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get user data
        final userData = await FacebookAuth.instance.getUserData();
        final String email = userData['email'] ?? '';
        final String displayName = userData['name'] ?? 'Facebook User';

        if (email.isEmpty) {
          return {
            'success': false,
            'message': 'لم نتمكن من الحصول على البريد الإلكتروني من Facebook',
          };
        }

        // Call our backend API
        final authResult = await AuthService.loginWithSocial(
          'facebook',
          email,
          displayName,
        );

        return authResult;
      } else if (result.status == LoginStatus.cancelled) {
        return {'success': false, 'message': 'تم إلغاء تسجيل الدخول'};
      } else {
        return {
          'success': false,
          'message': 'فشل تسجيل الدخول: ${result.message}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في تسجيل الدخول: $e'};
    }
  }

  /// Sign out from Google
  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore errors during sign out
    }
  }

  /// Sign out from Facebook
  static Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      // Ignore errors during sign out
    }
  }

  /// Sign out from all social providers
  static Future<void> signOutAll() async {
    await Future.wait([signOutGoogle(), signOutFacebook()]);
  }
}
