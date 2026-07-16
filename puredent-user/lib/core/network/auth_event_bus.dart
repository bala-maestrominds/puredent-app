import 'dart:async';

enum AuthBusEvent { loggedOut, sessionExpired }

/// Lightweight pub/sub so the network layer (Dio interceptor) can signal
/// "please log this user out" without importing the auth Bloc directly.
///
/// Named `AuthBusEvent` (not `AuthEvent`) deliberately — `AuthEvent` is
/// already the sealed class name for `AuthBloc`'s events, and both types
/// end up imported into `auth_bloc.dart`, so a shared name is ambiguous.
class AuthEventBus {
  final _controller = StreamController<AuthBusEvent>.broadcast();

  Stream<AuthBusEvent> get stream => _controller.stream;

  void emit(AuthBusEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
