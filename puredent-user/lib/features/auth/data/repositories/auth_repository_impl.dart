import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remote, required TokenStorage tokenStorage})
      : _remote = remote,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  // Simple in-memory cache of the current user for the session; avoids an
  // extra /auth/me round trip on every screen that needs the user's name.
  UserEntity? _cachedUser;

  @override
  Future<Result<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _guard(() async {
        final (user, tokens) = await _remote.register(name: name, email: email, password: password, phone: phone);
        await _tokenStorage.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
        _cachedUser = user;
        return user;
      });

  @override
  Future<Result<UserEntity>> login({required String email, required String password}) => _guard(() async {
        final (user, tokens) = await _remote.login(email: email, password: password);
        await _tokenStorage.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
        _cachedUser = user;
        return user;
      });

  @override
  Future<Result<void>> logout() => _guard(() async {
        try {
          await _remote.logout();
        } catch (_) {
          // Even if the server call fails (e.g. offline), still clear local
          // tokens so the user is logged out on-device.
        }
        _cachedUser = null;
        await _tokenStorage.clear();
      });

  @override
  Future<UserEntity?> restoreSession() async {
    final token = await _tokenStorage.accessToken;
    if (token == null || token.isEmpty) return null;
    if (_cachedUser != null) return _cachedUser;

    final result = await fetchProfile();
    return result.when(success: (user) => user, failure: (_) => null);
  }

  @override
  Future<Result<UserEntity>> fetchProfile() => _guard(() async {
        final user = await _remote.getMe();
        _cachedUser = user;
        return user;
      });

  @override
  Future<Result<UserEntity>> updateProfile(Map<String, dynamic> updates) => _guard(() async {
        final user = await _remote.updateProfile(updates);
        _cachedUser = user;
        return user;
      });

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) =>
      _guard(() => _remote.changePassword(currentPassword: currentPassword, newPassword: newPassword));

  @override
  Future<bool> get isLoggedIn async {
    final token = await _tokenStorage.accessToken;
    return token != null && token.isNotEmpty;
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Result.success(result);
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : Failure.unknown(e.message);
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
