import 'dart:async';

import '../domain/failure.dart';

abstract class AppException implements Exception {
  const AppException();
  Failure toFailure();

  @override
  String toString() {
    return '$runtimeType - ${toFailure().message}';
  }
}

extension AppExceptionExtension on TimeoutException {
  TimeoutFailure toFailure() => TimeoutFailure();
}

class ServerException implements AppException {
  final String? errorMessage;
  ServerException({this.errorMessage});
  @override
  ServerFailure toFailure() => ServerFailure(message: errorMessage);
}

class InputException implements AppException {
  final String? errorMessage;
  InputException({required this.errorMessage});
  @override
  InputFailure toFailure() => InputFailure(message: errorMessage);
}

class UnauthorisedException implements AppException {
  final String errorMessage;
  UnauthorisedException({this.errorMessage = ''});
  @override
  BadAuthFailure toFailure() => BadAuthFailure(message: errorMessage);
}

class NetworkException implements AppException {
  @override
  Failure toFailure() => NetworkFailure();
}

class UnknownException implements AppException {
  @override
  Failure toFailure() => UnknownFailure();
}
