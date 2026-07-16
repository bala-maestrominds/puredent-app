import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.appointmentCode,
    required super.doctorId,
    required super.serviceId,
    required super.date,
    required super.time,
    required super.patientName,
    required super.patientEmail,
    required super.patientPhone,
    required super.status,
    super.checkInStatus,
    super.doctorName,
    super.serviceName,
    super.paymentMethod,
    super.paymentOption,
    super.consultationFee,
    super.amount,
    super.amountPaid,
    super.balanceDue,
    super.paymentStatus,
    super.rescheduleCount,
    super.originalDate,
    super.originalTime,
    super.cancellationReason,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // doctorId/serviceId may come back as a raw ObjectId string or as a
    // populated sub-document, depending on the endpoint.
    final doctorField = json['doctor'] ?? json['doctorId'];
    final serviceField = json['service'] ?? json['serviceId'];

    return AppointmentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      appointmentCode: json['appointmentCode'] ?? '',
      doctorId: doctorField is Map ? (doctorField['_id']?.toString() ?? '') : (doctorField?.toString() ?? ''),
      serviceId: serviceField is Map ? (serviceField['_id']?.toString() ?? '') : (serviceField?.toString() ?? ''),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      patientName: json['patientName'] ?? '',
      patientEmail: json['patientEmail'] ?? '',
      patientPhone: json['patientPhone'] ?? '',
      status: json['status'] ?? 'Pending',
      checkInStatus: json['checkInStatus'] ?? 'not_arrived',
      doctorName: doctorField is Map ? doctorField['name']?.toString() : json['doctorName']?.toString(),
      serviceName: serviceField is Map ? serviceField['name']?.toString() : json['serviceName']?.toString(),
      paymentMethod: json['paymentMethod'] ?? 'Pay at Clinic',
      paymentOption: json['paymentOption'] ?? 'Full Payment',
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balanceDue'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['paymentStatus'] ?? 'pending',
      rescheduleCount: (json['rescheduleCount'] as num?)?.toInt() ?? 0,
      originalDate: json['originalDate']?.toString(),
      originalTime: json['originalTime']?.toString(),
      cancellationReason: json['cancellationReason']?.toString(),
    );
  }
}
