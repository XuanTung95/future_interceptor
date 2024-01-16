/// [FutureException] describes the exception info when a request failed.
class FutureException implements Exception {
  FutureException({
    this.error,
    StackTrace? stackTrace,
    this.message,
  }) : stackTrace = identical(stackTrace, StackTrace.empty)
            ? StackTrace.current
            : stackTrace ?? StackTrace.current;

  /// The original error/exception object;
  final Object? error;

  /// The stacktrace of the original error/exception object;
  final StackTrace stackTrace;

  /// The error message that throws a [FutureException].
  final String? message;

  /// Generate a new [FutureException] by combining given values and original values.
  FutureException copyWith({
    Object? error,
    StackTrace? stackTrace,
    String? message,
  }) {
    return FutureException(
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    String msg = 'FutureException: $message';
    if (error != null) {
      msg += '\nError: $error';
    }
    return msg;
  }
}
