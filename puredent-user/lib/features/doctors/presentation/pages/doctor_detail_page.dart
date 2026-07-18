import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctors_repository.dart';

class DoctorDetailPage extends StatefulWidget {
  const DoctorDetailPage({super.key, required this.doctorId});
  final String doctorId;

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late Future<DoctorEntity> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DoctorEntity> _load() async {
    final result =
        await getIt<DoctorsRepository>().getDoctorById(widget.doctorId);
    return result.when(success: (d) => d, failure: (f) => throw f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DoctorEntity>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            final message = snapshot.error is Failure
                ? (snapshot.error as Failure).message
                : 'Failed to load doctor';
            return Scaffold(
                appBar: AppBar(), body: Center(child: Text(message)));
          }

          final doctor = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background:
                      AppNetworkImage(imageUrl: doctor.photoUrl, height: 220),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(doctor.specialty,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Stat(
                              label: 'Rating',
                              value: '${doctor.rating.toStringAsFixed(1)} ★'),
                          _Stat(label: 'Reviews', value: '${doctor.reviews}'),
                          _Stat(
                              label: 'Experience',
                              value: '${doctor.experienceYears} yrs'),
                          _Stat(
                              label: 'Consult Fee',
                              value:
                                  '₹${kConsultationFeeAmount.toStringAsFixed(0)}'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (doctor.bio.isNotEmpty) ...[
                        Text('About',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(doctor.bio,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (doctor.education.isNotEmpty) ...[
                        Text('Education',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(doctor.education,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (doctor.languages.isNotEmpty) ...[
                        Text('Languages',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: doctor.languages
                              .map((l) => Chip(label: Text(l)))
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (doctor.workingHours.isNotEmpty) ...[
                        Text('Working Hours',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ...doctor.workingHours.map(
                          (wh) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_capitalize(wh.day),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                Text('${wh.startTime} – ${wh.endTime}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      AppPrimaryButton(
                        label: 'Book Appointment',
                        onPressed: () => context.push('/booking/select-service',
                            extra: doctor),
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

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.outline)),
      ],
    );
  }
}
