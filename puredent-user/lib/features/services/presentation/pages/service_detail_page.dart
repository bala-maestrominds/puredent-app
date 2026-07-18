import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../doctors/presentation/widgets/doctor_card.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key, required this.idOrSlug});
  final String idOrSlug;

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late Future<ServiceEntity> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ServiceEntity> _load() async {
    final result = await getIt<ServicesRepository>().getServiceByIdOrSlug(widget.idOrSlug);
    return result.when(success: (s) => s, failure: (f) => throw f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ServiceEntity>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is Failure ? (snapshot.error as Failure).message : 'Failed to load service';
            return Scaffold(appBar: AppBar(), body: Center(child: Text(message)));
          }

          final service = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: AppNetworkImage(imageUrl: service.imageUrl, height: 220),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.payments_outlined,
                            label: service.priceFrom != null ? 'From ₹${service.priceFrom!.toStringAsFixed(0)}' : 'Contact us',
                          ),
                          _InfoChip(icon: Icons.schedule_outlined, label: '${service.durationMinutes} min'),
                          _InfoChip(icon: Icons.category_outlined, label: service.category),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('About this treatment', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        service.description.isNotEmpty ? service.description : service.shortDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (service.keyBenefits.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Key Benefits', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        _KeyBenefitsGrid(benefits: service.keyBenefits),
                      ],
                      if (service.process.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('The Process', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        _ProcessTimeline(steps: service.process),
                      ],
                      if (service.bestSpecialist != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Expert Practitioner', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        DoctorCard(
                          doctor: service.bestSpecialist!,
                          onTap: () => context.push('/doctors/${service.bestSpecialist!.id}'),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppPrimaryButton(
                        label: 'Book This Service',
                        onPressed: () => context.push('/booking/select-doctor', extra: service),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Renders benefits in a 2-column bento-style grid, with the last item
/// spanning both columns when the count is odd — matching the reference UI.
class _KeyBenefitsGrid extends StatelessWidget {
  const _KeyBenefitsGrid({required this.benefits});
  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: List.generate(benefits.length, (index) {
        final isLastOdd = benefits.length.isOdd && index == benefits.length - 1;
        final width = isLastOdd
            ? double.infinity
            : (MediaQuery.of(context).size.width - AppSpacing.marginMobile * 2 - AppSpacing.md) / 2;
        return SizedBox(
          width: width,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    benefits[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Renders numbered steps with a connecting vertical line, matching the
/// reference UI's process timeline.
class _ProcessTimeline extends StatelessWidget {
  const _ProcessTimeline({required this.steps});
  final List<ServiceProcessStep> steps;

  @override
  Widget build(BuildContext context) {
    final sorted = [...steps]..sort((a, b) => a.step.compareTo(b.step));
    return Column(
      children: List.generate(sorted.length, (index) {
        final step = sorted[index];
        final isLast = index == sorted.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      '${step.step}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.outline.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (step.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(step.description, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
