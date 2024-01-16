part of 'future_interceptor.dart';

typedef InterceptorRequestCallback = FutureOr<FutureRequestOptions> Function(FutureRequestOptions options);

typedef InterceptorDataCallback = FutureOr<dynamic> Function(FutureRequestOptions options, dynamic data);

typedef InterceptorErrorCallback = FutureOr<FutureException> Function(FutureRequestOptions options, FutureException error);

typedef InterceptorTransformCallback = FutureOr<FutureResponse> Function(FutureResponse response);

class Interceptor {
  const Interceptor();

  InterceptorRequestCallback? get onRequest => null;
  InterceptorDataCallback? get onResponse => null;
  InterceptorErrorCallback? get onError => null;
  InterceptorTransformCallback? get onTransform => null;
}

class InterceptorWrapper extends Interceptor {
  InterceptorWrapper(
  {
    InterceptorRequestCallback? onRequest,
    InterceptorDataCallback? onResponse,
    InterceptorErrorCallback? onError,
    InterceptorTransformCallback? onTransform,
  }):_onRequest = onRequest,
    _onResponse = onResponse,
    _onError = onError,
    _onTransform = onTransform;

  final InterceptorRequestCallback? _onRequest;
  final InterceptorDataCallback? _onResponse;
  final InterceptorErrorCallback? _onError;
  final InterceptorTransformCallback? _onTransform;

  @override
  InterceptorRequestCallback? get onRequest => _onRequest;

  @override
  InterceptorDataCallback? get onResponse => _onResponse;

  @override
  InterceptorErrorCallback? get onError => _onError;

  @override
  InterceptorTransformCallback? get onTransform => _onTransform;
}

class FutureInterceptors extends ListMixin<Interceptor> {
  /// Define a nullable list to be capable with growable elements.
  final List<Interceptor?> _list = [];

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    _list.length = newLength;
  }

  @override
  Interceptor operator [](int index) => _list[index]!;

  @override
  void operator []=(int index, Interceptor value) {
    if (_list.length == index) {
      _list.add(value);
    } else {
      _list[index] = value;
    }
  }

  @override
  void clear() {
    _list.clear();
    super.clear();
  }
}