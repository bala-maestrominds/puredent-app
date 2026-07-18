import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -140,
            left: -160,
            child: _blob(360, AppColors.surfaceContainerHigh),
          ),
          Positioned(
            bottom: -120,
            right: -140,
            child: _blob(320, AppColors.surfaceContainerHigh),
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                      SnackBar(content: Text(state.failure.message)));
              }
              if (state is AuthAuthenticated) {
                final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
                context.go(redirect != null && redirect.isNotEmpty ? redirect : '/home');
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Icon badge
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/icons/app.png',
                          color: Colors
                              .white, // remove this line if your logo is multi-color
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 32,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log in to manage your appointments and records.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 32),
                      // Card wrapping the form fields
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Email',
                              hint: 'john@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline_rounded,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Email is required';
                                final regex =
                                    RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                                if (!regex.hasMatch(value.trim()))
                                  return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              obscureText: true,
                              prefixIcon: Icons.lock_outline_rounded,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Password is required';
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return AppPrimaryButton(
                                  label: 'Log in',
                                  isLoading: state is AuthLoading,
                                  onPressed: _submit,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: const Text('Sign up',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Continue as guest'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}