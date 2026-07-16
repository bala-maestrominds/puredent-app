import '../models/appointment.dart';
import '../models/dashboard_stats.dart';
import '../models/patient.dart';
import '../models/revenue_report.dart';
import 'api_client.dart';

class AdminApiService {
  AdminApiService._();
  static final AdminApiService instance = AdminApiService._();

  Future<DashboardStats> getStats() async {
    final data = await ApiClient.instance.get('/admin/stats');
    return DashboardStats.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Patient>> listPatients({String? search}) async {
    final data = await ApiClient.instance.get('/admin/patients', query: {'search': search});
    return (data as List).map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RevenueReport> getRevenue({String period = 'week'}) async {
    final data = await ApiClient.instance.get('/admin/revenue', query: {'period': period});
    return RevenueReport.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Appointment>> getPatientAppointments(String email) async {
    final data = await ApiClient.instance.get('/admin/patients/${Uri.encodeComponent(email)}/appointments');
    return (data as List).map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }
}
