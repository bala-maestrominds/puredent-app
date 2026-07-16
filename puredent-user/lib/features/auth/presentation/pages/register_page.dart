import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                  Text('Join PureDent', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Create an account to book and track appointments.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 28),
                  AppTextField(
                    label: 'Full name',
                    hint: 'John Doe',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your full name' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    hint: 'john@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email is required';
                      final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                      if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone (optional)',
                    hint: '+1 (555) 000-0000',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Password',
                    hint: 'At least 8 characters',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Confirm password',
                    hint: 'Re-enter your password',
                    controller: _confirmController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v != _passwordController.text) ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppPrimaryButton(
                        label: 'Create account',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text('Log in', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
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
