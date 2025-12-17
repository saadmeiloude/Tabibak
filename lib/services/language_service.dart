import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('ar'); // Default to Arabic

  Locale get currentLocale => _currentLocale;

  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isFrench => _currentLocale.languageCode == 'fr';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic
    Locale('fr'), // French
  ];

  // Initialize language from saved preference
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  // Change language
  Future<void> changeLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }

    _currentLocale = locale;

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);

    notifyListeners();
  }

  // Toggle between Arabic and French
  Future<void> toggleLanguage() async {
    final newLocale = isArabic ? const Locale('fr') : const Locale('ar');
    await changeLanguage(newLocale);
  }

  // Get language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      default:
        return languageCode;
    }
  }

  // Get current language name
  String get currentLanguageName =>
      getLanguageName(_currentLocale.languageCode);
}
