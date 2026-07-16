import 'package:dio/dio.dart';
import '../models/appointment_model.dart';

class AppointmentsRemoteDataSource {
  AppointmentsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<AppointmentModel>> getMyAppointments() async {
    final response = await _dio.get('/appointments/mine');
    final list = response.data['data'] as List;
    return list.map((e) => AppointmentModel.fromJson(e)).toList();
  }

  Future<AppointmentModel> getById(String id) async {
    final response = await _dio.get('/appointments/$id');
    return AppointmentModel.fromJson(response.data['data']);
  }

  Future<AppointmentModel> reschedule(String id, {required String date, required String time}) async {
    final response = await _dio.patch('/appointments/$id/reschedule', data: {
      'date': date,
      'time': time,
    });
    return AppointmentModel.fromJson(response.data['data']);
  }

  Future<AppointmentModel> cancel(String id, {String? reason}) async {
    final response = await _dio.patch('/appointments/$id/cancel', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    return AppointmentModel.fromJson(response.data['data']);
  }

  Future<AppointmentModel> payBalance(String id, {String paymentMethod = 'Card'}) async {
    final response = await _dio.patch('/appointments/$id/pay', data: {
      'paymentMethod': paymentMethod,
    });
    return AppointmentModel.fromJson(response.data['data']);
  }
}
