class Appointment {
  final String id;
  final String appointmentCode;
  final String verificationToken;
  final String doctorName;
  final String doctorSpecialty;
  final String serviceName;
  final num servicePrice;
  final String date;
  final String time;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String status;
  final String checkInStatus;
  final String paymentMethod;
  final String paymentStatus; // pending | partially_paid | paid
  final String paymentOption; // 'Full Payment' | 'Consultation Fee Only'
  final num consultationFee;
  final num amount; // full treatment cost
  final num amountPaid; // actually collected so far
  final num balanceDue; // amount - amountPaid, settled later

  const Appointment({
    required this.id,
    required this.appointmentCode,
    required this.verificationToken,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.serviceName,
    required this.servicePrice,
    required this.date,
    required this.time,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.status,
    required this.checkInStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentOption,
    required this.consultationFee,
    required this.amount,
    required this.amountPaid,
    required this.balanceDue,
  });

  bool get isConsultationFeeOnly => paymentOption == 'Consultation Fee Only';

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        appointmentCode: json['appointmentCode'] ?? '',
        verificationToken: json['verificationToken'] ?? '',
        doctorName: json['doctorName'] ?? '',
        doctorSpecialty: json['doctorSpecialty'] ?? '',
        serviceName: json['serviceName'] ?? '',
        servicePrice: (json['servicePrice'] as num?) ?? 0,
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        patientName: json['patientName'] ?? '',
        patientEmail: json['patientEmail'] ?? '',
        patientPhone: json['patientPhone'] ?? '',
        status: json['status'] ?? 'Pending',
        checkInStatus: json['checkInStatus'] ?? 'not_arrived',
        paymentMethod: json['paymentMethod'] ?? 'Pay at Clinic',
        paymentStatus: json['paymentStatus'] ?? 'pending',
        paymentOption: json['paymentOption'] ?? 'Full Payment',
        consultationFee: (json['consultationFee'] as num?) ?? 0,
        amount: (json['amount'] as num?) ?? 0,
        amountPaid: (json['amountPaid'] as num?) ?? 0,
        balanceDue: (json['balanceDue'] as num?) ?? 0,
      );
}
