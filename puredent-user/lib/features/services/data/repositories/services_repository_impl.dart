import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  ServicesRepositoryImpl(this._remote);
  final ServicesRemoteDataSource _remote;

  List<ServiceEntity>? _cache;
  DateTime? _cachedAt;
  static const _cacheTtl = Duration(minutes: 5);

  bool get _isCacheValid =>
      _cache != null && _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  Future<Result<List<ServiceEntity>>> getServices({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) {
      return Result.success(_cache!);
    }
    try {
      final services = await _remote.getServices();
      _cache = services;
      _cachedAt = DateTime.now();
      return Result.success(services);
    } on DioException catch (e) {
      if (_cache != null) return Result.success(_cache!);
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      if (_cache != null) return Result.success(_cache!);
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<ServiceEntity>> getServiceByIdOrSlug(String idOrSlug) async {
    if (_cache != null) {
      for (final service in _cache!) {
        if (service.id == idOrSlug || service.slug == idOrSlug) return Result.success(service);
      }
    }
    try {
      final service = await _remote.getServiceByIdOrSlug(idOrSlug);
      return Result.success(service);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
