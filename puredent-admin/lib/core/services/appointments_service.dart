import '../models/appointment.dart';
import 'api_client.dart';

class AppointmentsService {
  AppointmentsService._();
  static final AppointmentsService instance = AppointmentsService._();

  Future<List<Appointment>> list({String? status, String? date, String? search, String? doctorId}) async {
    final data = await ApiClient.instance.get('/appointments', query: {
      'status': status,
      'date': date,
      'search': search,
      'doctorId': doctorId,
    });
    return (data as List).map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Appointment> updateStatus(String id, String status) async {
    final data = await ApiClient.instance.patch('/appointments/$id/status', body: {'status': status});
    return Appointment.fromJson(data as Map<String, dynamic>);
  }

  Future<Appointment> checkIn(String id) async {
    final data = await ApiClient.instance.post('/appointments/$id/checkin');
    return Appointment.fromJson(data as Map<String, dynamic>);
  }

  /// Verifies a scanned QR payload ({code, token}) against the backend and
  /// returns the matching appointment, or throws [ApiException] if the code
  /// is invalid, forged, or the appointment was cancelled.
  Future<Appointment> verify({required String code, required String token}) async {
    final data = await ApiClient.instance.post('/appointments/verify', body: {
      'code': code,
      'token': token,
    });
    return Appointment.fromJson(data as Map<String, dynamic>);
  }
}
