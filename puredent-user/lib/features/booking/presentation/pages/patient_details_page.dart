import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/booking_bloc.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({super.key});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();
  String? _gender;

  @override
  void initState() {
    super.initState();
    final booking = context.read<BookingBloc>().state;
    _nameController = TextEditingController(text: booking.patientName ?? '');
    _emailController = TextEditingController(text: booking.patientEmail ?? '');
    _phoneController = TextEditingController(text: booking.patientPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BookingBloc>().add(BookingPatientDetailsSubmitted(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          age: int.tryParse(_ageController.text.trim()),
          gender: _gender,
          notes: _notesController.text.trim(),
        ));
    context.push('/booking/payment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Full name',
                  hint: 'John Doe',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Enter patient name' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'john@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email is required';
                    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Phone',
                  hint: '+1 (555) 000-0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (v) => (v == null || v.trim().length < 6) ? 'Enter a valid phone number' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Age (optional)',
                        hint: '28',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(),
                            items: const ['Male', 'Female', 'Other']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Notes (optional)',
                  hint: 'e.g. Routine checkup, toothache…',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                AppPrimaryButton(label: 'Continue to Payment', onPressed: _continue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
