import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8087/api';
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8087/api';
    }
    return 'http://localhost:8087/api';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
