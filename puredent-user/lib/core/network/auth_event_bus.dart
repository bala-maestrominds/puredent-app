import 'dart:async';

enum AuthBusEvent { loggedOut, sessionExpired }


class AuthEventBus {
  final _controller = StreamController<AuthBusEvent>.broadcast();

  Stream<AuthBusEvent> get stream => _controller.stream;

  void emit(AuthBusEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
