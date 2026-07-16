import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Shared shell for every admin sub-page (Appointments, Patients, etc.):
/// a back button, animated title, and consistent padding -- equivalent to
/// the website's <AdminLayout> wrapper, just adapted for a single-column
/// mobile screen instead of a sidebar layout.
class AdminPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  const AdminPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.headlineSmall),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}