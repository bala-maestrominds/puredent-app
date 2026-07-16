import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  AppointmentsRepositoryImpl(this._remote);
  final AppointmentsRemoteDataSource _remote;

  @override
  Future<Result<List<AppointmentEntity>>> getMyAppointments() async {
    try {
      final appointments = await _remote.getMyAppointments();
      return Result.success(appointments);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<AppointmentEntity>> getById(String id) async {
    try {
      final appointment = await _remote.getById(id);
      return Result.success(appointment);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<AppointmentEntity>> reschedule(String id, {required String date, required String time}) async {
    try {
      final appointment = await _remote.reschedule(id, date: date, time: time);
      return Result.success(appointment);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<AppointmentEntity>> cancel(String id, {String? reason}) async {
    try {
      final appointment = await _remote.cancel(id, reason: reason);
      return Result.success(appointment);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<AppointmentEntity>> payBalance(String id, {String paymentMethod = 'Card'}) async {
    try {
      final appointment = await _remote.payBalance(id, paymentMethod: paymentMethod);
      return Result.success(appointment);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
