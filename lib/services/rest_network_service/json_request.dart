// ignore_for_file: constant_identifier_names

/// HTTP GET method constant.
const GET = 'GET';

/// HTTP POST method constant.
const POST = 'POST';

/// HTTP PATCH method constant.
const PATCH = 'PATCH';

/// HTTP PUT method constant.
const PUT = 'PUT';

/// HTTP DELETE method constant.
const DELETE = 'DELETE';

/// Represents a JSON HTTP request with all necessary parameters.
///
/// This class encapsulates all the information needed to make a JSON-based
/// HTTP request, including the endpoint, HTTP method, request body, query
/// parameters, and authentication requirements.
///
/// The class provides convenient constructor methods for each HTTP method
/// type, making it easy to create requests with proper default values.
/// All requests default to requiring authentication unless explicitly disabled.
///
/// Example usage:
/// ```dart
/// // GET request
/// final getRequest = JsonRequest.get('/api/users');
///
/// // POST request with body
/// final postRequest = JsonRequest.post('/api/users', {
///   'name': 'John Doe',
///   'email': 'john@example.com'
/// });
///
/// // Request without authentication
/// final publicRequest = JsonRequest.get('/api/public', useToken: false);
/// ```
class JsonRequest {
  /// The API endpoint path for the request.
  ///
  /// This should be a relative path that will be appended to the base URL
  /// configured in the network service. It should start with a forward slash.
  final String endpoint;

  /// Whether to include authentication token in headers.
  ///
  /// When true, the network service will include the current user's
  /// authentication token in the request headers. Set to false for
  /// public endpoints that don't require authentication.
  final bool useToken;

  /// The request body data as a map.
  ///
  /// For GET requests, this is typically empty. For POST, PUT, PATCH, and
  /// DELETE requests, this contains the data to be sent in the request body.
  /// The data will be JSON-encoded by the network service.
  final Map<String, dynamic> body;

  /// Optional query parameters for the request.
  ///
  /// These parameters will be appended to the URL as query string parameters.
  /// Useful for filtering, pagination, sorting, and other URL-based parameters.
  final Map<String, String>? queryParams;

  /// The HTTP method for the request.
  ///
  /// This should be one of the standard HTTP methods: GET, POST, PATCH, PUT, DELETE.
  /// Use the provided constants (GET, POST, etc.) for consistency.
  final String method;

  /// Creates a new [JsonRequest] with the specified parameters.
  ///
  /// This is the base constructor that allows you to specify all parameters
  /// manually. For convenience, use the named constructors for specific HTTP methods.
  ///
  /// [method] The HTTP method (GET, POST, PATCH, PUT, DELETE).
  /// [endpoint] The API endpoint path.
  /// [body] The request body data.
  /// [queryParams] Optional query parameters.
  /// [useToken] Whether to include authentication token (defaults to true).
  JsonRequest(
    this.method, {
    required this.endpoint,
    required this.body,
    required this.queryParams,
    this.useToken = true,
  });

  /// Creates a GET request.
  ///
  /// GET requests typically don't have a body and are used for retrieving data.
  ///
  /// [endpoint] The API endpoint path.
  /// [queryParams] Optional query parameters for filtering or pagination.
  /// [useToken] Whether to include authentication token (defaults to true).
  JsonRequest.get(this.endpoint, {this.queryParams, this.useToken = true})
    : body = const {},
      method = GET;

  /// Creates a POST request.
  ///
  /// POST requests are typically used for creating new resources.
  ///
  /// [endpoint] The API endpoint path.
  /// [body] The request body data containing the resource to create.
  /// [queryParams] Optional query parameters.
  /// [useToken] Whether to include authentication token (defaults to true).
  JsonRequest.post(this.endpoint, this.body, {this.queryParams, this.useToken = true})
    : method = POST;

  /// Creates a PATCH request.
  ///
  /// PATCH requests are typically used for partial updates of existing resources.
  ///
  /// [endpoint] The API endpoint path.
  /// [body] The request body data containing the fields to update.
  /// [queryParams] Optional query parameters.
  /// [useToken] Whether to include authentication token (defaults to true).
  JsonRequest.patch(this.endpoint, this.body, {this.queryParams, this.useToken = true})
    : method = PATCH;

  /// Creates a PUT request.
  ///
  /// PUT requests are typically used for complete replacement of existing resources.
  ///
  /// [endpoint] The API endpoint path.
  /// [body] The request body data containing the complete resource.
  /// [queryParams] Optional query parameters.
  /// [useToken] Whether to include authentication token (defaults to true).
  JsonRequest.put(this.endpoint, this.body, {this.queryParams, this.useToken = true})
    : method = PUT;

  /// Creates a DELETE request.
  ///
  /// DELETE requests are used for removing resources.
  ///
  /// [endpoint] The API endpoint path.
  /// [body] The request body data (may be empty for simple deletes).
  /// [queryParams] Optional query parameters.
  /// [useToken] Whether to include authentication token (defaults to true).
  JsonRequest.delete(this.endpoint, this.body, {this.queryParams, this.useToken = true})
    : method = DELETE;

  /// Checks equality between two [JsonRequest] objects.
  ///
  /// Two requests are considered equal if they have the same endpoint and method.
  /// This is useful for caching and deduplication purposes.
  @override
  bool operator ==(other) =>
      other is JsonRequest && endpoint == other.endpoint && method == other.method;

  /// Returns the hash code for this [JsonRequest].
  ///
  /// The hash code is based on the endpoint to ensure consistent hashing
  /// for requests that are considered equal.
  @override
  int get hashCode => endpoint.hashCode;
}
