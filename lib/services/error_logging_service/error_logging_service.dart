import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../core/domain/app_user.dart';
import 'crashlytics_service.dart';

class ErrorLogService {
  //? Supply the implementation to use for this service in the app here
  static final ErrorLogService instance = CrashlyticsService();

  ErrorLogService();

  late bool _isLogging;

  @protected
  bool get isLogging => _isLogging;

  @mustCallSuper
  void initialise({required bool shouldLog}) {
    _isLogging = shouldLog && kReleaseMode;

    // Connect framework errors
    FlutterError.onError = recordFlutterError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, fatal: true);
      return true;
    };

    // Connect severe log events
    Logger.root.onRecord.listen((event) {
      if (kDebugMode) debugPrint(event.message);
      if (event.level >= Level.SEVERE) {
        recordError(
          event.error,
          event.stackTrace,
          reason: event.message,
          information: [event.loggerName, event.time],
        );
      }
    });

    // Connect errors on main isolate
    if (!kIsWeb) {
      Isolate.current.addErrorListener(
        RawReceivePort((List<dynamic> pair) async => recordError(pair.first, pair.last)).sendPort,
      );
    }
  }

  FutureOr<void> connectUser(AppUser user) async {}
  FutureOr<void> disconnectUser() async {}

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {}

  Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {}
}
