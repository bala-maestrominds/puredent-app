import 'package:equatable/equatable.dart';

class WorkingHour extends Equatable {
  final String day;
  final String startTime;
  final String endTime;
  const WorkingHour({required this.day, required this.startTime, required this.endTime});

  @override
  List<Object?> get props => [day, startTime, endTime];
}

class DoctorEntity extends Equatable {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String photoUrl;
  final int experienceYears;
  final double consultationFee;
  final double rating;
  final int reviews;
  final String experience;
  final String education;
  final List<String> languages;
  final List<WorkingHour> workingHours;
  final int slotDurationMinutes;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.specialty,
    this.bio = '',
    this.photoUrl = '',
    this.experienceYears = 0,
    this.consultationFee = 0,
    this.rating = 0,
    this.reviews = 0,
    this.experience = '',
    this.education = '',
    this.languages = const [],
    this.workingHours = const [],
    this.slotDurationMinutes = 30,
  });

  @override
  List<Object?> get props => [id, name, specialty, rating, reviews, consultationFee];
}
