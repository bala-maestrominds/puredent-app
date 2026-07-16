part of 'appointments_bloc.dart';

enum AppointmentsStatus { initial, loading, success, failure }
enum AppointmentActionStatus { idle, inProgress, success, failure }

class AppointmentsState extends Equatable {
  final AppointmentsStatus status;
  final List<AppointmentEntity> appointments;
  final Failure? failure;

  // Tracks the outcome of a reschedule/cancel action so the UI can show a
  // one-off snackbar/toast without re-triggering the whole list load.
  final AppointmentActionStatus actionStatus;
  final Failure? actionFailure;
  final String? actionMessage;

  const AppointmentsState({
    this.status = AppointmentsStatus.initial,
    this.appointments = const [],
    this.failure,
    this.actionStatus = AppointmentActionStatus.idle,
    this.actionFailure,
    this.actionMessage,
  });

  AppointmentsState copyWith({
    AppointmentsStatus? status,
    List<AppointmentEntity>? appointments,
    Failure? failure,
    AppointmentActionStatus? actionStatus,
    Failure? actionFailure,
    String? actionMessage,
  }) {
    return AppointmentsState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      failure: failure,
      actionStatus: actionStatus ?? this.actionStatus,
      actionFailure: actionFailure,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, appointments, failure, actionStatus, actionFailure, actionMessage];
}
