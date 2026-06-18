import 'dart:io' show Platform;

class ApiConfig {
  ApiConfig._();

  static const String _hostPort = '5202';

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_hostPort';
    }

    return 'http://localhost:$_hostPort';
  }
}
