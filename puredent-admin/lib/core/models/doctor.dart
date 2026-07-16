import '../services/api_client.dart';

class WorkingHour {
  final String day;
  final String startTime;
  final String endTime;

  const WorkingHour({required this.day, required this.startTime, required this.endTime});

  factory WorkingHour.fromJson(Map<String, dynamic> json) => WorkingHour(
        day: json['day'] ?? '',
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
      );

  Map<String, dynamic> toJson() => {'day': day, 'startTime': startTime, 'endTime': endTime};
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String photoUrl;
  final String email;
  final String phone;
  final int experienceYears;
  final num consultationFee;
  final double rating;
  final int reviews;
  final String experience;
  final String education;
  final List<String> languages;
  final List<WorkingHour> workingHours;
  final int slotDurationMinutes;
  final bool isActive;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.photoUrl,
    required this.email,
    required this.phone,
    required this.experienceYears,
    required this.consultationFee,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.education,
    required this.languages,
    required this.workingHours,
    required this.slotDurationMinutes,
    required this.isActive,
  });

  /// Absolute URL for the doctor's photo, or '' if none set.
  String get resolvedPhotoUrl => ApiClient.resolveMediaUrl(photoUrl);

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        specialty: json['specialty'] ?? '',
        bio: json['bio'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
        consultationFee: (json['consultationFee'] as num?) ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviews: (json['reviews'] as num?)?.toInt() ?? 0,
        experience: json['experience'] ?? '',
        education: json['education'] ?? '',
        languages: (json['languages'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        workingHours: (json['workingHours'] as List?)
                ?.map((e) => WorkingHour.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        slotDurationMinutes: (json['slotDurationMinutes'] as num?)?.toInt() ?? 30,
        isActive: json['isActive'] ?? true,
      );

  /// Short "Mon, Wed, Fri" style label built from workingHours, since the
  /// backend doesn't send a separate list of day abbreviations.
  String get workingDaysLabel {
    if (workingHours.isEmpty) return 'Not set';
    const shortNames = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
    };
    return workingHours.map((w) => shortNames[w.day] ?? w.day).join(', ');
  }
}
