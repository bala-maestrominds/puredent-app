/// A "patient" here is derived server-side from the Appointment collection
/// (grouped by email) -- there's no separate Patient model in the backend,
/// since guest booking is allowed and patient details are captured per visit.
class Patient {
  final String id; // the patient's email, used as the grouping key
  final String name;
  final String email;
  final String phone;
  final String gender;
  final num? age;
  final String lastVisit;
  final int totalAppointments;
  final String lastStatus;

  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.age,
    required this.lastVisit,
    required this.totalAppointments,
    required this.lastStatus,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: (json['id'] ?? json['email'] ?? '').toString(),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        gender: json['gender'] ?? '',
        age: json['age'] as num?,
        lastVisit: json['lastVisit'] ?? '',
        totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
        lastStatus: json['lastStatus'] ?? '',
      );
}
