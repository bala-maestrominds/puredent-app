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
          AuthLoginRequested(email: _emailController.text.trim(), password: _passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.failure.message)));
          }
          if (state is AuthAuthenticated) {
            context.go('/home');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.local_hospital_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Log in to manage your appointments and records.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'Email',
                    hint: 'john@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email is required';
                      final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                      if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
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
                      if (value == null || value.isEmpty) return 'Password is required';
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: const Text('Sign up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Continue as guest'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
