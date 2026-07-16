import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../datasources/doctors_remote_datasource.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  DoctorsRepositoryImpl(this._remote);
  final DoctorsRemoteDataSource _remote;

  List<DoctorEntity>? _cache;
  DateTime? _cachedAt;
  static const _cacheTtl = Duration(minutes: 5);

  bool get _isCacheValid =>
      _cache != null && _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  Future<Result<List<DoctorEntity>>> getDoctors({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) {
      return Result.success(_cache!);
    }
    try {
      final doctors = await _remote.getDoctors();
      _cache = doctors;
      _cachedAt = DateTime.now();
      return Result.success(doctors);
    } on DioException catch (e) {
      // Serve stale cache instead of an error if we have one, so a flaky
      // connection doesn't blank the screen when we already have data.
      if (_cache != null) return Result.success(_cache!);
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      if (_cache != null) return Result.success(_cache!);
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<DoctorEntity>> getDoctorById(String id) async {
    // Serve from cache first for a snappy detail-page transition.
    if (_cache != null) {
      for (final doctor in _cache!) {
        if (doctor.id == id) return Result.success(doctor);
      }
    }

    try {
      final doctor = await _remote.getDoctorById(id);
      return Result.success(doctor);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getAvailability(String doctorId, String date) async {
    try {
      final slots = await _remote.getAvailability(doctorId, date);
      return Result.success(slots);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
