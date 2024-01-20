import 'dart:async';
import 'package:future_interceptor/src/extension/record_extension.dart';

import 'future_exception.dart';
import 'listener.dart';
import 'options.dart';
import 'response.dart';
import 'dart:collection';

part 'interceptor.dart';

typedef ErrorPrinter = void Function(dynamic error, StackTrace st);

void _defaultErrorPrinter(dynamic error, StackTrace st) {
  print("$error\n$st");
}

class FutureInterceptor<T> {
  ErrorPrinter? errorPrinter;
  Interceptors get interceptors => _interceptors;
  final Interceptors _interceptors = Interceptors();
  final Set<FutureListener> _listeners = {};
  Set<FutureListener> get listeners => _listeners;

  FutureInterceptor({this.errorPrinter = _defaultErrorPrinter});

  Future<FutureResponse<T>> fetch(FutureRequestOptions<T> requestOptions) async {
    FutureRequestOptions option = requestOptions;
    final Map extensionData = {};
    for (final interceptor in interceptors) {
      if (interceptor.onRequest != null) {
        try {
          _processExtensionsBeforeCallback(extensionData, interceptor);
          option = interceptor.onRequest!.call(option);
        } catch (e, st) {
          errorPrinter?.call(e, st);
        } finally {
          _processExtensionsAfterCallback(extensionData, interceptor);
        }
      }
    }
    _notifyRequestCallback();
    FutureResponse response;
    try {
      var data = await option.request();
      for (final interceptor in interceptors) {
        if (interceptor.onResponse != null) {
          try {
            _processExtensionsBeforeCallback(extensionData, interceptor);
            data = interceptor.onResponse!.call(option, data);
          } catch (e, st) {
            errorPrinter?.call(e, st);
          } finally {
            _processExtensionsAfterCallback(extensionData, interceptor);
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
            _processExtensionsBeforeCallback(extensionData, interceptor);
            error = interceptor.onError!.call(option, error);
          } catch (e, st) {
            errorPrinter?.call(e, st);
          } finally {
            _processExtensionsAfterCallback(extensionData, interceptor);
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
          _processExtensionsBeforeCallback(extensionData, interceptor);
          response = interceptor.onTransform!.call(response);
        } catch (e, st) {
          errorPrinter?.call(e, st);
        } finally {
          _processExtensionsAfterCallback(extensionData, interceptor);
        }
      }
    }
    _notifyResponseCallback();
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

  void _processExtensionsBeforeCallback(Map extensionData, Interceptor interceptor) {
    if (interceptor is RecordExtension) {
      (interceptor as RecordExtension).setRecord(extensionData[interceptor]);
    }
  }

  void _processExtensionsAfterCallback(Map extensionData, Interceptor interceptor) {
    if (interceptor is RecordExtension) {
      extensionData[interceptor] = (interceptor as RecordExtension).record;
      (interceptor as RecordExtension).setRecord(null);
    }
  }

  bool addListener(FutureListener listener) {
    return _listeners.add(listener);
  }

  void _notifyRequestCallback() {
    if (_listeners.isNotEmpty) {
      for (var item in _listeners) {
        if (item.requestCallback != null) {
          try {
            item.requestCallback!.call();
          } catch (e, st) {
            errorPrinter?.call(e, st);
          }
        }
      }
    }
  }

  void _notifyResponseCallback() {
    if (_listeners.isNotEmpty) {
      for (var item in _listeners) {
        if (item.responseCallback != null) {
          try {
            item.responseCallback!.call();
          } catch (e, st) {
            errorPrinter?.call(e, st);
          }
        }
      }
    }
  }
}

