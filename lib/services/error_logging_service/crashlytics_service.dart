import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../core/domain/app_user.dart';
import 'error_logging_service.dart';

class CrashlyticsService extends ErrorLogService {
  @override
  void initialise({required bool shouldLog}) {
    super.initialise(shouldLog: shouldLog);
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(isLogging);
  }

  @override
  Future<void> recordError(
    exception,
    StackTrace? stack, {
    reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      information: information,
      printDetails: !isLogging,
      fatal: fatal,
    );
  }

  @override
  Future<void> connectUser(AppUser user) {
    return FirebaseCrashlytics.instance.setUserIdentifier(user.id);
  }

  @override
  FutureOr<void> disconnectUser() {
    return FirebaseCrashlytics.instance.setUserIdentifier('');
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails errorDetails) =>
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
}
