import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Converted from the PureDent website's contact.jsx. Same fields, same
/// validation rules, same honeypot anti-spam field, wired to the same
/// `POST /contact` endpoint the website uses.
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

enum _SubmitStatus { idle, submitting, success, error }

class _ContactPageState extends State<ContactPage> {
  static const _services = [
    'General Dentistry',
    'Cosmetic Dentistry',
    'Orthodontics',
    'Oral Surgery',
    'Periodontics',
  ];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  // Honeypot: left empty by real users, filled in by bots. If it has a
  // value on submit we silently drop the request, same as the website.
  final _companyController = TextEditingController();

  String _service = _services.first;
  _SubmitStatus _status = _SubmitStatus.idle;
  String? _errorMessage;

  String? _nameError;
  String? _emailError;
  String? _messageError;

  static final _emailRegex = RegExp(r'^\S+@\S+\.\S+$');

  @override
  void initState() {
    super.initState();
    // Prefill from the logged-in user, same convenience the app already
    // gives you on other forms (e.g. booking).
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.user.name;
      _emailController.text = authState.user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Please enter your name.' : null;
      if (_emailController.text.trim().isEmpty) {
        _emailError = 'Please enter your email.';
      } else if (!_emailRegex.hasMatch(_emailController.text.trim())) {
        _emailError = 'Enter a valid email address.';
      } else {
        _emailError = null;
      }
      _messageError = _messageController.text.trim().isEmpty ? 'Please enter a message.' : null;
    });
    return _nameError == null && _emailError == null && _messageError == null;
  }

  Future<void> _submit() async {
    setState(() => _status = _SubmitStatus.idle);

    if (!_validate()) return;
    if (_companyController.text.isNotEmpty) return; // honeypot tripped

    setState(() => _status = _SubmitStatus.submitting);

    try {
      final dio = getIt<DioClient>().dio;
      await dio.post('/contact', data: {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'service': _service,
        'message': _messageController.text.trim(),
      });

      if (!mounted) return;
      setState(() {
        _status = _SubmitStatus.success;
        _messageController.clear();
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _SubmitStatus.error;
        _errorMessage = e.message ?? 'Something went wrong';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _SubmitStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Contact Us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile, AppSpacing.lg, AppSpacing.marginMobile, AppSpacing.xl),
        children: [
          Text('Get in Touch', style: AppTypography.headlineLg(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Whether you have questions about a procedure or wish to schedule a '
            'consultation, our team is here to help.',
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),

          _FieldLabel('Full Name'),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('John Doe', error: _nameError),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _FieldLabel('Email Address'),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('john@example.com', error: _emailError),
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _FieldLabel('Service Interest'),
          DropdownButtonFormField<String>(
            initialValue: _service,
            decoration: _inputDecoration(null),
            items: _services
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _service = value);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _FieldLabel('Your Message'),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: _inputDecoration('How can we help you today?', error: _messageError),
            onChanged: (_) {
              if (_messageError != null) setState(() => _messageError = null);
            },
          ),

          // Honeypot -- present but invisible/unreachable to real users.
          Offstage(
            offstage: true,
            child: TextField(controller: _companyController),
          ),

          if (_status == _SubmitStatus.success) ...[
            const SizedBox(height: AppSpacing.md),
            _StatusBanner(
              icon: Icons.check_circle,
              color: AppColors.success,
              text: "Thanks — your message has been sent. We'll be in touch within 24 hours.",
            ),
          ],
          if (_status == _SubmitStatus.error) ...[
            const SizedBox(height: AppSpacing.md),
            _StatusBanner(
              icon: Icons.error,
              color: AppColors.error,
              text: _errorMessage ?? 'Something went wrong sending your message. Please try again.',
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _status == _SubmitStatus.submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: _status == _SubmitStatus.submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : const Text('Send Inquiry'),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          _ClinicInfoCard(),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint, {String? error}) {
    return InputDecoration(
      hintText: hint,
      errorText: error,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: AppTypography.labelMd(color: AppColors.onSurface)),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.bodySm(color: color)),
          ),
        ],
      ),
    );
  }
}

class _ClinicInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: const [
          _InfoTile(icon: Icons.call, label: 'Phone Support', value: '+91 9876543210'),
          Divider(height: 1, indent: AppSpacing.marginMobile, endIndent: AppSpacing.marginMobile),
          _InfoTile(icon: Icons.mail, label: 'Email Inquiry', value: 'care@puredent.com'),
          Divider(height: 1, indent: AppSpacing.marginMobile, endIndent: AppSpacing.marginMobile),
          _InfoTile(
            icon: Icons.location_on,
            label: 'Our Address',
            value: '1200 Health Plaza, Suite 400, Central Medical District, NY 10001',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: AppSpacing.xs),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTypography.labelMd()),
      subtitle: Text(value, style: AppTypography.bodyMd(color: AppColors.onSurface)),
    );
  }
}
