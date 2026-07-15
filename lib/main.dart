import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';

void main() {
  runApp(const PureDentApp());
}

class PureDentApp extends StatelessWidget {
  const PureDentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureDent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Home screen has no mockup yet -> Services tab (index 2) is a
      // reasonable default landing point until you design one.
      home: const AppShell(initialIndex: 2),
    );
  }
}
