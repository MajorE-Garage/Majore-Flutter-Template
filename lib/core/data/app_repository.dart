import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../domain/app_responses.dart';
import '../domain/failure.dart';
import 'app_exceptions.dart';

export '../domain/app_responses.dart';
export '../domain/failure.dart';
export 'app_exceptions.dart';

abstract class AppRepository {
  /// Creates a new instance of [AppRepository].
  AppRepository();

  @protected
  int resultsPerPage = 15;

  @protected
  Logger get logger => Logger(runtimeType.toString());

  @protected
  Map<String, String> generatePaginationQuery(int page) => {
    'skip': ((page - 1) * resultsPerPage).toString(),
    'limit': resultsPerPage.toString(),
  };

  /// Converts an exception [e] to a corresponding [Failure].
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
