import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'about_us_screen.dart';
import 'my_appointments_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

/// No dedicated mockup was provided for Profile yet, so this is a
/// simple placeholder shell — built to match the same design tokens
/// as the other screens. "About Us" lives here as requested, as its
/// own tile that opens the AboutUsScreen below.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.lg, AppSpacing.marginMobile, AppSpacing.xxl),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 32, backgroundColor: AppColors.surfaceContainerHigh, child: Icon(Icons.person, color: AppColors.outline)),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Name', style: AppTextStyles.headlineSm),
                  Text('you@example.com', style: AppTextStyles.bodySm),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _ProfileTile(
            icon: Icons.calendar_month_outlined,
            label: 'My Appointments',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyAppointmentsScreen())),
          ),
          _ProfileTile(
            icon: Icons.favorite_border,
            label: 'Saved',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedScreen())),
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          _ProfileTile(
            icon: Icons.info_outline,
            label: 'About Us',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutUsScreen())),
          ),
          _ProfileTile(
            icon: Icons.logout,
            label: 'Log Out',
            onTap: () => _confirmLogOut(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You\'ll need to sign in again to book or manage appointments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // TODO: wire up actual sign-out logic (clear session, navigate to auth screen, etc.)
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: AppTextStyles.bodyMd),
        trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
    );
  }
}

