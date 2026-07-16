import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';
import '../../../services/presentation/bloc/services_bloc.dart';
import '../../../services/presentation/widgets/service_card.dart';
import '../bloc/booking_bloc.dart';

/// Step in the booking flow where a doctor is already chosen and the patient
/// now picks which service to book with them.
class SelectServicePage extends StatelessWidget {
  const SelectServicePage({super.key, required this.doctor});
  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ServicesBloc>()..add(const ServicesFetchRequested()),
      child: Scaffold(
        appBar: AppBar(title: Text('Book with Dr. ${doctor.name}')),
        body: BlocBuilder<ServicesBloc, ServicesState>(
          builder: (context, state) {
            if (state.status == ServicesStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.65,
              ),
              itemCount: state.visibleServices.length,
              itemBuilder: (context, index) {
                final service = state.visibleServices[index];
                return ServiceCard(
                  service: service,
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
