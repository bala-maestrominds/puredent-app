import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/doctor_model.dart';

/// Converted from doctor-detail.html
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  static const _dates = [
    ('Tue', '05'),
    ('Wed', '06'),
    ('Thu', '07'),
    ('Fri', '08'),
    ('Sat', '09'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('Doctor'),
        actions: [IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 140),
        children: [
          // Hero
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                child: Image.network(doctor.imageUrl, width: 96, height: 96, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
                    Text(doctor.specialty, style: AppTextStyles.bodySm.copyWith(color: AppColors.outline)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('${doctor.rating} (${doctor.reviewCount}+ Reviews)', style: AppTextStyles.labelMd),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Stats bento grid
          Row(
            children: [
              _StatCircle(icon: Icons.work_outline, label: '${doctor.yearsExperience} yrs', sublabel: 'Experience'),
              _StatCircle(icon: Icons.star_border, label: '${doctor.rating}', sublabel: 'Rating'),
              _StatCircle(icon: Icons.groups_outlined, label: '${doctor.reviewCount}+', sublabel: 'Patients'),
              _StatCircle(icon: Icons.payments_outlined, label: '\$${doctor.fee.toStringAsFixed(0)}', sublabel: 'Fee'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // About me
          Text('About Me', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Text.rich(
            TextSpan(
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
              children: [
                TextSpan(text: doctor.about),
                const TextSpan(text: '  '),
                TextSpan(
                  text: 'Read More...',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Availability
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Availability', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
              TextButton(onPressed: () {}, child: Text('View Calendar', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, i) {
                final (day, date) = _dates[i];
                final selected = i == 0;
                return Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.toUpperCase(), style: AppTextStyles.labelMd.copyWith(color: selected ? AppColors.onPrimary.withOpacity(0.8) : AppColors.onSurfaceVariant)),
                      Text(date, style: AppTextStyles.headlineSm.copyWith(color: selected ? AppColors.onPrimary : AppColors.onSurface)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Sticky footer action
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.9)),
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: wire up booking flow
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text('Book Appointment'),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
      ),
    );
  }
}

class _StatCircle extends StatelessWidget {
  const _StatCircle({required this.icon, required this.label, required this.sublabel});
  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.05),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          Text(sublabel, style: AppTextStyles.labelMd.copyWith(color: AppColors.outline)),
        ],
      ),
    );
  }
}
