import 'package:flutter/material.dart';
import '../../core/models/doctor.dart';
import '../../core/services/doctors_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class DentistsScreen extends StatefulWidget {
  const DentistsScreen({super.key});

  @override
  State<DentistsScreen> createState() => _DentistsScreenState();
}

class _DentistsScreenState extends State<DentistsScreen> {
  late Future<List<Doctor>> _future;

  @override
  void initState() {
    super.initState();
    _future = DoctorsService.instance.list();
  }

  Future<void> _refresh() async {
    final future = DoctorsService.instance.list();
    setState(() => _future = future);
    await future;
  }

  Future<void> _confirmDeactivate(Doctor d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deactivate dentist?'),
        content: Text('${d.name} will no longer appear as bookable on the website.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DoctorsService.instance.deactivate(d.id);
        if (!mounted) return;
        Navigator.pop(context); // close detail sheet
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Dentists',
      subtitle: 'Specialists at PureDent',
      child: FutureBuilder<List<Doctor>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(message: '${snapshot.error}', onRetry: _refresh);
          }
          final dentists = snapshot.data ?? const [];
          if (dentists.isEmpty) {
            return Center(child: Text('No dentists yet.', style: Theme.of(context).textTheme.bodyMedium));
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: dentists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final d = dentists[index];
                return StaggeredFadeIn(
                  index: index,
                  child: GestureDetector(
                    onTap: () => _openDetail(context, d),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Avatar(url: d.resolvedPhotoUrl),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.name, style: Theme.of(context).textTheme.titleMedium),
                                Text(
                                  d.specialty,
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12.5),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  d.education.isNotEmpty ? d.education : '${d.experienceYears} yrs experience',
                                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.5),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFFFB700), size: 16),
                                    const SizedBox(width: 2),
                                    Text('${d.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                    const SizedBox(width: 10),
                                    if (!d.isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorContainer.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text('Inactive', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
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
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Doctor d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DentistDetailSheet(dentist: d, onDeactivate: () => _confirmDeactivate(d)),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: url.isEmpty
          ? Container(
              width: 76,
              height: 76,
              color: AppColors.surfaceContainerLow,
              child: const Icon(Icons.person_rounded, color: AppColors.outline),
            )
          : Image.network(
              url,
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
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
            Text('Could not load dentists', style: Theme.of(context).textTheme.titleMedium),
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

class _DentistDetailSheet extends StatelessWidget {
  final Doctor dentist;
  final VoidCallback onDeactivate;
  const _DentistDetailSheet({required this.dentist, required this.onDeactivate});

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
                child: dentist.resolvedPhotoUrl.isEmpty
                    ? Container(
                        width: 110,
                        height: 110,
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(Icons.person_rounded, size: 40, color: AppColors.outline),
                      )
                    : Image.network(
                        dentist.resolvedPhotoUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 110,
                          height: 110,
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(Icons.person_rounded, size: 40, color: AppColors.outline),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: Text(dentist.name, style: Theme.of(context).textTheme.headlineSmall)),
            Center(
              child: Text(
                dentist.specialty,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            if (dentist.education.isNotEmpty) ...[
              const SizedBox(height: 6),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.secondaryContainer.withOpacity(0.4), borderRadius: BorderRadius.circular(999)),
                  child: Text(dentist.education, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _statBox('Experience', '${dentist.experienceYears} yrs')),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Rating', '⭐ ${dentist.rating}')),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Fee', '₹${dentist.consultationFee}')),
              ],
            ),
            const SizedBox(height: 20),
            if (dentist.bio.isNotEmpty) ...[
              Text('About', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(dentist.bio, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 20),
            ],
            Text('Working Hours', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            dentist.workingHours.isEmpty
                ? const Text('Not set', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dentist.workingHours
                        .map((w) => Chip(
                              label: Text(
                                '${w.day.substring(0, 3)} ${w.startTime}-${w.endTime}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: AppColors.secondaryContainer.withOpacity(0.35),
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
            const SizedBox(height: 20),
            if (dentist.email.isNotEmpty) ...[
              _contactRow(Icons.mail_outline_rounded, dentist.email),
              const SizedBox(height: 10),
            ],
            if (dentist.phone.isNotEmpty) _contactRow(Icons.call_outlined, dentist.phone),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDeactivate,
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                icon: const Icon(Icons.person_off_rounded, size: 18),
                label: Text(dentist.isActive ? 'Deactivate' : 'Already inactive'),
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
