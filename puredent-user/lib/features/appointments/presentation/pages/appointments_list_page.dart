import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointments_bloc.dart';

class AppointmentsListPage extends StatelessWidget {
  const AppointmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthBloc>().state is AuthAuthenticated;

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Appointments')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.outline),
                const SizedBox(height: 12),
                Text('Log in to see your appointments', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => context.push('/login'), child: const Text('Log in')),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => getIt<AppointmentsBloc>()..add(const AppointmentsFetchRequested()),
      child: const _AppointmentsListView(),
    );
  }
}

class _AppointmentsListView extends StatelessWidget {
  const _AppointmentsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == AppointmentActionStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.actionMessage ?? 'Done')));
          } else if (state.actionStatus == AppointmentActionStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.actionFailure?.message ?? 'Something went wrong')));
          }
        },
        builder: (context, state) {
          if (state.status == AppointmentsStatus.loading || state.status == AppointmentsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AppointmentsStatus.failure) {
            return Center(child: Text(state.failure?.message ?? 'Failed to load appointments'));
          }
          if (state.appointments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_busy_outlined, size: 40, color: AppColors.outline),
                    const SizedBox(height: 12),
                    const Text('No appointments yet'),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => context.go('/services'), child: const Text('Book Now')),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<AppointmentsBloc>().add(const AppointmentsFetchRequested()),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: state.appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _AppointmentTile(appointment: state.appointments[index]),
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});
  final AppointmentEntity appointment;

  Color _statusColor() {
    switch (appointment.status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      case 'Completed':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  Color _paymentColor() {
    switch (appointment.paymentStatus) {
      case 'paid':
        return AppColors.success;
      case 'partially_paid':
        return AppColors.warning;
      default:
        return AppColors.outline;
    }
  }

  String _paymentLabel() {
    switch (appointment.paymentStatus) {
      case 'paid':
        return 'Paid';
      case 'partially_paid':
        return 'Balance due ₹${appointment.balanceDue.toStringAsFixed(2)}';
      default:
        return 'Payment pending';
    }
  }

  Future<void> _showRescheduleSheet(BuildContext context) async {
    final bloc = context.read<AppointmentsBloc>();
    final now = DateTime.now();
    final initialDate = DateTime.tryParse(appointment.date) ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (pickedDate == null || !context.mounted) return;

    final timeParts = appointment.time.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(timeParts.isNotEmpty ? timeParts[0] : '') ?? 9,
      minute: int.tryParse(timeParts.length > 1 ? timeParts[1] : '') ?? 0,
    );
    final pickedTime = await showTimePicker(context: context, initialTime: initialTime);
    if (pickedTime == null || !context.mounted) return;

    final date =
        '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
    final time = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reschedule appointment'),
        content: Text('Move this appointment to $date at $time?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(AppointmentRescheduleRequested(appointmentId: appointment.id, date: date, time: time));
    }
  }

  Future<void> _showPayOnlineSheet(BuildContext context) async {
    final bloc = context.read<AppointmentsBloc>();
    String method = 'Card';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.marginMobile,
                right: AppSpacing.marginMobile,
                top: AppSpacing.marginMobile,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.marginMobile,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pay Online', style: Theme.of(sheetContext).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    appointment.isConsultationOnly
                        ? 'Settle the remaining balance for your treatment.'
                        : 'Pay the full amount for your treatment.',
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to pay'),
                          Text(
                            '₹${appointment.balanceDue.toStringAsFixed(2)}',
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Payment method', style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  ...['Card', 'PayPal', 'Razorpay'].map(
                    (m) => RadioListTile<String>(
                      value: m,
                      groupValue: method,
                      contentPadding: EdgeInsets.zero,
                      title: Text(m),
                      onChanged: (v) => setState(() => method = v!),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: Text('Pay ₹${appointment.balanceDue.toStringAsFixed(2)}'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed == true) {
      bloc.add(AppointmentPayRequested(appointmentId: appointment.id, paymentMethod: method));
    }
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final bloc = context.read<AppointmentsBloc>();
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this appointment?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep appointment')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(AppointmentCancelRequested(
        appointmentId: appointment.id,
        reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(AppRadius.base)),
                  child: const Icon(Icons.event_available_rounded, color: AppColors.onPrimaryContainer),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.serviceName ?? 'Appointment', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text('${appointment.date} · ${appointment.time}', style: Theme.of(context).textTheme.bodySmall),
                      if (appointment.doctorName != null)
                        Text('Dr. ${appointment.doctorName}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration:
                      BoxDecoration(color: _statusColor().withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.full)),
                  child: Text(appointment.status, style: TextStyle(color: _statusColor(), fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.payments_outlined, size: 16, color: _paymentColor()),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appointment.isConsultationOnly
                        ? 'Consultation fee paid · ${_paymentLabel()}'
                        : _paymentLabel(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _paymentColor(), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (appointment.hasBalanceDue && appointment.status != 'Cancelled') ...[
              const SizedBox(height: AppSpacing.sm),
              if (appointment.canPayOnline)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showPayOnlineSheet(context),
                    icon: const Icon(Icons.credit_card_rounded, size: 18),
                    label: Text('Pay Online · ₹${appointment.balanceDue.toStringAsFixed(2)}'),
                  ),
                )
              else if (appointment.isConsultationOnly && !appointment.isCheckedIn)
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "You can pay the remaining balance online once you're checked in at the clinic.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline),
                      ),
                    ),
                  ],
                ),
            ],
            if (appointment.canReschedule || appointment.canCancel) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (appointment.canReschedule)
                    TextButton.icon(
                      onPressed: () => _showRescheduleSheet(context),
                      icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                      label: const Text('Reschedule'),
                    ),
                  if (appointment.canCancel)
                    TextButton.icon(
                      onPressed: () => _showCancelDialog(context),
                      icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                      label: const Text('Cancel', style: TextStyle(color: AppColors.error)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
