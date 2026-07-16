import 'api_client.dart';

/// Calls the real backend (`POST /api/auth/login`) and only allows sign-in
/// for accounts with `role == 'admin'`. Seed an admin account first:
///
///   cd backend
///   npm run seed:admin
///   # or: node src/db/seedAdmin.js --email you@clinic.com --password Something123
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Map<String, dynamic>? _currentUser;

  bool get isLoggedIn => ApiClient.instance.hasToken && _currentUser != null;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Restores a persisted session on app start. Returns true if a valid
  /// admin session was restored.
  Future<bool> restoreSession() async {
    await ApiClient.instance.loadToken();
    if (!ApiClient.instance.hasToken) return false;

    try {
      final data = await ApiClient.instance.get('/auth/me');
      if (data is Map && data['role'] == 'admin') {
        _currentUser = Map<String, dynamic>.from(data);
        return true;
      }
      await ApiClient.instance.setToken(null);
      return false;
    } catch (_) {
      await ApiClient.instance.setToken(null);
      return false;
    }
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> login(String email, String password) async {
    try {
      final data = await ApiClient.instance.post('/auth/login', body: {
        'email': email.trim(),
        'password': password,
      });

      final user = data['user'] as Map<String, dynamic>;
      if (user['role'] != 'admin') {
        return 'This account does not have admin access.';
      }

      await ApiClient.instance.setToken(data['accessToken'] as String);
      _currentUser = user;
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not reach the server. Check your connection and try again.';
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {
      // Ignore -- we clear the local session regardless.
    }
    await ApiClient.instance.setToken(null);
    _currentUser = null;
  }
}
