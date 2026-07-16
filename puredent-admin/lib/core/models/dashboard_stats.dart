import 'appointment.dart';

class TodayRevenue {
  final double total;
  final List<double> values;
  final List<String> labels;

  const TodayRevenue({required this.total, required this.values, required this.labels});

  factory TodayRevenue.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TodayRevenue(total: 0, values: [], labels: []);
    return TodayRevenue(
      total: (json['total'] as num?)?.toDouble() ?? 0,
      values: (json['values'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? const [],
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class DashboardStats {
  final int totalDoctors;
  final int activeDoctors;
  final int totalServices;
  final int todaysAppointments;
  final int pendingAppointments;
  final int completedAppointments;
  final int totalAppointments;
  final int totalPatients;
  final List<Appointment> recentAppointments;
  final TodayRevenue todayRevenue;
  final Appointment? nextAppointment;

  const DashboardStats({
    required this.totalDoctors,
    required this.activeDoctors,
    required this.totalServices,
    required this.todaysAppointments,
    required this.pendingAppointments,
    required this.completedAppointments,
    required this.totalAppointments,
    required this.totalPatients,
    required this.recentAppointments,
    required this.todayRevenue,
    required this.nextAppointment,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalDoctors: (json['totalDoctors'] as num?)?.toInt() ?? 0,
        activeDoctors: (json['activeDoctors'] as num?)?.toInt() ?? 0,
        totalServices: (json['totalServices'] as num?)?.toInt() ?? 0,
        todaysAppointments: (json['todaysAppointments'] as num?)?.toInt() ?? 0,
        pendingAppointments: (json['pendingAppointments'] as num?)?.toInt() ?? 0,
        completedAppointments: (json['completedAppointments'] as num?)?.toInt() ?? 0,
        totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
        totalPatients: (json['totalPatients'] as num?)?.toInt() ?? 0,
        recentAppointments: (json['recentAppointments'] as List?)
                ?.map((e) => Appointment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        todayRevenue: TodayRevenue.fromJson(json['todayRevenue'] as Map<String, dynamic>?),
        nextAppointment: json['nextAppointment'] != null
            ? Appointment.fromJson(json['nextAppointment'] as Map<String, dynamic>)
            : null,
      );
}
