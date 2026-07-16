import '../../domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.specialty,
    super.bio,
    super.photoUrl,
    super.experienceYears,
    super.consultationFee,
    super.rating,
    super.reviews,
    super.experience,
    super.education,
    super.languages,
    super.workingHours,
    super.slotDurationMinutes,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        specialty: json['specialty'] ?? '',
        bio: json['bio'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
        experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
        consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviews: (json['reviews'] as num?)?.toInt() ?? 0,
        experience: json['experience'] ?? '',
        education: json['education'] ?? '',
        languages: (json['languages'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        workingHours: (json['workingHours'] as List?)
                ?.map((e) => WorkingHour(day: e['day'], startTime: e['startTime'], endTime: e['endTime']))
                .toList() ??
            const [],
        slotDurationMinutes: (json['slotDurationMinutes'] as num?)?.toInt() ?? 30,
      );
}
