part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class BookingDoctorAndServiceSelected extends BookingEvent {
  final String doctorId;
  final String doctorName;
  final String serviceId;
  final String serviceName;
  final double consultationFee;
  final double servicePrice;
  const BookingDoctorAndServiceSelected({
    required this.doctorId,
    required this.doctorName,
    required this.serviceId,
    required this.serviceName,
    this.consultationFee = 0,
    this.servicePrice = 0,
  });
  @override
  List<Object?> get props => [doctorId, doctorName, serviceId, serviceName, consultationFee, servicePrice];
}

class BookingSlotSelected extends BookingEvent {
  final String date;
  final String time;
  const BookingSlotSelected({required this.date, required this.time});
  @override
  List<Object?> get props => [date, time];
}

class BookingPatientDetailsSubmitted extends BookingEvent {
  final String name;
  final String email;
  final String phone;
  final int? age;
  final String? gender;
  final String? notes;
  const BookingPatientDetailsSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    this.age,
    this.gender,
    this.notes,
  });
  @override
  List<Object?> get props => [name, email, phone, age, gender, notes];
}

class BookingPaymentMethodSelected extends BookingEvent {
  final String method;
  const BookingPaymentMethodSelected(this.method);
  @override
  List<Object?> get props => [method];
}

/// Full treatment cost now, vs just the doctor's consultation fee (with the
/// remainder settled after treatment).
class BookingPaymentOptionSelected extends BookingEvent {
  final String option; // 'Full Payment' | 'Consultation Fee Only'
  const BookingPaymentOptionSelected(this.option);
  @override
  List<Object?> get props => [option];
}

class BookingSubmitRequested extends BookingEvent {
  const BookingSubmitRequested();
}

class BookingReset extends BookingEvent {
  const BookingReset();
}
