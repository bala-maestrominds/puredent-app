import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  const AuthTokens({required this.accessToken, required this.refreshToken});
}

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<(UserModel, AuthTokens)> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return _parseAuthResponse(response.data);
  }

  Future<(UserModel, AuthTokens)> login({required String email, required String password}) async {
    final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return _parseAuthResponse(response.data);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data['data']);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    final response = await _dio.patch('/auth/me', data: updates);
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _dio.post('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  (UserModel, AuthTokens) _parseAuthResponse(Map<String, dynamic> body) {
    final data = body['data'];
    final user = UserModel.fromJson(data['user']);
    final tokens = AuthTokens(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
    return (user, tokens);
  }
}
