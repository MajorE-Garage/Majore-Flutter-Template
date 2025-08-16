import 'package:flutter/material.dart';

import 'form_data_request.dart';
import 'json_request.dart';

export 'form_data_request.dart';
export 'json_request.dart';

/// Type alias for JSON data representation.
///
/// This is a convenient alias for Map<String, dynamic> used throughout
/// the network service for JSON request and response data.
typedef Json = Map<String, dynamic>;

/// Abstract base class for REST API network services.
///
/// This class provides a standardized interface for making HTTP requests to REST APIs.
/// It supports both JSON and multipart/form-data requests with built-in timeout handling,
/// environment-aware configuration, and comprehensive error handling.
///
/// Implementations of this class should handle the actual HTTP communication,
/// authentication, and error conversion. The class provides a clean abstraction
/// over different HTTP libraries (e.g., Dio, http) while maintaining consistent
/// behavior across the application.
///
/// Example implementation usage:
/// ```dart
/// final networkService = DioNetworkService(
///   baseUrl: 'https://api.example.com',
///   isProd: true,
///   sendTimeout: Duration(seconds: 30),
/// );
///
/// final response = await networkService.sendJsonRequest(
///   JsonRequest.get('/users')
/// );
/// ```
abstract class RestNetworkService {
  /// The base URL for all network requests.
  ///
  /// This URL is prepended to all endpoint paths in requests.
  /// It should include the protocol (http/https) and domain, 
  /// optionally with a path prefix for API versioning.
  @protected
  final String baseUrl;

  /// Whether the service is running in production mode.
  ///
  /// This flag can be used by implementations to enable/disable
  /// debugging features, logging levels, or development-only functionality.
  @protected
  final bool isProd;

  /// Timeout durations for network operations.
  ///
  /// [sendTimeout] specifies how long to wait when sending request data.
  /// [receiveTimeout] specifies how long to wait for response data.
  /// If receiveTimeout is not provided, it defaults to sendTimeout.
  @protected
  final Duration sendTimeout, receiveTimeout;

  /// Creates a new instance of [RestNetworkService].
  ///
  /// [baseUrl] The base URL for all network requests.
  /// [isProd] Whether the service is running in production mode.
  /// [sendTimeout] Timeout duration for sending requests.
  /// [receiveTimeout] Optional timeout duration for receiving responses.
  /// If not provided, defaults to [sendTimeout].
  RestNetworkService({
    required this.baseUrl,
    required this.isProd,
    required this.sendTimeout,
    Duration? receiveTimeout,
  }) : receiveTimeout = receiveTimeout ?? sendTimeout;

  /// Sends a JSON HTTP request with the specified [request].
  ///
  /// This method handles JSON-based API requests with automatic serialization
  /// and authentication. The request body is sent as JSON and the response
  /// is expected to be JSON format.
  ///
  /// [T] The expected type of the response data (for documentation purposes).
  /// [request] The JSON request object containing endpoint, method, body, and options.
  ///
  /// Returns a [Json] map containing the response data.
  ///
  /// Throws:
  /// - [NetworkException] if there are network connectivity issues
  /// - [TimeoutException] if the request times out
  /// - [ServerException] if the server returns an error status
  /// - [InputException] if there are validation or client-side errors
  ///
  /// Example usage:
  /// ```dart
  /// final response = await sendJsonRequest(
  ///   JsonRequest.post('/api/login', {'email': 'user@example.com'})
  /// );
  /// ```
  Future<Json> sendJsonRequest<T>(JsonRequest request);

  /// Sends a multipart/form-data HTTP request with the specified [request].
  ///
  /// This method handles file uploads and form data submissions using
  /// multipart encoding. It supports both file uploads and regular form fields
  /// in the same request.
  ///
  /// [T] The expected type of the response data (for documentation purposes).
  /// [request] The form data request object containing files, form fields, and options.
  ///
  /// Returns a [Json] map containing the response data.
  ///
  /// Throws:
  /// - [NetworkException] if there are network connectivity issues
  /// - [TimeoutException] if the request times out
  /// - [ServerException] if the server returns an error status
  /// - [InputException] if there are validation or client-side errors
  ///
  /// Example usage:
  /// ```dart
  /// final response = await sendFormDataRequest(
  ///   FormDataRequest.post('/api/upload', {'avatar': File('image.jpg')})
  /// );
  /// ```
  Future<Json> sendFormDataRequest<T>(FormDataRequest request);
}
