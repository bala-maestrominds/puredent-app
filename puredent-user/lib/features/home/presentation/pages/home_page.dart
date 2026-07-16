import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';
import '../../../doctors/domain/repositories/doctors_repository.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../services/domain/repositories/services_repository.dart';
import '../../../../core/di/service_locator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<ServiceEntity>> _servicesFuture;
  late final Future<List<DoctorEntity>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = getIt<ServicesRepository>()
        .getServices()
        .then((r) => r.when(success: (s) => s.take(4).toList(), failure: (_) => <ServiceEntity>[]));
    _doctorsFuture = getIt<DoctorsRepository>()
        .getDoctors()
        .then((r) => r.when(success: (d) => d.take(4).toList(), failure: (_) => <DoctorEntity>[]));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name.split(' ').first : 'Guest';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {
            _servicesFuture = getIt<ServicesRepository>()
                .getServices(forceRefresh: true)
                .then((r) => r.when(success: (s) => s.take(4).toList(), failure: (_) => <ServiceEntity>[]));
            _doctorsFuture = getIt<DoctorsRepository>()
                .getDoctors(forceRefresh: true)
                .then((r) => r.when(success: (d) => d.take(4).toList(), failure: (_) => <DoctorEntity>[]));
          }),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, $userName 👋', style: Theme.of(context).textTheme.headlineSmall),
                      Text('How can we help your smile today?', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline_rounded),
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _BookNowBanner(onTap: () => context.push('/services')),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Our Services', onSeeAll: () => context.push('/services')),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 150,
                child: FutureBuilder<List<ServiceEntity>>(
                  future: _servicesFuture,
                  builder: (context, snapshot) {
                    final services = snapshot.data ?? [];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _ServicePreviewCard(
                          service: service,
                          onTap: () => context.push('/services/${service.slug}'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Top Doctors', onSeeAll: () => context.push('/doctors')),
              const SizedBox(height: AppSpacing.sm),
              FutureBuilder<List<DoctorEntity>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  final doctors = snapshot.data ?? [];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Column(
                    children: doctors
                        .map((doctor) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _DoctorPreviewTile(
                                doctor: doctor,
                                onTap: () => context.push('/doctors/${doctor.id}'),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookNowBanner extends StatelessWidget {
  const _BookNowBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book Your Visit', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Find a service and pick a time that works for you.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_circle_right_rounded, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _ServicePreviewCard extends StatelessWidget {
  const _ServicePreviewCard({required this.service, required this.onTap});
  final ServiceEntity service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 80,
                child: AppNetworkImage(
                  imageUrl: service.imageUrl,
                  height: 80,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(service.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorPreviewTile extends StatelessWidget {
  const _DoctorPreviewTile({required this.doctor, required this.onTap});
  final DoctorEntity doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: AppNetworkImage(
          imageUrl: doctor.photoUrl,
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(AppRadius.base),
        ),
        title: Text(doctor.name),
        subtitle: Text(doctor.specialty),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
      ),
    );
  }
}
