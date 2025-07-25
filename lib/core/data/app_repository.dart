import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../domain/app_responses.dart';
import '../domain/failure.dart';
import 'app_exceptions.dart';

export '../domain/app_responses.dart';
export '../domain/failure.dart';
export 'app_exceptions.dart';

/// A base class for implementing repository pattern in the data layer.
///
/// This abstract class provides a foundation for implementing repositories
/// that handle data operations with built-in error handling, logging, and
/// pagination support. It implements the Repository pattern from Clean Architecture,
/// providing a clean abstraction over data sources.
///
/// The class provides common functionality for:
/// - Error handling and exception conversion
/// - Logging of errors and operations
/// - Pagination query generation
/// - Guarded execution of data operations
///
/// Subclasses should implement specific data operations while leveraging
/// the provided error handling and logging infrastructure.
///
/// Example usage:
/// ```dart
/// class UserRepository extends AppRepository {
///   Future<DataResponse<List<User>>> getUsers(int page) {
///     return runDataWithGuard(() async {
///       // Implement data fetching logic
///       final users = await apiService.getUsers(page: page);
///       return DataResponse(data: users);
///     });
///   }
/// }
/// ```
abstract class AppRepository {
  /// Creates a new instance of [AppRepository].
  ///
  /// This constructor initializes the repository with default settings.
  /// Subclasses can override this constructor to add custom initialization
  /// logic if needed.
  AppRepository();

  /// The number of results to fetch per page for pagination.
  ///
  /// This value is used by [generatePaginationQuery] to create pagination
  /// parameters. Subclasses can override this value to customize the
  /// page size for their specific use cases.
  ///
  /// Default value is 15 items per page.
  @protected
  int resultsPerPage = 15;

  /// A logger instance for this repository.
  ///
  /// This getter provides a logger instance that uses the runtime type
  /// of the repository as the logger name. It's used for logging errors
  /// and debugging information throughout the repository operations.
  ///
  /// The logger is protected to allow subclasses to access it for
  /// custom logging needs.
  @protected
  Logger get logger => Logger(runtimeType.toString());

  /// Generates pagination query parameters for the specified page.
  ///
  /// This method creates a map of query parameters for pagination based on
  /// the current page number and the [resultsPerPage] value. It calculates
  /// the skip value (how many items to skip) and the limit value (how many
  /// items to fetch).
  ///
  /// The skip calculation uses the formula: `(page - 1) * resultsPerPage`
  /// to determine how many items to skip based on the page number.
  ///
  /// [page] The page number to generate parameters for (1-based indexing).
  ///
  /// Returns a map containing 'skip' and 'limit' parameters for API queries.
  ///
  /// Example:
  /// ```dart
  /// final params = generatePaginationQuery(2); // page 2
  /// // Returns: {'skip': '15', 'limit': '15'}
  /// ```
  @protected
  Map<String, String> generatePaginationQuery(int page) => {
    'skip': ((page - 1) * resultsPerPage).toString(),
    'limit': resultsPerPage.toString(),
  };

  /// Converts an exception to a corresponding [Failure] object.
  ///
  /// This method provides a centralized way to convert various types of
  /// exceptions to appropriate [Failure] objects that can be handled
  /// by the presentation layer. It handles different exception types:
  ///
  /// - [AppException]: Converts using the exception's [toFailure] method
  /// - [TimeoutException]: Converts to [TimeoutFailure]
  /// - Other exceptions: Converts to [UnknownFailure]
  ///
  /// This method is used by the guard methods ([runDataWithGuard] and
  /// [runStatusWithGuard]) to ensure consistent error handling across
  /// all repository operations.
  ///
  /// [e] The exception to convert.
  ///
  /// Returns a [Failure] object representing the exception.
  @protected
  Failure convertException(e) {
    if (e is AppException) {
      return e.toFailure();
    } else if (e is TimeoutException) {
      return TimeoutFailure();
    } else {
      return UnknownFailure();
    }
  }

  /// Executes a data operation with error handling and logging.
  ///
  /// This method provides a safe way to execute data operations by wrapping
  /// them in a try-catch block with comprehensive error handling. It ensures
  /// that all exceptions are properly converted to [Failure] objects and
  /// logged appropriately.
  ///
  /// The method handles different types of exceptions:
  /// - [AppException]: Logs the error (except for [NetworkException]) and converts to [Failure]
  /// - Other exceptions: Logs the error and converts to [UnknownFailure]
  ///
  /// This method is designed to be used by subclasses to wrap their data
  /// operations, ensuring consistent error handling across all repository
  /// implementations.
  ///
  /// [T] The type of data that the operation returns.
  /// [closure] The data operation to execute.
  ///
  /// Returns a [DataResponse] containing either the data or an error.
  ///
  /// Example usage:
  /// ```dart
  /// Future<DataResponse<List<User>>> getUsers() {
  ///   return runDataWithGuard(() async {
  ///     final users = await apiService.getUsers();
  ///     return DataResponse(data: users);
  ///   });
  /// }
  /// ```
  @protected
  Future<DataResponse<T>> runDataWithGuard<T>(FutureOr<DataResponse<T>> Function() closure) async {
    try {
      final d = await closure();
      return d;
    } on AppException catch (e, t) {
      if (e is! NetworkException) logger.severe(e.toFailure().message, e, t);
      return DataResponse<T>(data: null, error: convertException(e));
    } catch (e, t) {
      logger.severe(e, e, t);
      return DataResponse<T>(data: null, error: convertException(e));
    }
  }

  /// Executes a status operation with error handling and logging.
  ///
  /// This method provides a safe way to execute status operations (operations
  /// that don't return data but indicate success/failure) by wrapping them
  /// in a try-catch block with comprehensive error handling. It ensures that
  /// all exceptions are properly converted to [Failure] objects and logged
  /// appropriately.
  ///
  /// The method handles different types of exceptions:
  /// - [AppException]: Logs the error (except for [NetworkException]) and converts to [Failure]
  /// - Other exceptions: Logs the error and converts to [UnknownFailure]
  ///
  /// This method is designed to be used by subclasses to wrap their status
  /// operations (like create, update, delete operations), ensuring consistent
  /// error handling across all repository implementations.
  ///
  /// [closure] The status operation to execute.
  ///
  /// Returns a [StatusResponse] indicating success or failure.
  ///
  /// Example usage:
  /// ```dart
  /// Future<StatusResponse> createUser(User user) {
  ///   return runStatusWithGuard(() async {
  ///     await apiService.createUser(user);
  ///     return StatusResponse.successful();
  ///   });
  /// }
  /// ```
  @protected
  Future<StatusResponse> runStatusWithGuard(FutureOr<StatusResponse> Function() closure) async {
    try {
      final d = await closure();
      return d;
    } on AppException catch (e, t) {
      if (e is! NetworkException) logger.severe(e.toFailure().message, e, t);
      return StatusResponse.failed(convertException(e));
    } catch (e, t) {
      logger.severe(e, e, t);
      return StatusResponse.failed(convertException(e));
    }
  }
}
