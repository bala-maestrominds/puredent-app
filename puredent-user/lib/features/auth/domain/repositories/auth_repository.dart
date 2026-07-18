import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Result<UserEntity>> login({required String email, required String password});

  Future<Result<void>> logout();

  Future<UserEntity?> restoreSession();

  Future<Result<UserEntity>> fetchProfile();

  Future<Result<UserEntity>> updateProfile(Map<String, dynamic> updates);

  Future<Result<void>> changePassword({required String currentPassword, required String newPassword});

  Future<bool> get isLoggedIn;
}
