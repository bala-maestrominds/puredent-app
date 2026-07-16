import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../doctors/presentation/bloc/doctors_bloc.dart';
import '../../../doctors/presentation/widgets/doctor_card.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../bloc/booking_bloc.dart';

/// Step in the booking flow where a service is already chosen and the
/// patient now picks which doctor to see for it.
class SelectDoctorPage extends StatelessWidget {
  const SelectDoctorPage({super.key, required this.service});
  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DoctorsBloc>()..add(const DoctorsFetchRequested()),
      child: Scaffold(
        appBar: AppBar(title: Text('Choose a doctor for ${service.name}')),
        body: BlocBuilder<DoctorsBloc, DoctorsState>(
          builder: (context, state) {
            if (state.status == DoctorsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: state.visibleDoctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final doctor = state.visibleDoctors[index];
                return DoctorCard(
                  doctor: doctor,
                  onTap: () {
                    context.read<BookingBloc>().add(BookingDoctorAndServiceSelected(
                          doctorId: doctor.id,
                          doctorName: doctor.name,
                          serviceId: service.id,
                          serviceName: service.name,
                          consultationFee: doctor.consultationFee,
                          servicePrice: service.priceFrom ?? 0,
                        ));
                    context.push('/booking/select-slot');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
