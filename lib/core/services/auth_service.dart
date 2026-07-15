/// Mirrors client/src/utils/auth.js from the website.
///
/// Fixed admin credentials for now -- fine for a class project, but for a
/// real production app this check should move to a backend endpoint instead
/// of living in the compiled app.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _adminUsername = 'admin';
  static const _adminPassword = 'PureDent@2024';

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  /// Returns true on success. Simulates a small network delay so the button's
  /// loading state feels real, matching the website's login page behavior.
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final success = username.trim() == _adminUsername && password == _adminPassword;
    if (success) _isLoggedIn = true;
    return success;
  }

  void logout() {
    _isLoggedIn = false;
  }
}