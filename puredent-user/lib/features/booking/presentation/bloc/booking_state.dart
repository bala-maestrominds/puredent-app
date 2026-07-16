part of 'booking_bloc.dart';

enum BookingStatus { draft, submitting, success, failure }

const kFullPayment = 'Full Payment';
const kConsultationFeeOnly = 'Consultation Fee Only';

/// The consultation fee is a flat, site-wide amount — the same for every
/// doctor and every service — mirroring `CONSULTATION_FEE` on the backend.
const kConsultationFeeAmount = 100.0;

class BookingState extends Equatable {
  final BookingStatus status;

  // Step 1: doctor + service (chosen before entering the flow)
  final String? doctorId;
  final String? doctorName;
  final String? serviceId;
  final String? serviceName;
  final double consultationFee;
  final double servicePrice;

  // Step 2: slot
  final String? date; // YYYY-MM-DD
  final String? time; // HH:mm

  // Step 3: patient details
  final String? patientName;
  final String? patientEmail;
  final String? patientPhone;
  final int? patientAge;
  final String? patientGender;
  final String? notes;

  // Step 4: payment
  final String? paymentMethod;
  final String paymentOption; // 'Full Payment' | 'Consultation Fee Only'

  // Result
  final AppointmentEntity? confirmedAppointment;
  final String? qrCodeDataUrl;
  final Failure? failure;

  const BookingState({
    this.status = BookingStatus.draft,
    this.doctorId,
    this.doctorName,
    this.serviceId,
    this.serviceName,
    this.consultationFee = 0,
    this.servicePrice = 0,
    this.date,
    this.time,
    this.patientName,
    this.patientEmail,
    this.patientPhone,
    this.patientAge,
    this.patientGender,
    this.notes,
    this.paymentMethod,
    this.paymentOption = kFullPayment,
    this.confirmedAppointment,
    this.qrCodeDataUrl,
    this.failure,
  });

  bool get hasSlot => date != null && time != null;
  bool get hasPatientDetails => patientName != null && patientEmail != null && patientPhone != null;
  bool get isConsultationOnly => paymentOption == kConsultationFeeOnly;

  /// Amount payable now, given the selected payment option.
  double get amountDueNow => isConsultationOnly ? consultationFee.clamp(0, servicePrice) : servicePrice;

  /// Remaining balance to be settled after the treatment.
  double get balanceDue => (servicePrice - amountDueNow).clamp(0, double.infinity);

  BookingState copyWith({
    BookingStatus? status,
    String? doctorId,
    String? doctorName,
    String? serviceId,
    String? serviceName,
    double? consultationFee,
    double? servicePrice,
    String? date,
    String? time,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    int? patientAge,
    String? patientGender,
    String? notes,
    String? paymentMethod,
    String? paymentOption,
    AppointmentEntity? confirmedAppointment,
    String? qrCodeDataUrl,
    Failure? failure,
  }) {
    return BookingState(
      status: status ?? this.status,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      consultationFee: consultationFee ?? this.consultationFee,
      servicePrice: servicePrice ?? this.servicePrice,
      date: date ?? this.date,
      time: time ?? this.time,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      patientPhone: patientPhone ?? this.patientPhone,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentOption: paymentOption ?? this.paymentOption,
      confirmedAppointment: confirmedAppointment ?? this.confirmedAppointment,
      qrCodeDataUrl: qrCodeDataUrl ?? this.qrCodeDataUrl,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctorId,
        serviceId,
        date,
        time,
        patientName,
        patientEmail,
        patientPhone,
        paymentMethod,
        paymentOption,
        confirmedAppointment,
        failure,
      ];
}
