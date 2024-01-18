/// RecordExtension is used to store an unique data for each request.
///
/// Unlike FutureRequestOptions, a record cannot be modified by other Interceptors.
/// A record is not shared between requests.
mixin RecordExtension {
  dynamic _record;
  dynamic get record => _record;

  void setRecord(dynamic record) {
    _record = record;
  }
}