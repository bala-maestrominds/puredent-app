import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 40, color: AppColors.outline),
                    const SizedBox(height: AppSpacing.md),
                    const Text("You're browsing as a guest"),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Log in')),
                  ],
                ),
              ),
            );
          }

          final user = state.user;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              AppSpacing.xl,
              AppSpacing.marginMobile,
              AppSpacing.xl,
            ),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 28,
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                  child: Text(user.name,
                      style: Theme.of(context).textTheme.headlineSmall)),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  user.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.xs,
                      ),
                      leading: const Icon(Icons.event_note_outlined),
                      title: const Text('My Appointments'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/appointments'),
                    ),
                    const Divider(
                        height: 1,
                        indent: AppSpacing.marginMobile,
                        endIndent: AppSpacing.marginMobile),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.xs,
                      ),
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Phone'),
                      subtitle:
                          Text(user.phone.isNotEmpty ? user.phone : 'Not set'),
                    ),
                    const Divider(
                        height: 1,
                        indent: AppSpacing.marginMobile,
                        endIndent: AppSpacing.marginMobile),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.xs,
                      ),
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/settings'),
                    ),
                    const Divider(
                        height: 1,
                        indent: AppSpacing.marginMobile,
                        endIndent: AppSpacing.marginMobile),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.xs,
                      ),
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('About Us'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/about'),
                    ),
                    const Divider(
                        height: 1,
                        indent: AppSpacing.marginMobile,
                        endIndent: AppSpacing.marginMobile),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.xs,
                      ),
                      leading: const Icon(Icons.mail_outline_rounded),
                      title: const Text('Contact Us'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/contact'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go('/home');
                  },
                  icon:
                      const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Log out',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
