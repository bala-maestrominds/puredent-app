import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/login/admin_login_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';

void main() {
  runApp(const PureDentAdminApp());
}

class PureDentAdminApp extends StatelessWidget {
  const PureDentAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _SessionGate(),
    );
  }
}


class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final restored = await AuthService.instance.restoreSession();
    if (!mounted) return;
    setState(() {
      _loggedIn = restored;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _loggedIn ? const AdminDashboardScreen() : const AdminLoginScreen();
  }
}
