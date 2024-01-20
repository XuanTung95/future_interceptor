import 'package:test/test.dart';

import 'package:future_interceptor/future_interceptor.dart';

void main() {
  late FutureInterceptor<String> futureInterceptor;

  setUp(() {
    futureInterceptor = FutureInterceptor<String>(errorPrinter: null);
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
        onResponse: (option, data) {
          return '${data}-r1';
        },
        onTransform: (response) {
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
        onResponse: (option, data) {
          return '${data}-r2';
        },
        onTransform: (response) {
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
        onResponse: (option, data) {
          return '${data}-r3';
        },
        onTransform: (response) {
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
        onTransform: (response) {
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
        onTransform: (response) {
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
        onResponse: (option, data) {
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
        onError: (option, error) {
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
        onTransform: (response) {
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
        onTransform: (response) {
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

  group('Record extension', () {
    test('RecordExtension with data', () async {
      futureInterceptor.interceptors.clear();
      final interceptor = RecordInterceptor();
      futureInterceptor.interceptors.add(
          interceptor
      );

      final res = await futureInterceptor.fetch(
        FutureRequestOptions(
          request: () {
            return "0";
          },
        ),
      );
      expect(interceptor.record, null);
      expect(interceptor.actual.length, 3);
      expect(interceptor.actual[0], null);
      expect(interceptor.actual[1], interceptor.records[0]);
      expect(interceptor.actual[2], interceptor.records[1]);
      expect(res.error, null);
    });

    test('RecordExtension with error', () async {
      futureInterceptor.interceptors.clear();
      final interceptor = RecordInterceptor();
      final interceptor2 = RecordInterceptor();
      futureInterceptor.interceptors.addAll([
          interceptor,
          RecordInterceptor(),
          interceptor2,
          RecordInterceptor(),
        ]
      );

      final res = await futureInterceptor.fetch(
        FutureRequestOptions(
          request: () {
            throw Exception();
          },
        ),
      );
      expect(interceptor.record, null);
      expect(interceptor.actual.length, 3);
      expect(interceptor.actual[0], null);
      expect(interceptor.actual[1], interceptor.records[0]);
      expect(interceptor.actual[2], interceptor.records[3]);

      expect(interceptor2.record, null);
      expect(interceptor2.actual.length, 3);
      expect(interceptor2.actual[0], null);
      expect(interceptor2.actual[1], interceptor2.records[0]);
      expect(interceptor2.actual[2], interceptor2.records[3]);
      expect(res.error != null, true);
    });
  });

  group('Listener', () {
    test('Listener test', () async {
      int count = 0;
      futureInterceptor.interceptors.clear();
      futureInterceptor.interceptors.addAll([
          InterceptorWrapper(
            onRequest: (options) {
              count = 1;
              return options;
            },
            onResponse: (options, data) {
              count = 2;
              return data;
            },
            onError: (options, error) {
              count = 3;
              return error;
            },
            onTransform: (res) {
              count = 4;
              return res;
            }
          ),
          InterceptorWrapper(
              onRequest: (options) {
                count = 5;
                return options;
              },
              onResponse: (options, data) {
                count = 6;
                return data;
              },
              onError: (options, error) {
                count = 7;
                return error;
              },
              onTransform: (res) {
                count = 8;
                return res;
              }
          ),
      ]);
      int request = 0;
      int response = 0;
      futureInterceptor.addListener(FutureListener(
        requestCallback: () {
          request = count;
        },
        responseCallback: () {
          response = count;
        }
      ));

      await futureInterceptor.fetch(
        FutureRequestOptions(
          request: () {
            count = 9;
            return "0";
          },
        ),
      );
      expect(request, 5);
      expect(response, 8);
      request = 0;
      response = 0;
      await futureInterceptor.fetch(
        FutureRequestOptions(
          request: () {
            count = 9;
            throw Exception();
          },
        ),
      );
      expect(request, 5);
      expect(response, 8);
    });
  });
}

class RecordInterceptor extends Interceptor with RecordExtension {

  List<Object> records = [Object(), Object(), Object(), Object()];
  List<dynamic> actual = [];

  @override
  InterceptorRequestCallback get onRequest => (option) {
    actual.add(record);
    setRecord(records[0]);
    return option;
  };

  @override
  InterceptorDataCallback get onResponse => (option, data) {
    actual.add(record);
    setRecord(records[1]);
    return data;
  };

  @override
  InterceptorTransformCallback get onTransform => (response) {
    actual.add(record);
    setRecord(records[2]);
    return response;
  };

  @override
  InterceptorErrorCallback get onError => (options, error) {
    actual.add(record);
    setRecord(records[3]);
    return error;
  };
}
