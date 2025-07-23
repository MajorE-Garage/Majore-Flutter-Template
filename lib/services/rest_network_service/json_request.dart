// ignore_for_file: constant_identifier_names

const GET = 'GET';
const POST = 'POST';
const PATCH = 'PATCH';
const PUT = 'PUT';
const DELETE = 'DELETE';

class JsonRequest {
  final String endpoint;
  final bool useToken;
  final Map<String, dynamic> body;
  final Map<String, String>? queryParams;
  final String method;

  JsonRequest(
    this.method, {
    required this.endpoint,
    required this.body,
    required this.queryParams,
    this.useToken = true,
  });

  JsonRequest.get(
    this.endpoint, {
    this.queryParams,
    this.useToken = true,
  })  : body = const {},
        method = GET;

  JsonRequest.post(
    this.endpoint,
    this.body, {
    this.queryParams,
    this.useToken = true,
  }) : method = POST;

  JsonRequest.patch(
    this.endpoint,
    this.body, {
    this.queryParams,
    this.useToken = true,
  }) : method = PATCH;

  JsonRequest.put(
    this.endpoint,
    this.body, {
    this.queryParams,
    this.useToken = true,
  }) : method = PUT;

  JsonRequest.delete(
    this.endpoint,
    this.body, {
    this.queryParams,
    this.useToken = true,
  }) : method = DELETE;

  @override
  bool operator ==(other) =>
      other is JsonRequest &&
      endpoint == other.endpoint &&
      method == other.method;

  @override
  int get hashCode => endpoint.hashCode;
}
