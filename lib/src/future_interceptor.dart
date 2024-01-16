import 'dart:async';
import 'dart:developer';
import 'future_exception.dart';
import 'options.dart';
import 'response.dart';
import 'dart:collection';
part 'interceptor.dart';

typedef ErrorPrinter = void Function(dynamic error, StackTrace st);

void _defaultErrorPrinter(dynamic error, StackTrace st) {
  log("$error\n$st");
}

class FutureInterceptor<T> {
  ErrorPrinter? errorPrinter;
  FutureInterceptors get interceptors => _interceptors;
  final FutureInterceptors _interceptors = FutureInterceptors();

  FutureInterceptor({this.errorPrinter = _defaultErrorPrinter});

  Future<FutureResponse<T>> fetch(FutureRequestOptions<T> requestOptions) async {
    FutureRequestOptions option = requestOptions;
    for (final interceptor in interceptors) {
      if (interceptor.onRequest != null) {
        try {
          option = await interceptor.onRequest!.call(option);
        } catch (e, st) {
          errorPrinter?.call(e, st);
        }
      }
    }

    FutureResponse response;
    try {
      var data = await option.request();
      for (final interceptor in interceptors) {
        if (interceptor.onResponse != null) {
          try {
            data = await interceptor.onResponse!.call(option, data);
          } catch (e, st) {
            errorPrinter?.call(e, st);
          }
        }
      }
      response = FutureResponse(
        requestOptions: option,
        data: data,
      );
    } catch (e, st) {
      FutureException error = e is FutureException ? e : FutureException(
        error: e,
        stackTrace: st,
      );
      for (final interceptor in interceptors) {
        if (interceptor.onError != null) {
          try {
            error = await interceptor.onError!.call(option, error);
          } catch (e, st) {
            errorPrinter?.call(e, st);
          }
        }
      }
      response = FutureResponse(
        requestOptions: option,
        error: error,
      );
    }
    for (final interceptor in interceptors) {
      if (interceptor.onTransform != null) {
        try {
          response = await interceptor.onTransform!.call(response);
        } catch (e, st) {
          errorPrinter?.call(e, st);
        }
      }
    }
    if (response is FutureResponse<T>) {
      return response;
    }
    if (response.data is T || response.data == null) {
      return FutureResponse<T>(
        error: response.error,
        requestOptions: response.requestOptions,
        data: response.data,
      );
    }
    return FutureResponse<T>(
      data: null,
      requestOptions: requestOptions,
      error: FutureException(
        stackTrace: StackTrace.current,
        error: Exception("type '${response.data.runtimeType}' is not a subtype of type '$T' in type cast"),
      ),
    );
  }
}

