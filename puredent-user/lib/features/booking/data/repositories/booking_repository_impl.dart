import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/booking_result.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);
  final BookingRemoteDataSource _remote;

  @override
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
  }) async {
    try {
      final result = await _remote.createAppointment(
        doctorId: doctorId,
        serviceId: serviceId,
        date: date,
        time: time,
        patientName: patientName,
        patientEmail: patientEmail,
        patientPhone: patientPhone,
        patientAge: patientAge,
        patientGender: patientGender,
        notes: notes,
        paymentMethod: paymentMethod,
        paymentOption: paymentOption,
      );
      return Result.success(
        BookingResult(appointment: result.appointment, qrCodeDataUrl: result.qrCodeDataUrl, emailSent: result.emailSent),
      );
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
