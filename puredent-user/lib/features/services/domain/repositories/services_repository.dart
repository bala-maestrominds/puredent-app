import '../../../../core/utils/result.dart';
import '../entities/service_entity.dart';

abstract class ServicesRepository {
  Future<Result<List<ServiceEntity>>> getServices({bool forceRefresh = false});
  Future<Result<ServiceEntity>> getServiceByIdOrSlug(String idOrSlug);
}
