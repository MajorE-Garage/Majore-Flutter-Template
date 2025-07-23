abstract class Failure {
  final String message;

  Failure(this.message);
}

/// Represents a failure that occurred on the server side of the application,
/// typically resulting in a status code of 500 or above being returned by an API.
class ServerFailure extends Failure {
  ServerFailure({String? message}) : super(message ?? 'An error occurred');
}

/// Represents a failure that occurred due to invalid input or a failed request
/// from the user.
class InputFailure extends Failure {
  InputFailure({required String? message})
      : super(message ?? 'Something went wrong');
}

/// Represents a failure that occurred due to bad or expired authentication
/// credentials, or a lack of access to a resource.
class BadAuthFailure extends Failure {
  BadAuthFailure({required String? message})
      : super(message ?? 'Please sign in again');
}

/// Represents a failure that occurred due to an issue with the user's network
/// connection.
class NetworkFailure implements Failure {
  @override
  String get message => 'Please check your internet connection';
}

/// Represents a failure that occurred due to a request timeout.
class TimeoutFailure extends Failure {
  TimeoutFailure({String? message})
      : super(message ??= 'Request timed out. Please try again.');
}

/// Represents an unknown failure that occurred within the application.
class UnknownFailure implements Failure {
  @override
  String get message => 'Something went wrong. Please try again.';
}
