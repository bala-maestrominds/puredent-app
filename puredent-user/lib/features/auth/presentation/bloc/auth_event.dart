part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Fired once on app start to decide the initial route.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.phone = '',
  });
  @override
  List<Object?> get props => [name, email, password, phone];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthProfileUpdated extends AuthEvent {
  final UserEntity user;
  const AuthProfileUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

/// Internal event triggered by [AuthEventBus] when the network layer detects
/// an unrecoverable 401 (refresh token also expired/invalid).
class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
