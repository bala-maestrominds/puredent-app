import 'package:flutter/material.dart';
import '../../core/models/appointment.dart';
import '../../core/services/api_client.dart';
import '../../core/services/appointments_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static const _statusColors = {
    'Confirmed': AppColors.secondaryContainer,
    'In-Progress': AppColors.tertiaryFixed,
    'Pending': AppColors.surfaceContainerHigh,
    'Completed': AppColors.primaryFixed,
    'Cancelled': AppColors.errorContainer,
  };

  final _statusFilters = const ['All', 'Confirmed', 'Pending', 'In-Progress', 'Completed', 'Cancelled'];

  String _search = '';
  String _statusFilter = 'All';
  late Future<List<Appointment>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppointmentsService.instance.list();
  }

  Future<void> _refresh() async {
    final future = AppointmentsService.instance.list(
      status: _statusFilter == 'All' ? null : _statusFilter,
      search: _search.isEmpty ? null : _search,
    );
    setState(() => _future = future);
    await future;
  }

  Future<void> _updateStatus(Appointment a, String status) async {
    try {
      await AppointmentsService.instance.updateStatus(a.id, status);
      if (!mounted) return;
      Navigator.pop(context);
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Appointments',
      subtitle: 'Bookings made through the website & app',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by patient, doctor, or code...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                _search = value;
                _refresh();
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final s = _statusFilters[index];
                final selected = _statusFilter == s;
                return GestureDetector(
                  onTap: () {
                    setState(() => _statusFilter = s);
                    _refresh();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: selected ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(message: '${snapshot.error}', onRetry: _refresh);
                }
                final appointments = snapshot.data ?? const [];
                if (appointments.isEmpty) {
                  return Center(
                    child: Text('No appointments match your filters.', style: Theme.of(context).textTheme.bodyMedium),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: appointments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final a = appointments[index];
                      return StaggeredFadeIn(
                        index: index,
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(a.patientName, style: Theme.of(context).textTheme.titleMedium),
                                        Text('#${a.appointmentCode}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  _StatusChip(
                                    status: a.status,
                                    color: _statusColors[a.status] ?? AppColors.surfaceContainerHigh,
                                    onTap: () => _showStatusPicker(a),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, color: AppColors.outlineVariant),
                              _infoRow(Icons.medical_services_outlined, a.serviceName),
                              const SizedBox(height: 6),
                              _infoRow(Icons.person_outline_rounded, a.doctorName),
                              const SizedBox(height: 6),
                              _infoRow(Icons.schedule_rounded, '${a.date} · ${a.time}'),
                              if (a.checkInStatus == 'checked_in') ...[
                                const SizedBox(height: 6),
                                _infoRow(Icons.check_circle_outline_rounded, 'Checked in'),
                              ],
                              const SizedBox(height: 6),
                              _paymentRow(a),
                            ],
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant))),
      ],
    );
  }

  Widget _paymentRow(Appointment a) {
    late final Color color;
    late final IconData icon;
    late final String label;

    switch (a.paymentStatus) {
      case 'paid':
        color = AppColors.primary;
        icon = Icons.check_circle_rounded;
        label = 'Paid in full · \$${a.amountPaid.toStringAsFixed(2)}';
        break;
      case 'partially_paid':
        color = AppColors.tertiary;
        icon = Icons.hourglass_bottom_rounded;
        label = a.isConsultationFeeOnly
            ? 'Consultation fee paid · \$${a.balanceDue.toStringAsFixed(2)} due after check-in'
            : 'Partially paid · \$${a.balanceDue.toStringAsFixed(2)} balance due';
        break;
      default:
        color = AppColors.outline;
        icon = Icons.payments_outlined;
        label = 'Payment pending · \$${a.amount.toStringAsFixed(2)} due';
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _showStatusPicker(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._statusColors.keys.map(
              (s) => ListTile(
                title: Text(s),
                trailing: appointment.status == s ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                onTap: () => _updateStatus(appointment, s),
              ),
            ),
          ],
        ),
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
            Text('Could not load appointments', style: Theme.of(context).textTheme.titleMedium),
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

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({required this.status, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(999)),
        child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
