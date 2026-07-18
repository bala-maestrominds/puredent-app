
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://puredent-app.onrender.com/api', 
  );

  static const bool enableNetworkLogs = bool.fromEnvironment('ENABLE_NETWORK_LOGS', defaultValue: true);

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Debounce window used for search fields across the app (services, doctors, etc).
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Page size used for all paginated / lazy-loaded lists.
  static const int pageSize = 12;
}
