import 'package:dio/dio.dart';
import '../../../appointments/data/models/appointment_model.dart';

class BookingCreateResult {
  final AppointmentModel appointment;
  final String qrCodeDataUrl;
  final bool emailSent;
  const BookingCreateResult({required this.appointment, required this.qrCodeDataUrl, required this.emailSent});
}

class BookingRemoteDataSource {
  BookingRemoteDataSource(this._dio);
  final Dio _dio;

  Future<BookingCreateResult> createAppointment({
    required String doctorId,
    required String serviceId,
    required String date,
    required String time,
    required String patientName,
    required String patientEmail,
    required String patientPhone,
    int? patientAge,
    String? patientGender,
    String? notes,
    String? paymentMethod,
    String? paymentOption,
  }) async {
    final response = await _dio.post('/appointments', data: {
      'doctorId': doctorId,
      'serviceId': serviceId,
      'date': date,
      'time': time,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      if (patientAge != null) 'patientAge': patientAge,
      if (patientGender != null && patientGender.isNotEmpty) 'patientGender': patientGender,
      'notes': notes ?? '',
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentOption != null) 'paymentOption': paymentOption,
    });

    final data = response.data['data'];
    return BookingCreateResult(
      appointment: AppointmentModel.fromJson(data['appointment']),
      qrCodeDataUrl: data['qrCodeDataUrl'] ?? '',
      emailSent: data['emailSent'] ?? false,
    );
  }
}
