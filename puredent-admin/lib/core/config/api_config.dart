
class ApiConfig {
  ApiConfig._();

  static const String _lanIp =
      'puredent-app.onrender.com'; 

  static String get baseUrl {
    return 'https://$_lanIp';
  }

  static String get apiUrl => '$baseUrl/api';
}
