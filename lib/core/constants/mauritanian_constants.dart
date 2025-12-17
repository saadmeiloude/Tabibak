// Mauritanian Cities and Constants
class MauritanianConstants {
  // Currency
  static const String currency = 'أوقية'; // MRU - Mauritanian Ouguiya
  static const String currencySymbol = 'أوقية';
  static const String currencyCode = 'MRU';

  // Major Cities
  static const List<String> cities = [
    'نواكشوط', // Nouakchott (Capital)
    'نواذيبو', // Nouadhibou
    'زويرات', // Zouérat
    'أطار', // Atar
    'تجگجة', // Tidjikja
    'روصو', // Rosso
    'كيفة', // Kaédi
    'ألاگ', // Aleg
    'كيهيدي', // Kaédi
    'بوتلميت', // Boutilimit
  ];

  // Nouakchott Districts (أحياء نواكشوط)
  static const List<String> nouakchottDistricts = [
    'عرفات', // Arafat
    'دار النعيم', // Dar Naim
    'دار البركة', // Dar El Barka
    'لكصر', // El Mina
    'تفرغ زينة', // Tevragh Zeina
    'توجنين', // Toujounine
    'الرياض', // Riadh
    'السبخة', // Sebkha
    'كبة', // Ksar
  ];

  // Price ranges in MRU (Ouguiya)
  static const double consultationPriceOnline = 5000; // ~13 USD
  static const double consultationPriceVideo = 6000; // ~16 USD
  static const double appointmentPrice = 10000; // ~26 USD

  // Get full address format
  static String getFullAddress(String district, String city) {
    return '$district، $city';
  }

  // Format price with currency
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} $currencySymbol';
  }
}
