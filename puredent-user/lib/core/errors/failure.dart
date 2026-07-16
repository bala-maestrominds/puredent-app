/// Base failure type surfaced to the UI layer. Kept deliberately small and
/// serializable-free so Bloc states can carry it directly.
class Failure {
  final String message;
  final int? statusCode;
  final List<FieldError>? fieldErrors;

  const Failure(this.message, {this.statusCode, this.fieldErrors});

  factory Failure.network() => const Failure('No internet connection. Please check your network and try again.');

  factory Failure.timeout() => const Failure('The request took too long. Please try again.');

  factory Failure.unauthorized() => const Failure('Your session has expired. Please log in again.', statusCode: 401);

  factory Failure.unknown([String? message]) => Failure(message ?? 'Something went wrong. Please try again.');

  @override
  String toString() => message;
}

class FieldError {
  final String field;
  final String message;
  const FieldError(this.field, this.message);
}
