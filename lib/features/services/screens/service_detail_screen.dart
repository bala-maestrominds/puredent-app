import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../doctors/models/doctor_model.dart';
import '../models/service_model.dart';

/// Converted from service-detail.html
class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service, this.practitioner});

  final ServiceModel service;
  final DoctorModel? practitioner;

  @override
  Widget build(BuildContext context) {
    final doctor = practitioner ?? demoDoctors.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface.withOpacity(0.8),
                expandedHeight: 320,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(service.imageUrl, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, 0, AppSpacing.marginMobile, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      // Header card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(color: AppColors.primaryContainer.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                    ),
                                    child: Text(service.category, style: AppTextStyles.labelMd.copyWith(color: AppColors.onSecondaryContainer)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(service.name, style: AppTextStyles.headlineLgMobile.copyWith(color: AppColors.primary)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${service.price.toStringAsFixed(2)}', style: AppTextStyles.headlineMd.copyWith(color: AppColors.secondary)),
                                Text('Starting price', style: AppTextStyles.labelMd.copyWith(color: AppColors.outline)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Overview
                      Text('Overview', style: AppTextStyles.headlineSm),
                      const SizedBox(height: AppSpacing.md),
                      Text(service.overview, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.6)),
                      const SizedBox(height: AppSpacing.lg),
                      // Key benefits
                      Text('Key Benefits', style: AppTextStyles.headlineSm),
                      const SizedBox(height: AppSpacing.md),
                      _KeyBenefitsGrid(highlights: service.highlights),
                      const SizedBox(height: AppSpacing.lg),
                      // Process timeline
                      Text('The Process', style: AppTextStyles.headlineSm),
                      const SizedBox(height: AppSpacing.md),
                      _ProcessTimeline(steps: service.processSteps),
                      const SizedBox(height: AppSpacing.lg),
                      // Practitioner
                      Text('Expert Practitioner', style: AppTextStyles.headlineSm),
                      const SizedBox(height: AppSpacing.md),
                      _PractitionerCard(doctor: doctor),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Fixed booking button
          Positioned(
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            bottom: AppSpacing.lg,
            child: ElevatedButton(
              onPressed: () {
                // TODO: wire up booking flow
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Book Appointment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyBenefitsGrid extends StatelessWidget {
  const _KeyBenefitsGrid({required this.highlights});
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: highlights
          .map(
            (h) => Container(
              width: (MediaQuery.of(context).size.width - AppSpacing.marginMobile * 2 - AppSpacing.md) / 2,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    child: const Icon(Icons.check_circle, color: AppColors.secondary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(child: Text(h, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProcessTimeline extends StatelessWidget {
  const _ProcessTimeline({required this.steps});
  final List<ProcessStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text('${i + 1}', style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    if (i != steps.length - 1)
                      Expanded(child: Container(width: 2, color: AppColors.outlineVariant.withOpacity(0.3), margin: const EdgeInsets.symmetric(vertical: 4))),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].title, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                        Text(steps[i].description, style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PractitionerCard extends StatelessWidget {
  const _PractitionerCard({required this.doctor});
  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.network(doctor.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                Text(doctor.specialty, style: AppTextStyles.bodySm.copyWith(color: AppColors.outline)),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${doctor.rating} (${doctor.reviewCount}+ Reviews)', style: AppTextStyles.labelMd),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    );
  }
}
