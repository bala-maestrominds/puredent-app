import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class _Patient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String lastVisit;
  final String nextVisit;
  final int totalVisits;

  const _Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.lastVisit,
    required this.nextVisit,
    required this.totalVisits,
  });
}

const _patients = [
  _Patient(id: 'PD-8821', name: 'Jonathan Smith', email: 'jonathan.smith@email.com', phone: '+1 (555) 201-3344', lastVisit: '2024-07-10', nextVisit: '2024-08-14', totalVisits: 12),
  _Patient(id: 'PD-7729', name: 'Alice Wonderland', email: 'alice.w@email.com', phone: '+1 (555) 402-9981', lastVisit: '2024-07-10', nextVisit: '—', totalVisits: 4),
  _Patient(id: 'PD-9122', name: 'Robert Lewandowski', email: 'robert.l@email.com', phone: '+1 (555) 778-2210', lastVisit: '2024-07-10', nextVisit: '2024-07-24', totalVisits: 8),
  _Patient(id: 'PD-6650', name: 'Maria Gonzalez', email: 'maria.g@email.com', phone: '+1 (555) 331-0092', lastVisit: '2024-07-01', nextVisit: '2024-07-11', totalVisits: 21),
  _Patient(id: 'PD-5518', name: 'David Okafor', email: 'david.okafor@email.com', phone: '+1 (555) 664-7723', lastVisit: '2024-06-28', nextVisit: '—', totalVisits: 3),
];

String _initials(String name) =>
    name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _search = '';

  List<_Patient> get _filtered {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _patients;
    return _patients
        .where((p) => p.name.toLowerCase().contains(q) || p.email.toLowerCase().contains(q) || p.id.toLowerCase().contains(q))
        .toList();
  }

  void _openDetail(_Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PatientDetailSheet(patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return AdminPageScaffold(
      title: 'Patients',
      subtitle: '${_patients.length} records',
      action: IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hook this up to open an "Add Patient" form.')),
          );
        },
        icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, email, or ID...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('No patients match your search.', style: Theme.of(context).textTheme.bodyMedium))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
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
                                    Text('${p.totalVisits}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
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
          ),
        ],
      ),
    );
  }
}

class _PatientDetailSheet extends StatelessWidget {
  final _Patient patient;
  const _PatientDetailSheet({required this.patient});

  @override
  Widget build(BuildContext context) {
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
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(_initials(patient.name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text('ID: #${patient.id}', style: Theme.of(context).textTheme.bodyMedium),
                ],
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
              Expanded(child: _statBox(context, 'Last Visit', patient.lastVisit)),
              const SizedBox(width: 12),
              Expanded(child: _statBox(context, 'Next Visit', patient.nextVisit)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Edit Record'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ],
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
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _statBox(BuildContext context, String label, String value) {
    return Container(
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