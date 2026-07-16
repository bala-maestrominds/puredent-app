import '../../../../core/utils/result.dart';
import '../entities/doctor_entity.dart';

abstract class DoctorsRepository {
  /// Cached, client-filterable list of doctors. [forceRefresh] bypasses the
  /// in-memory cache (e.g. pull-to-refresh).
  Future<Result<List<DoctorEntity>>> getDoctors({bool forceRefresh = false});

  Future<Result<DoctorEntity>> getDoctorById(String id);

  Future<Result<List<String>>> getAvailability(String doctorId, String date);
}
