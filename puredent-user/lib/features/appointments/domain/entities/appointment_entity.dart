import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String appointmentCode;
  final String doctorId;
  final String serviceId;
  final String date;
  final String time;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String status;
  final String checkInStatus; // 'not_arrived' | 'checked_in'
  final String? doctorName;
  final String? serviceName;

  // Payment tracking
  final String paymentMethod;
  final String paymentOption; // 'Full Payment' | 'Consultation Fee Only'
  final double consultationFee;
  final double amount; // total treatment cost
  final double amountPaid;
  final double balanceDue;
  final String paymentStatus; // 'pending' | 'partially_paid' | 'paid'

  // Reschedule tracking
  final int rescheduleCount;
  final String? originalDate;
  final String? originalTime;

  // Cancellation
  final String? cancellationReason;

  const AppointmentEntity({
    required this.id,
    required this.appointmentCode,
    required this.doctorId,
    required this.serviceId,
    required this.date,
    required this.time,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.status,
    this.checkInStatus = 'not_arrived',
    this.doctorName,
    this.serviceName,
    this.paymentMethod = 'Pay at Clinic',
    this.paymentOption = 'Full Payment',
    this.consultationFee = 0,
    this.amount = 0,
    this.amountPaid = 0,
    this.balanceDue = 0,
    this.paymentStatus = 'pending',
    this.rescheduleCount = 0,
    this.originalDate,
    this.originalTime,
    this.cancellationReason,
  });

  bool get isConsultationOnly => paymentOption == 'Consultation Fee Only';
  bool get hasBalanceDue => balanceDue > 0;
  bool get isCheckedIn => checkInStatus == 'checked_in';
  bool get canReschedule => status != 'Cancelled' && status != 'Completed';
  bool get canCancel => status != 'Cancelled' && status != 'Completed';

  // The patient can pay any outstanding balance up front, but once they've
  // opted for "Consultation Fee Only" the remaining treatment cost is only
  // payable once the clinic has checked them in for the visit.
  bool get canPayOnline {
    if (!hasBalanceDue) return false;
    if (status == 'Cancelled') return false;
    if (isConsultationOnly) return isCheckedIn;
    return true;
  }

  @override
  List<Object?> get props => [id, appointmentCode, date, time, status, paymentStatus, balanceDue];
}
