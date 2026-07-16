/// A "payment" is just an appointment viewed through its billing fields —
/// there's no separate Payment/invoice collection in the backend.
class Payment {
  final String id;
  final String appointmentCode;
  final String patientName;
  final String serviceName;
  final String date;
  final num amount; // full treatment cost
  final num amountPaid; // collected so far
  final num balanceDue;
  final String method; // paymentMethod: Card | PayPal | Razorpay | Pay at Clinic
  final String paymentOption; // 'Full Payment' | 'Consultation Fee Only'
  final String status; // derived: Paid | Partially Paid | Pending | Overdue

  const Payment({
    required this.id,
    required this.appointmentCode,
    required this.patientName,
    required this.serviceName,
    required this.date,
    required this.amount,
    required this.amountPaid,
    required this.balanceDue,
    required this.method,
    required this.paymentOption,
    required this.status,
  });

  factory Payment.fromAppointmentJson(Map<String, dynamic> json) {
    final paymentStatus = json['paymentStatus'] ?? 'pending';
    final date = json['date'] ?? '';

    String status;
    if (paymentStatus == 'paid') {
      status = 'Paid';
    } else if (paymentStatus == 'partially_paid') {
      status = 'Partially Paid';
    } else {
      // Pending for more than 3 days counts as overdue.
      final parsed = DateTime.tryParse(date);
      final isOld = parsed != null && DateTime.now().difference(parsed).inDays > 3;
      status = isOld ? 'Overdue' : 'Pending';
    }

    return Payment(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      appointmentCode: json['appointmentCode'] ?? '',
      patientName: json['patientName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      date: date,
      amount: (json['amount'] as num?) ?? 0,
      amountPaid: (json['amountPaid'] as num?) ?? 0,
      balanceDue: (json['balanceDue'] as num?) ?? 0,
      method: json['paymentMethod'] ?? 'Pay at Clinic',
      paymentOption: json['paymentOption'] ?? 'Full Payment',
      status: status,
    );
  }
}
