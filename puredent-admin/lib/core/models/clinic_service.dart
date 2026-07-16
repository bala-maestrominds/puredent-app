import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ClinicService {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String shortDescription;
  final String description;
  final String imageUrl;
  final num? priceFrom;
  final int durationMinutes;
  final bool isActive;

  const ClinicService({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.imageUrl,
    required this.priceFrom,
    required this.durationMinutes,
    required this.isActive,
  });

  String get resolvedImageUrl => ApiClient.resolveMediaUrl(imageUrl);

  /// The backend has no icon concept -- pick a sensible one from the category
  /// so the Treatments grid still looks intentional.
  IconData get icon {
    switch (category.toLowerCase()) {
      case 'orthodontics':
        return Icons.health_and_safety_rounded;
      case 'periodontics':
        return Icons.spa_rounded;
      case 'oral surgery':
        return Icons.medical_information_rounded;
      case 'cosmetic':
        return Icons.auto_awesome_rounded;
      case 'endodontics':
        return Icons.healing_rounded;
      case 'pediatric dentistry':
        return Icons.child_care_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  factory ClinicService.fromJson(Map<String, dynamic> json) => ClinicService(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        category: json['category'] ?? 'General',
        shortDescription: json['shortDescription'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        priceFrom: json['priceFrom'] as num?,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
        isActive: json['isActive'] ?? true,
      );
}
