import 'package:test/test.dart';

import 'package:future_interceptor/future_interceptor.dart';

void main() {
  late FutureInterceptor<String> futureInterceptor;

  setUp(() {
    futureInterceptor = FutureInterceptor<String>();
  });

  test('Multiple Interceptors', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.addAll([
      InterceptorWrapper(
        onRequest: (option) {
          return option.copyWith(
            request: () async {
              final res = await option.request();
              return "${res}-o1";
            }
          );
        },
        onResponse: (option, data) async {
          return '${data}-r1';
        },
        onTransform: (response) async {
          return FutureResponse(
            data: "${response.data}-t1",
            requestOptions: response.requestOptions,
            error: response.error,
          );
        },
      ),
      InterceptorWrapper(
        onRequest: (option) {
          return option.copyWith(
              request: () async {
                final res = await option.request();
                return "${res}-o2";
              }
          );
        },
        onResponse: (option, data) async {
          return '${data}-r2';
        },
        onTransform: (response) async {
          return FutureResponse(
            data: "${response.data}-t2",
            requestOptions: response.requestOptions,
            error: response.error,
          );
        },
      ),
      InterceptorWrapper(
        onRequest: (option) {
          return option.copyWith(
              request: () async {
                final res = await option.request();
                return "${res}-o3";
              }
          );
        },
        onResponse: (option, data) async {
          return '${data}-r3';
        },
        onTransform: (response) async {
          return FutureResponse(
            data: "${response.data}-t3",
            requestOptions: response.requestOptions,
            error: response.error,
          );
        },
      ),
    ]);
    final res = await futureInterceptor.fetch(FutureRequestOptions(
      request: () async {
        return "test";
      },
    ));
    expect(res.data, "test-o1-o2-o3-r1-r2-r3-t1-t2-t3");
    expect(res.error, null);
  });

  test('Success', () async {
    const ret = "my result";
    final extra = <String, dynamic>{};
    final res = await futureInterceptor.fetch(FutureRequestOptions(
      request: () async {
        return ret;
      },
      extra: extra,
    ));
    expect(res.data, ret);
    expect(res.error, null);
    expect(res.requestOptions.extra, extra);
  });

  test('Throw Exception', () async {
    final extra = <String, dynamic>{};
    final exception = Exception("my Exception");
    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          throw exception;
        },
        extra: extra,
      ),
    );
    expect(res.data, null);
    expect(res.error?.error, exception);
    expect(res.requestOptions.extra, extra);
  });

  test('Throw FutureException', () async {
    final extra = <String, dynamic>{};
    final exception = FutureException();
    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          throw exception;
        },
        extra: extra,
      ),
    );
    expect(res.data, null);
    expect(res.error, exception);
    expect(res.requestOptions.extra, extra);
  });

  test('dynamic type', () async {
    final futureInterceptor = FutureInterceptor();
    futureInterceptor.interceptors.clear();
    final extra = {
      "key" : "",
    };
    futureInterceptor.interceptors.addAll([
      InterceptorWrapper(
        onRequest: (option) {
          return option.copyWith(
              request: () async {
                return 1;
              }
          );
        },
        onResponse: (option, data) async {
          return [1];
        },
        onTransform: (response) async {
          return FutureResponse(
            data: {
              'key': 1
            },
            requestOptions: response.requestOptions,
            error: response.error,
          );
        },
      ),
      InterceptorWrapper(
        onRequest: (option) {
          return option.copyWith(
              request: () async {
                return null;
              }
          );
        },
        onResponse: (option, data) async {
          return {
            'key': 2
          };
        },
        onTransform: (response) async {
          return FutureResponse(
            data: <int>{2, 3},
            requestOptions: response.requestOptions,
            error: response.error,
          );
        },
      ),
    ]);
    final res = await futureInterceptor.fetch(FutureRequestOptions(
      request: () async {
        return "tes";
      },
      extra: extra,
    ));
    expect(res.data, <int>{2, 3});
    expect(res.error, null);
  });

  test('test onRequest resolve', () async {
    futureInterceptor.interceptors.clear();
    FutureRequestOptions? _options;
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onRequest: (
          FutureRequestOptions options,
        ) {
          _options = options.copyWith(request: () async {
            return "123";
          });
          return _options!;
        },
      ),
    );

    final extra = <String, dynamic>{};
    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          throw Exception();
        },
        extra: extra,
      ),
    );
    expect(res.data, "123");
    expect(res.error, null);
    expect(res.requestOptions, _options);
  });

  test('test onRequest reject', () async {
    futureInterceptor.interceptors.clear();
    final exception = Exception("test");
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onRequest: (
          FutureRequestOptions options,
        ) {
          return options.copyWith(request: () async {
            throw exception;
          });
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          return "123";
        },
      ),
    );
    expect(res.data, null);
    expect(res.error != null, true);
    expect(res.error?.error, exception);
  });


  test('test onResponse modify data', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onResponse: (option, data) async {
          if (data is String) {
            return '${data}2';
          }
          return data;
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          return "1";
        },
      ),
    );
    expect(res.data, "12");
    expect(res.error, null);
  });

  test('test onResponse throw', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onResponse: (option, data) {
          throw Exception("test");
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          return "1";
        },
      ),
    );
    expect(res.data, "1");
    expect(res.error, null);
  });

  test('test onResponse return wrong type', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onResponse: (option, data) {
          return 2;
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          return "1";
        },
      ),
    );
    expect(res.data, null);
    expect(res.error != null, true);
  });

  test('test onResponse return wrong type', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onResponse: (option, data) {
          return 2;
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          return "1";
        },
      ),
    );
    expect(res.data, null);
    expect(res.error != null, true);
  });

  test('test onError modify error', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onError: (option, error) {
          return error.copyWith(
            error: "1",
            message: "test",
          );
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          throw Exception("");
        },
      ),
    );
    expect(res.data, null);
    expect(res.error?.error, "1");
    expect(res.error?.message, "test");
  });

  test('test onError throw', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onError: (option, error) async {
          throw Exception("1");
        },
      ),
    );

    final ex = Exception("test");
    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () async {
          throw ex;
        },
      ),
    );
    expect(res.data, null);
    expect(res.error?.error, ex);
  });

  test('test onTransform modify', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onTransform: (response) async {
          return FutureResponse(data: "1", requestOptions: response.requestOptions,);
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () {
          return "0";
        },
      ),
    );
    expect(res.data, "1");
    expect(res.error, null);
  });

  test('test onTransform throw', () async {
    futureInterceptor.interceptors.clear();
    futureInterceptor.interceptors.add(
      InterceptorWrapper(
        onTransform: (response) async {
          throw Exception("1");
        },
      ),
    );

    final res = await futureInterceptor.fetch(
      FutureRequestOptions(
        request: () {
          return "0";
        },
      ),
    );
    expect(res.data, "0");
    expect(res.error, null);
  });

}
