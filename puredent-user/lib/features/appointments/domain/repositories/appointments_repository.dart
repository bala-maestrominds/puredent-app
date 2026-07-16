import '../../../../core/utils/result.dart';
import '../entities/appointment_entity.dart';

abstract class AppointmentsRepository {
  Future<Result<List<AppointmentEntity>>> getMyAppointments();
  Future<Result<AppointmentEntity>> getById(String id);
  Future<Result<AppointmentEntity>> reschedule(String id, {required String date, required String time});
  Future<Result<AppointmentEntity>> cancel(String id, {String? reason});
  Future<Result<AppointmentEntity>> payBalance(String id, {String paymentMethod});
}
