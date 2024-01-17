Integrate Interceptor into an asynchronous operation, inspired by Dio.

## Motivation

Enables the breakdown of tasks into smaller, independent operational units (Interceptor).

Easily adds new functionality to the application by creating new Interceptors.

Easy to modify and upgrade as Interceptors are not dependent on each other.

Increases code reuse.

Auto catch all exception.

## Features

- `onRequest`: allows monitoring and modification of the input request.
- `onResponse`: allows monitoring and modification of the response data.
- `onError`: allows monitoring and modification of the error.
- `onTransform`: allow modification of the FutureResponse before returning to the caller.
- `extra`: Custom field that can be retrieved later.

## Usage

```dart

/// Create your Interceptor

class LoggingInterceptor extends Interceptor {

  @override
  InterceptorRequestCallback? get onRequest => (options) {
    print("onRequest");
    return options;
  };

  @override
  InterceptorDataCallback? get onResponse => (options, data) {
    print("onResponse with data $data");
    return data;
  };

  @override
  InterceptorErrorCallback? get onError => (options, error) {
    print("onError $error");
    return error;
  };

  @override
  InterceptorTransformCallback? get onTransform => (response) {
    print("onTransform response $response");
    return response;
  };
}

/// Create a class that setup interceptors and expose fetch method

class MyClass {
  late FutureInterceptor _futureInterceptor;

  MyClass() {
    _futureInterceptor = FutureInterceptor();
    _futureInterceptor.interceptors.add(LoggingInterceptor());
  }

  Future<FutureResponse<dynamic>> fetch(FetchMethod request) async {
    return _futureInterceptor.fetch(FutureRequestOptions(
        request: request,
        extra: {'key' : 'val'},
    ));
  }
}

/// Finally

Future test() async {
  final myClass = MyClass();
  final res = await myClass.fetch(() async {
    // Do your work here
    return "my result";
  });
  if (res.error != null) {
    print("Error: ${res.error}");
  } else {
    print("Response: ${res.data}");
  }
}

```

## Some rules

- FutureInterceptor.fetch() will never throw an exception.
- The operation of each Interceptor is not affected by other Interceptors. 
  However, the Interceptor's input can be changed by the Interceptor before it.
- `onRequest` and `onTransform` callbacks will always be called.
- If request return a result, all `onResponse` callbacks will be called.
- If request throws an exception, all `onError` callbacks will be called.
- If a callback throws an exception, it will be ignored.

## Extensions

### RecordExtension

RecordExtension is used to store an unique data for each request.
Unlike FutureRequestOptions, a record cannot be modified by other Interceptors.

Example:

```dart
class InterceptorWithRecord extends Interceptor with RecordExtension {
  int id = 0;

  @override
  InterceptorRequestCallback get onRequest => (option) {
    setRecord(id++);
    return option;
  };

  @override
  InterceptorDataCallback get onResponse => (option, data) {
    /// Show the data that has been set by the previous callback of this request.
    print('Record = $record');
    return data;
  };
}
```