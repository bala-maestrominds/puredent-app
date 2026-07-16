import '../../../doctors/data/models/doctor_model.dart';
import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.slug,
    super.category,
    super.shortDescription,
    super.description,
    super.imageUrl,
    super.priceFrom,
    required super.durationMinutes,
    super.keyBenefits,
    super.process,
    super.bestSpecialist,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        category: json['category'] ?? 'General',
        shortDescription: json['shortDescription'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        priceFrom: (json['priceFrom'] as num?)?.toDouble(),
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
        keyBenefits: (json['keyBenefits'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        process: (json['process'] as List?)
                ?.map((e) => ServiceProcessStep(
                      step: (e['step'] as num?)?.toInt() ?? 0,
                      title: e['title'] ?? '',
                      description: e['description'] ?? '',
                    ))
                .toList() ??
            const [],
        bestSpecialist:
            json['bestSpecialist'] != null ? DoctorModel.fromJson(json['bestSpecialist']) : null,
      );
}
