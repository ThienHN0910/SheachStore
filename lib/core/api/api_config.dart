import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    return 'http://bookstore26.runasp.net';
  }
}