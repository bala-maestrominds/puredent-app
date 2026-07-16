import '../../../appointments/domain/entities/appointment_entity.dart';

class BookingResult {
  final AppointmentEntity appointment;
  final String qrCodeDataUrl;
  final bool emailSent;
  const BookingResult({required this.appointment, required this.qrCodeDataUrl, required this.emailSent});
}
