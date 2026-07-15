import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onViewProfile});

  final DoctorModel doctor;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: AppColors.primaryContainer.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(doctor.name, style: AppTextStyles.headlineSm, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 2),
                          Text('${doctor.rating}', style: AppTextStyles.labelMd.copyWith(color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  '${doctor.specialty} • ${doctor.yearsExperience} yrs exp.',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.outline, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FEE', style: AppTextStyles.labelMd.copyWith(color: AppColors.outlineVariant)),
                        Text('\$${doctor.fee.toStringAsFixed(2)}', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onViewProfile,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 16)),
                      child: const Text('View Profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
