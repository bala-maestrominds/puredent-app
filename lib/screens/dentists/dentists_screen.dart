import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class _Dentist {
  final String name;
  final String specialization;
  final String qualification;
  final int experienceYears;
  final double rating;
  final int appointmentsThisMonth;
  final String photoUrl;
  final String bio;
  final List<String> workingDays;
  final String email;
  final String phone;
  final int consultationFee;

  const _Dentist({
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.experienceYears,
    required this.rating,
    required this.appointmentsThisMonth,
    required this.photoUrl,
    required this.bio,
    required this.workingDays,
    required this.email,
    required this.phone,
    required this.consultationFee,
  });
}

const _dentists = [
  _Dentist(
    name: 'Dr. Michael Chen',
    specialization: 'Orthodontics',
    qualification: 'BDS, MDS — Orthodontics',
    experienceYears: 12,
    rating: 4.9,
    appointmentsThisMonth: 42,
    photoUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBjxmggMOrmqO_ghBNdAtl8QOQgsm6di-DFw8rQqmiAoDG30wlijKcJLn6FWQZ3kZDOKRvx2_Z7Wde2BOGRhIrzA4inCE8iUOw7A4VwXTnxq2tRBlujrHtCmdSIjs39H3-dwCI8N5UQHQG-BKXLUZUA8U9-eDHLSYniUrvDE6Opyq1zVEjI5Qkvsgxn15j3CavSI16aItEDvlULSftquAIlYGC9yAHj1a57NM919HpgKwFJ7FFZvtuK',
    bio:
        'Dr. Chen specializes in modern orthodontic care, including clear aligners and traditional braces, with a focus on making treatment comfortable for patients of all ages.',
    workingDays: ['Mon', 'Tue', 'Wed', 'Fri'],
    email: 'michael.chen@puredent.com',
    phone: '+1 (555) 201-4410',
    consultationFee: 120,
  ),
  _Dentist(
    name: 'Dr. Aisha Varma',
    specialization: 'Periodontics',
    qualification: 'BDS, MDS — Periodontology',
    experienceYears: 9,
    rating: 4.8,
    appointmentsThisMonth: 38,
    photoUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCzJCEwTCgpx_B_X-kQbaY8XL61lS6-xnUYtpm0HP-WD7Lk7YZaZrQvTnvtCVHUgpg9QMu3JvG1a0xViOeHBtFwUpY_1q5a0-khaa0GwTjUeB6OT91SuHzvnIejp11YwXKyB7n5o77jKM1YnvR1CBtlZlawwJH88QwGAR3F_om8fSOTHCHMkiQ5qaql0UyNwnxM9m0at1bbo4GoTt7tdSfoIhdFXArhExkU4wCCDBE6HVz4H0ISuTdy',
    bio:
        'Dr. Varma focuses on gum health and periodontal treatment, helping patients recover from gum disease and maintain long-term oral health with a gentle, thorough approach.',
    workingDays: ['Mon', 'Wed', 'Thu', 'Sat'],
    email: 'aisha.varma@puredent.com',
    phone: '+1 (555) 201-7723',
    consultationFee: 110,
  ),
  _Dentist(
    name: 'Dr. James Wilson',
    specialization: 'General Dentistry',
    qualification: 'BDS — General & Family Dentistry',
    experienceYears: 15,
    rating: 4.9,
    appointmentsThisMonth: 35,
    photoUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB9YRF45_XVEmjL6LFK-XcdmQB3Tec2d1-hdXQXEYS9PMpJdGcMKD8vjff6DFZ6oLM9tcVSXYKHkpUawC7ow1POOpahIlgv-u-BTAJGrQ4sDB2wJetLMuGTKJenrIxJaD3B8CdzD6uvwUP_kKqGd_bfu8xERfKMNYM4oqIn67PA1JQJZwt26qNfzEaF-p67Xvgfd0AXCggUqC_fBvd7YVVfwMdO9XZbFdll6Ph1nf2fOlM2pyAii4tp',
    bio:
        'Dr. Wilson has spent over a decade providing routine and family dental care, and is known by patients for his calm, reassuring chairside manner.',
    workingDays: ['Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    email: 'james.wilson@puredent.com',
    phone: '+1 (555) 201-9981',
    consultationFee: 90,
  ),
];

class DentistsScreen extends StatelessWidget {
  const DentistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Dentists',
      subtitle: '${_dentists.length} specialists at PureDent',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _dentists.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final d = _dentists[index];
          return StaggeredFadeIn(
            index: index,
            child: GestureDetector(
              onTap: () => _openDetail(context, d),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        d.photoUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: 76,
                            height: 76,
                            color: AppColors.surfaceContainerLow,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 76,
                          height: 76,
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(Icons.person_rounded, color: AppColors.outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            d.specialization,
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            d.qualification,
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFB700), size: 16),
                              const SizedBox(width: 2),
                              Text('${d.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              const SizedBox(width: 10),
                              const Icon(Icons.event_available_rounded, size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 3),
                              Text(
                                '${d.appointmentsThisMonth} this month',
                                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, _Dentist d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DentistDetailSheet(dentist: d),
    );
  }
}

class _DentistDetailSheet extends StatelessWidget {
  final _Dentist dentist;
  const _DentistDetailSheet({required this.dentist});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(dentist.photoUrl, width: 110, height: 110, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: Text(dentist.name, style: Theme.of(context).textTheme.headlineSmall)),
            Center(
              child: Text(
                dentist.specialization,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.secondaryContainer.withOpacity(0.4), borderRadius: BorderRadius.circular(999)),
                child: Text(dentist.qualification, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _statBox('Experience', '${dentist.experienceYears} yrs')),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Rating', '⭐ ${dentist.rating}')),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Fee', '\$${dentist.consultationFee}')),
              ],
            ),
            const SizedBox(height: 20),
            Text('About', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(dentist.bio, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 20),
            Text('Working Days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: dentist.workingDays
                  .map((d) => Chip(
                        label: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        backgroundColor: AppColors.secondaryContainer.withOpacity(0.35),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _contactRow(Icons.mail_outline_rounded, dentist.email),
            const SizedBox(height: 10),
            _contactRow(Icons.call_outlined, dentist.phone),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('View Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
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
}