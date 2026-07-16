import 'package:dio/dio.dart';
import '../models/doctor_model.dart';

class DoctorsRemoteDataSource {
  DoctorsRemoteDataSource(this._dio);
  final Dio _dio;

  /// Note: the backend currently returns the full active-doctors list
  /// (optionally filtered by `specialty`) with no server-side pagination.
  /// Search/pagination for the UI is therefore done client-side in the
  /// repository/bloc layer — see [DoctorsRepositoryImpl].
  Future<List<DoctorModel>> getDoctors({String? specialty}) async {
    final response = await _dio.get('/doctors', queryParameters: {
      if (specialty != null && specialty.isNotEmpty) 'specialty': specialty,
    });
    final list = response.data['data'] as List;
    return list.map((e) => DoctorModel.fromJson(e)).toList();
  }

  Future<DoctorModel> getDoctorById(String id) async {
    final response = await _dio.get('/doctors/$id');
    return DoctorModel.fromJson(response.data['data']);
  }

  Future<List<String>> getAvailability(String doctorId, String date) async {
    final response = await _dio.get('/doctors/$doctorId/availability', queryParameters: {'date': date});
    final slots = response.data['data']['slots'] as List;
    return slots.map((e) => e.toString()).toList();
  }
}
