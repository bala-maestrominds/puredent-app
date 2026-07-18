import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../bloc/booking_bloc.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BookingBloc>().state;
    final appointment = state.confirmedAppointment;

    if (appointment == null) {
      // Guard against deep-link / back-navigation into this route directly.
      return Scaffold(
        body: Center(
          child: AppPrimaryButton(label: 'Back to Home', expand: false, onPressed: () => context.go('/home')),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Appointment Confirmed', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'A confirmation has been sent to ${appointment.patientEmail}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (state.qrCodeDataUrl != null && state.qrCodeDataUrl!.isNotEmpty) _QrTicket(dataUrl: state.qrCodeDataUrl!),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _Row(label: 'Booking Code', value: appointment.appointmentCode),
                      _Row(label: 'Date', value: appointment.date),
                      _Row(label: 'Time', value: appointment.time),
                      _Row(label: 'Status', value: appointment.status),
                      _Row(label: 'Paid Now', value: '₹${appointment.amountPaid.toStringAsFixed(2)}'),
                      if (appointment.balanceDue > 0)
                        _Row(label: 'Balance Due at Treatment', value: '₹${appointment.balanceDue.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: 'View My Appointments',
                onPressed: () {
                  context.read<BookingBloc>().add(const BookingReset());
                  context.go('/appointments');
                },
              ),
              const SizedBox(height: 12),
              AppPrimaryButton(
                label: 'Back to Home',
                expand: true,
                onPressed: () {
                  context.read<BookingBloc>().add(const BookingReset());
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrTicket extends StatelessWidget {
  const _QrTicket({required this.dataUrl});
  final String dataUrl;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    try {
      final base64Part = dataUrl.split(',').last;
      bytes = base64Decode(base64Part);
    } catch (_) {
      bytes = null;
    }
    if (bytes == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Image.memory(bytes, width: 180, height: 180),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
