import 'dart:async';

typedef FetchMethod<T> = FutureOr<T> Function();

class FutureRequestOptions<T> {
  FutureRequestOptions({
    Map<String, dynamic>? extra,
    required this.request,
  }) {
    if (extra != null) {
      this.extra = extra;
    }
  }

  final FetchMethod<T> request;
  Map<String, dynamic> extra = {};

  FutureRequestOptions copyWith({
    FutureOr<T> Function()? request,
    Map<String, dynamic>? extra,
  }) {
    return FutureRequestOptions<T>(
      request: request ?? this.request,
      extra: extra ?? this.extra,
    );
  }
}
