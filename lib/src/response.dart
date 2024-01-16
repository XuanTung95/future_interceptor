import 'future_exception.dart';
import 'options.dart';

class FutureResponse<T> {
  FutureResponse({
    this.data,
    this.error,
    required this.requestOptions,
  });

  /// The response payload in specific type.
  final T? data;

  final FutureException? error;

  final FutureRequestOptions requestOptions;
}
