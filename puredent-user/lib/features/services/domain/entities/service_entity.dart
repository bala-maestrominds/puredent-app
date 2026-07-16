import 'package:equatable/equatable.dart';

import '../../../doctors/domain/entities/doctor_entity.dart';

class ServiceProcessStep extends Equatable {
  final int step;
  final String title;
  final String description;

  const ServiceProcessStep({
    required this.step,
    required this.title,
    this.description = '',
  });

  @override
  List<Object?> get props => [step, title, description];
}

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String shortDescription;
  final String description;
  final String imageUrl;
  final double? priceFrom;
  final int durationMinutes;
  final List<String> keyBenefits;
  final List<ServiceProcessStep> process;
  final DoctorEntity? bestSpecialist;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.category = 'General',
    this.shortDescription = '',
    this.description = '',
    this.imageUrl = '',
    this.priceFrom,
    required this.durationMinutes,
    this.keyBenefits = const [],
    this.process = const [],
    this.bestSpecialist,
  });

  @override
  List<Object?> get props => [id, name, slug, category, priceFrom, durationMinutes];
}
