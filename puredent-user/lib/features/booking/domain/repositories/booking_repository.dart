import '../../../../core/utils/result.dart';
import '../entities/booking_result.dart';

abstract class BookingRepository {
  Future<Result<BookingResult>> createAppointment({
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
  });
}
