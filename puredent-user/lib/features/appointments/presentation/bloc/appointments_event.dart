part of 'appointments_bloc.dart';

sealed class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();
  @override
  List<Object?> get props => [];
}

class AppointmentsFetchRequested extends AppointmentsEvent {
  const AppointmentsFetchRequested();
}

class AppointmentRescheduleRequested extends AppointmentsEvent {
  final String appointmentId;
  final String date;
  final String time;
  const AppointmentRescheduleRequested({required this.appointmentId, required this.date, required this.time});
  @override
  List<Object?> get props => [appointmentId, date, time];
}

class AppointmentCancelRequested extends AppointmentsEvent {
  final String appointmentId;
  final String? reason;
  const AppointmentCancelRequested({required this.appointmentId, this.reason});
  @override
  List<Object?> get props => [appointmentId, reason];
}

class AppointmentPayRequested extends AppointmentsEvent {
  final String appointmentId;
  final String paymentMethod;
  const AppointmentPayRequested({required this.appointmentId, this.paymentMethod = 'Card'});
  @override
  List<Object?> get props => [appointmentId, paymentMethod];
}
