import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static const String? _lanIp =
      '10.239.146.78'; // <-- computer's LAN IP

  static const int _port = 5000;

  static String get baseUrl {
    if (_lanIp != null) return 'http://$_lanIp:$_port';
    if (kIsWeb) return 'http://localhost:$_port';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:$_port';
    } catch (_) {}
    return 'http://localhost:$_port';
  }

  static String get apiUrl => '$baseUrl/api';
}
