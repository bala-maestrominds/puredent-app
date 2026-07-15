import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/login/admin_login_screen.dart';

void main() {
  runApp(const PureDentAdminApp());
}

class PureDentAdminApp extends StatelessWidget {
  const PureDentAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureDent Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AdminLoginScreen(),
    );
  }
}