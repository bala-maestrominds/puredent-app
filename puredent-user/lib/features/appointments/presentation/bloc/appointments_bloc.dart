import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc({required AppointmentsRepository repository})
      : _repository = repository,
        super(const AppointmentsState()) {
    on<AppointmentsFetchRequested>(_onFetchRequested);
    on<AppointmentRescheduleRequested>(_onRescheduleRequested);
    on<AppointmentCancelRequested>(_onCancelRequested);
    on<AppointmentPayRequested>(_onPayRequested);
  }

  final AppointmentsRepository _repository;

  Future<void> _onFetchRequested(AppointmentsFetchRequested event, Emitter<AppointmentsState> emit) async {
    emit(state.copyWith(status: AppointmentsStatus.loading));
    final result = await _repository.getMyAppointments();
    result.when(
      success: (appointments) => emit(state.copyWith(status: AppointmentsStatus.success, appointments: appointments)),
      failure: (f) => emit(state.copyWith(status: AppointmentsStatus.failure, failure: f)),
    );
  }

  Future<void> _onRescheduleRequested(
      AppointmentRescheduleRequested event, Emitter<AppointmentsState> emit) async {
    emit(state.copyWith(actionStatus: AppointmentActionStatus.inProgress));
    final result = await _repository.reschedule(event.appointmentId, date: event.date, time: event.time);
    result.when(
      success: (updated) {
        final updatedList = state.appointments.map((a) => a.id == updated.id ? updated : a).toList();
        emit(state.copyWith(
          appointments: updatedList,
          actionStatus: AppointmentActionStatus.success,
          actionMessage: 'Appointment rescheduled to ${updated.date} at ${updated.time}.',
        ));
      },
      failure: (f) => emit(state.copyWith(actionStatus: AppointmentActionStatus.failure, actionFailure: f)),
    );
  }

  Future<void> _onCancelRequested(AppointmentCancelRequested event, Emitter<AppointmentsState> emit) async {
    emit(state.copyWith(actionStatus: AppointmentActionStatus.inProgress));
    final result = await _repository.cancel(event.appointmentId, reason: event.reason);
    result.when(
      success: (updated) {
        final updatedList = state.appointments.map((a) => a.id == updated.id ? updated : a).toList();
        emit(state.copyWith(
          appointments: updatedList,
          actionStatus: AppointmentActionStatus.success,
          actionMessage: 'Appointment cancelled.',
        ));
      },
      failure: (f) => emit(state.copyWith(actionStatus: AppointmentActionStatus.failure, actionFailure: f)),
    );
  }

  Future<void> _onPayRequested(AppointmentPayRequested event, Emitter<AppointmentsState> emit) async {
    emit(state.copyWith(actionStatus: AppointmentActionStatus.inProgress));
    final result = await _repository.payBalance(event.appointmentId, paymentMethod: event.paymentMethod);
    result.when(
      success: (updated) {
        final updatedList = state.appointments.map((a) => a.id == updated.id ? updated : a).toList();
        emit(state.copyWith(
          appointments: updatedList,
          actionStatus: AppointmentActionStatus.success,
          actionMessage: 'Payment successful. Thank you!',
        ));
      },
      failure: (f) => emit(state.copyWith(actionStatus: AppointmentActionStatus.failure, actionFailure: f)),
    );
  }
}
