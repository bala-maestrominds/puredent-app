import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/auth_event_bus.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Single source of truth for auth/session state. Also listens on
/// [AuthEventBus] so a forced-logout from the network layer (refresh token
/// expired) reflects immediately in the UI.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
      {required AuthRepository authRepository,
      required AuthEventBus authEventBus})
      : _authRepository = authRepository,
        _authEventBus = authEventBus,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested, transformer: droppable());
    on<AuthRegisterRequested>(_onRegisterRequested, transformer: droppable());
    on<AuthLogoutRequested>(_onLogoutRequested, transformer: droppable());
    on<AuthProfileUpdated>(
        (event, emit) => emit(AuthAuthenticated(event.user)));
    on<AuthSessionExpired>((event, emit) => emit(const AuthUnauthenticated()));

    _busSubscription = _authEventBus.stream.listen((event) {
      if (event == AuthBusEvent.sessionExpired) {
        add(const AuthSessionExpired());
      }
    });
  }

  final AuthRepository _authRepository;
  final AuthEventBus _authEventBus;
  late final StreamSubscription<AuthBusEvent> _busSubscription;

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthChecking());
    final user = await _authRepository.restoreSession();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.login(
        email: event.email, password: event.password);
    result.when(
      success: (user) => emit(AuthAuthenticated(user)),
      failure: (f) => emit(AuthFailure(f)),
    );
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
      phone: event.phone,
    );
    result.when(
      success: (user) => emit(AuthAuthenticated(user)),
      failure: (f) => emit(AuthFailure(f)),
    );
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _busSubscription.cancel();
    return super.close();
  }
}
