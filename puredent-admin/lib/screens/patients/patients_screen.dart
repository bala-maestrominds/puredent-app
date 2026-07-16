import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/appointment.dart';
import '../../core/models/patient.dart';
import '../../core/services/admin_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

String _initials(String name) =>
    name.split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join().toUpperCase();

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _search = '';
  Timer? _debounce;
  late Future<List<Patient>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminApiService.instance.listPatients();
  }

  void _onSearchChanged(String value) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _refresh);
  }

  Future<void> _refresh() async {
    final future = AdminApiService.instance.listPatients(search: _search.isEmpty ? null : _search);
    setState(() => _future = future);
    await future;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _openDetail(Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PatientDetailSheet(patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Patients',
      subtitle: 'Derived from appointment records',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Patient>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(message: '${snapshot.error}', onRetry: _refresh);
                }
                final patients = snapshot.data ?? const [];
                if (patients.isEmpty) {
                  return Center(child: Text('No patients match your search.', style: Theme.of(context).textTheme.bodyMedium));
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: patients.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = patients[index];
                      return StaggeredFadeIn(
                        index: index,
                        child: GestureDetector(
                          onTap: () => _openDetail(p),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: Text(
                                    _initials(p.name),
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                                      Text(p.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${p.totalAppointments}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                                    const Text('visits', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.outline, size: 40),
            const SizedBox(height: 12),
            Text('Could not load patients', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _PatientDetailSheet extends StatefulWidget {
  final Patient patient;
  const _PatientDetailSheet({required this.patient});

  @override
  State<_PatientDetailSheet> createState() => _PatientDetailSheetState();
}

class _PatientDetailSheetState extends State<_PatientDetailSheet> {
  late Future<List<Appointment>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminApiService.instance.getPatientAppointments(widget.patient.email);
  }

  static const _statusColors = {
    'Confirmed': AppColors.secondaryContainer,
    'In-Progress': AppColors.tertiaryFixed,
    'Pending': AppColors.surfaceContainerHigh,
    'Completed': AppColors.primaryFixed,
    'Cancelled': AppColors.errorContainer,
  };

  void _openAppointment(Appointment a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailSheet(appointment: a),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(_initials(patient.name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name, style: Theme.of(context).textTheme.headlineSmall),
                      if (patient.gender.isNotEmpty || patient.age != null)
                        Text(
                          [if (patient.gender.isNotEmpty) patient.gender, if (patient.age != null) '${patient.age} yrs'].join(' · '),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _row(Icons.mail_outline_rounded, patient.email),
            const SizedBox(height: 10),
            _row(Icons.call_outlined, patient.phone),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _statBox(context, 'Last Visit', patient.lastVisit.isEmpty ? '—' : patient.lastVisit)),
                const SizedBox(width: 12),
                Expanded(child: _statBox(context, 'Total Visits', '${patient.totalAppointments}')),
              ],
            ),
            const SizedBox(height: 24),
            Text('Appointment History', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FutureBuilder<List<Appointment>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('Could not load history: ${snapshot.error}', style: const TextStyle(fontSize: 12, color: AppColors.error)),
                  );
                }
                final appointments = snapshot.data ?? const [];
                if (appointments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No appointments on record.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  );
                }
                return Column(
                  children: List.generate(appointments.length, (i) {
                    final a = appointments[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: i == appointments.length - 1 ? 0 : 10),
                      child: StaggeredFadeIn(
                        index: i,
                        child: GestureDetector(
                          onTap: () => _openAppointment(a),
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.serviceName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                      const SizedBox(height: 2),
                                      Text('${a.doctorName} · ${a.date} ${a.time}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (_statusColors[a.status] ?? AppColors.surfaceContainerHigh).withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(a.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _statBox(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Full detail for a single appointment, opened from a patient's history list.
class _AppointmentDetailSheet extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentDetailSheet({required this.appointment});

  static const _statusColors = {
    'Confirmed': AppColors.secondaryContainer,
    'In-Progress': AppColors.tertiaryFixed,
    'Pending': AppColors.surfaceContainerHigh,
    'Completed': AppColors.primaryFixed,
    'Cancelled': AppColors.errorContainer,
  };

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.serviceName, style: Theme.of(context).textTheme.headlineSmall),
                    Text('#${a.appointmentCode}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (_statusColors[a.status] ?? AppColors.surfaceContainerHigh).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(a.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _detailRow(Icons.person_outline_rounded, 'Dentist', '${a.doctorName}${a.doctorSpecialty.isNotEmpty ? ' · ${a.doctorSpecialty}' : ''}'),
          const SizedBox(height: 10),
          _detailRow(Icons.schedule_rounded, 'Date & Time', '${a.date} · ${a.time}'),
          const SizedBox(height: 10),
          _detailRow(
            Icons.check_circle_outline_rounded,
            'Check-in Status',
            a.checkInStatus == 'checked_in' ? 'Checked in' : 'Not arrived yet',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statBox('Total Cost', '\$${a.amount}')),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  'Payment',
                  _paymentLabel(a.paymentStatus),
                  color: _paymentColor(a.paymentStatus),
                ),
              ),
            ],
          ),
          if (a.isConsultationFeeOnly) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.tertiaryFixed.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Consultation Fee Only', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        Text(
                          'Paid \$${a.amountPaid} of \$${a.amount} · \$${a.balanceDue} due at visit',
                          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _paymentLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'partially_paid':
        return 'Partially Paid';
      default:
        return 'Pending';
    }
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.secondary;
      case 'partially_paid':
        return AppColors.tertiary;
      default:
        return AppColors.error;
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
