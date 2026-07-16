import 'package:dio/dio.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  ServicesRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<ServiceModel>> getServices({String? category}) async {
    final response = await _dio.get('/services', queryParameters: {
      if (category != null && category.isNotEmpty) 'category': category,
    });
    final list = response.data['data'] as List;
    return list.map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<ServiceModel> getServiceByIdOrSlug(String idOrSlug) async {
    final response = await _dio.get('/services/$idOrSlug');
    return ServiceModel.fromJson(response.data['data']);
  }
}
