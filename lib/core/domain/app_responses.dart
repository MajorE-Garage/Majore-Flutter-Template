import 'failure.dart';

class DataResponse<T> {
  T? data;
  Failure? error;

  bool get hasError => error != null;
  bool get isSuccessful => data != null;

  DataResponse({this.data, this.error})
      : assert((data != null) || (error != null),
            'Must have one of data or error');
}

class StatusResponse {
  Failure? error;

  bool get hasError => error != null;
  bool get isSuccessful => error == null;

  StatusResponse.failed(this.error);

  StatusResponse.successful() : error = null;
}
