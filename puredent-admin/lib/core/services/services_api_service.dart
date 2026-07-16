import '../models/clinic_service.dart';
import 'api_client.dart';

class ServicesApiService {
  ServicesApiService._();
  static final ServicesApiService instance = ServicesApiService._();

  Future<List<ClinicService>> list({String? category}) async {
    final data = await ApiClient.instance.get('/services', query: {'category': category});
    return (data as List).map((e) => ClinicService.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ClinicService> create({
    required String name,
    required String category,
    required String shortDescription,
    required String description,
    required num? priceFrom,
    required int durationMinutes,
    String? imagePath,
  }) async {
    final fields = <String, String>{
      'name': name,
      'category': category,
      'shortDescription': shortDescription,
      'description': description,
      'durationMinutes': durationMinutes.toString(),
    };
    if (priceFrom != null) fields['priceFrom'] = priceFrom.toString();

    final data = await ApiClient.instance.multipart(
      '/services',
      method: 'POST',
      fields: fields,
      fileField: imagePath != null ? 'image' : null,
      filePath: imagePath,
    );
    return ClinicService.fromJson(data as Map<String, dynamic>);
  }

  Future<ClinicService> update(
    String id, {
    String? name,
    String? category,
    String? shortDescription,
    String? description,
    num? priceFrom,
    int? durationMinutes,
    bool? isActive,
    String? imagePath,
  }) async {
    final fields = <String, String>{};
    if (name != null) fields['name'] = name;
    if (category != null) fields['category'] = category;
    if (shortDescription != null) fields['shortDescription'] = shortDescription;
    if (description != null) fields['description'] = description;
    if (priceFrom != null) fields['priceFrom'] = priceFrom.toString();
    if (durationMinutes != null) fields['durationMinutes'] = durationMinutes.toString();
    if (isActive != null) fields['isActive'] = isActive.toString();

    final data = await ApiClient.instance.multipart(
      '/services/$id',
      method: 'PATCH',
      fields: fields,
      fileField: imagePath != null ? 'image' : null,
      filePath: imagePath,
    );
    return ClinicService.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await ApiClient.instance.delete('/services/$id');
  }
}
