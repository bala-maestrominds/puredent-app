import 'dart:async';

/// Generic debouncer used for search fields / any rapid-fire user input that
/// should not trigger a network call on every keystroke.
///
/// Usage:
/// ```dart
/// final _debouncer = Debouncer(delay: AppConfig.searchDebounce);
/// onChanged: (value) => _debouncer.run(() => bloc.add(SearchChanged(value)));
/// ```
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() => _timer?.cancel();
}
