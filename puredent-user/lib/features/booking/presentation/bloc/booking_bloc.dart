import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../domain/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

/// Drives the multi-step booking flow (doctor/service already chosen ->
/// select slot -> patient details -> payment -> confirmation). Kept as a
/// single Bloc so the draft survives back/forward navigation between steps
/// without re-fetching or losing what the user already typed.
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({required BookingRepository repository})
      : _repository = repository,
        super(const BookingState()) {
    on<BookingDoctorAndServiceSelected>((event, emit) => emit(state.copyWith(
          doctorId: event.doctorId,
          doctorName: event.doctorName,
          serviceId: event.serviceId,
          serviceName: event.serviceName,
          // Flat, site-wide consultation fee — ignore any per-doctor value.
          consultationFee: kConsultationFeeAmount,
          servicePrice: event.servicePrice,
        )));
    on<BookingSlotSelected>((event, emit) => emit(state.copyWith(date: event.date, time: event.time)));
    on<BookingPatientDetailsSubmitted>((event, emit) => emit(state.copyWith(
          patientName: event.name,
          patientEmail: event.email,
          patientPhone: event.phone,
          patientAge: event.age,
          patientGender: event.gender,
          notes: event.notes,
        )));
    on<BookingPaymentMethodSelected>((event, emit) => emit(state.copyWith(paymentMethod: event.method)));
    on<BookingPaymentOptionSelected>((event, emit) => emit(state.copyWith(paymentOption: event.option)));
    on<BookingSubmitRequested>(_onSubmitRequested);
    on<BookingReset>((event, emit) => emit(const BookingState()));
  }

  final BookingRepository _repository;

  Future<void> _onSubmitRequested(BookingSubmitRequested event, Emitter<BookingState> emit) async {
    emit(state.copyWith(status: BookingStatus.submitting));

    final result = await _repository.createAppointment(
      doctorId: state.doctorId!,
      serviceId: state.serviceId!,
      date: state.date!,
      time: state.time!,
      patientName: state.patientName!,
      patientEmail: state.patientEmail!,
      patientPhone: state.patientPhone!,
      patientAge: state.patientAge,
      patientGender: state.patientGender,
      notes: state.notes,
      paymentMethod: state.paymentMethod,
      paymentOption: state.paymentOption,
    );

    result.when(
      success: (booking) => emit(state.copyWith(
        status: BookingStatus.success,
        confirmedAppointment: booking.appointment,
        qrCodeDataUrl: booking.qrCodeDataUrl,
      )),
      failure: (f) => emit(state.copyWith(status: BookingStatus.failure, failure: f)),
    );
  }
}
