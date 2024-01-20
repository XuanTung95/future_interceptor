
typedef RequestCallback = void Function();
typedef ResponseCallback = void Function();

class FutureListener {
  final RequestCallback? requestCallback;
  final ResponseCallback? responseCallback;

  FutureListener({this.requestCallback, this.responseCallback});
}