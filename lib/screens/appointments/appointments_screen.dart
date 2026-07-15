import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class _Appointment {
  final String id;
  final String patient;
  final String doctor;
  final String treatment;
  final String time;
  String status;

  _Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.treatment,
    required this.time,
    required this.status,
  });
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _appointments = [
    _Appointment(id: 'PD-8821', patient: 'Jonathan Smith', doctor: 'Dr. Michael Chen', treatment: 'Root Canal Therapy', time: '09:30 AM', status: 'Confirmed'),
    _Appointment(id: 'PD-7729', patient: 'Alice Wonderland', doctor: 'Dr. Aisha Varma', treatment: 'Teeth Whitening', time: '11:00 AM', status: 'In-Progress'),
    _Appointment(id: 'PD-9122', patient: 'Robert Lewandowski', doctor: 'Dr. James Wilson', treatment: 'Routine Checkup', time: '02:15 PM', status: 'Pending'),
    _Appointment(id: 'PD-6650', patient: 'Maria Gonzalez', doctor: 'Dr. Michael Chen', treatment: 'Dental Implants', time: '10:00 AM', status: 'Confirmed'),
    _Appointment(id: 'PD-5518', patient: 'David Okafor', doctor: 'Dr. Aisha Varma', treatment: 'Gum Treatment', time: '03:45 PM', status: 'Completed'),
  ];

  static const _statusColors = {
    'Confirmed': AppColors.secondaryContainer,
    'In-Progress': AppColors.tertiaryFixed,
    'Pending': AppColors.surfaceContainerHigh,
    'Completed': AppColors.primaryFixed,
    'Cancelled': AppColors.errorContainer,
  };

  String _search = '';
  String _statusFilter = 'All';
  final _statusFilters = const ['All', 'Confirmed', 'Pending', 'In-Progress', 'Completed', 'Cancelled'];

  List<_Appointment> get _filtered {
    return _appointments.where((a) {
      final matchesStatus = _statusFilter == 'All' || a.status == _statusFilter;
      final q = _search.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          a.patient.toLowerCase().contains(q) ||
          a.doctor.toLowerCase().contains(q) ||
          a.id.toLowerCase().contains(q);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return AdminPageScaffold(
      title: 'Appointments',
      subtitle: '${_appointments.length} total bookings',
      action: IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hook this up to open a "New Appointment" form.')),
          );
        },
        icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by patient, doctor, or ID...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) => setState(() => _search = value),
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
                  onTap: () => setState(() => _statusFilter = s),
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
            child: filtered.isEmpty
                ? Center(
                    child: Text('No appointments match your filters.', style: Theme.of(context).textTheme.bodyMedium),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final a = filtered[index];
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
                                        Text(a.patient, style: Theme.of(context).textTheme.titleMedium),
                                        Text('ID: #${a.id}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
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
                              _infoRow(Icons.medical_services_outlined, a.treatment),
                              const SizedBox(height: 6),
                              _infoRow(Icons.person_outline_rounded, a.doctor),
                              const SizedBox(height: 6),
                              _infoRow(Icons.schedule_rounded, a.time),
                            ],
                          ),
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
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  void _showStatusPicker(_Appointment appointment) {
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
                onTap: () {
                  setState(() => appointment.status = s);
                  Navigator.pop(context);
                },
              ),
            ),
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