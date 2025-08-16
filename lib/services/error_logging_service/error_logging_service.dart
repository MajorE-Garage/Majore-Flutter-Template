import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../core/domain/app_user.dart';
import 'crashlytics_service.dart';

/// Base class for error logging and crash reporting services.
///
/// This class provides a unified interface for error tracking and crash reporting
/// throughout the application. It automatically captures various types of errors:
/// - Flutter framework errors
/// - Uncaught asynchronous errors
/// - Severe logging events
/// - Main isolate errors (on non-web platforms)
///
/// The service integrates with the app's error handling infrastructure and
/// provides user context association for better error tracking and debugging.
/// It only logs errors in release mode to avoid noise during development.
///
/// The class follows a pattern where the concrete implementation is injected
/// through the singleton instance, allowing for easy testing and provider switching.
///
/// Example usage:
/// ```dart
/// // Initialize the service
/// ErrorLogService.instance.initialise(shouldLog: true);
///
/// // Connect user context
/// ErrorLogService.instance.connectUser(currentUser);
///
/// // Manual error recording
/// try {
///   riskyOperation();
/// } catch (e, stack) {
///   ErrorLogService.instance.recordError(e, stack, reason: 'Operation failed');
/// }
/// ```
class ErrorLogService {
  /// Singleton instance of the error logging service.
  ///
  /// The concrete implementation is defined here. In this case, it uses
  /// [CrashlyticsService] for Firebase Crashlytics integration, but this
  /// can be changed to use other error logging providers.
  static final ErrorLogService instance = CrashlyticsService();

  /// Creates a new instance of [ErrorLogService].
  ///
  /// This is the base constructor for error logging services. Concrete
  /// implementations should call this constructor and provide their
  /// specific error logging provider integration.
  ErrorLogService();

  /// Internal flag indicating whether error logging is enabled.
  late bool _isLogging;

  /// Whether the service is currently logging errors.
  ///
  /// This is typically true only in release mode to avoid polluting
  /// error logs with development-related issues. The value is set
  /// during [initialise].
  @protected
  bool get isLogging => _isLogging;

  /// Initializes the error logging service with automatic error capture.
  ///
  /// This method sets up comprehensive error handling throughout the application
  /// by connecting to various error sources in the Flutter framework and Dart runtime.
  /// It should be called during app initialization, typically in the main function.
  ///
  /// The method automatically configures:
  /// - Flutter framework error capture ([FlutterError.onError])
  /// - Uncaught asynchronous error capture ([PlatformDispatcher.instance.onError])
  /// - Severe logging event capture ([Logger.root.onRecord])
  /// - Main isolate error capture (non-web platforms only)
  ///
  /// Error logging is only enabled in release mode, even if [shouldLog] is true,
  /// to avoid capturing development-related errors and noise.
  ///
  /// Subclasses can override this method to add provider-specific initialization,
  /// but must call `super.initialise(shouldLog: shouldLog)` to maintain base functionality.
  ///
  /// [shouldLog] Whether to enable error logging. Automatically disabled in debug mode.
  ///
  /// Example usage:
  /// ```dart
  /// void main() {
  ///   ErrorLogService.instance.initialise(shouldLog: true);
  ///   runApp(MyApp());
  /// }
  /// ```
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

  /// Associates a user with error logs for better debugging context.
  ///
  /// This method connects user information to error reports, making it easier
  /// to track issues for specific users and understand the impact of errors.
  /// The user context will be included in all subsequent error reports until
  /// [disconnectUser] is called.
  ///
  /// Implementations should store user identification information (like user ID)
  /// and any relevant user properties that can help with debugging.
  ///
  /// [user] The user object containing identification and context information.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<void> connectUser(AppUser user) async {
  ///   if (!isLogging) return;
  ///   await crashlytics.setUserIdentifier(user.id);
  ///   await crashlytics.setCustomKey('user_email', user.email);
  /// }
  /// ```
  FutureOr<void> connectUser(AppUser user) async {}

  /// Disconnects the current user from error logs.
  ///
  /// This method clears user context from error reporting, typically called
  /// when a user logs out. After calling this method, subsequent error reports
  /// will not include user-specific information.
  ///
  /// Implementations should clear any stored user identification and context
  /// information from their error logging provider.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<void> disconnectUser() async {
  ///   if (!isLogging) return;
  ///   await crashlytics.setUserIdentifier('');
  /// }
  /// ```
  FutureOr<void> disconnectUser() async {}

  /// Records an error with optional context information.
  ///
  /// This is the primary method for manually logging errors throughout the
  /// application. It should be used in catch blocks and error handling code
  /// to ensure errors are properly tracked and reported.
  ///
  /// The method allows for rich context information to be attached to errors,
  /// making debugging and issue resolution more effective.
  ///
  /// [exception] The exception or error object that occurred.
  /// [stack] The stack trace associated with the error. Can be null.
  /// [reason] Optional human-readable description of what caused the error.
  /// [information] Additional context objects that might help with debugging.
  /// [fatal] Whether this error should be considered fatal (app-breaking).
  ///
  /// Example usage:
  /// ```dart
  /// try {
  ///   await riskyNetworkCall();
  /// } catch (e, stack) {
  ///   ErrorLogService.instance.recordError(
  ///     e,
  ///     stack,
  ///     reason: 'Failed to fetch user data',
  ///     information: ['userId: $userId', 'endpoint: /api/users'],
  ///     fatal: false,
  ///   );
  /// }
  /// ```
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {}

  /// Records Flutter framework errors.
  ///
  /// This method is automatically called when Flutter framework errors occur
  /// (through [FlutterError.onError] setup in [initialise]). It handles
  /// Flutter-specific error details and extracts relevant information for logging.
  ///
  /// Implementations should process [FlutterErrorDetails] and extract:
  /// - The exception and stack trace
  /// - Flutter-specific context information
  /// - Library and widget information
  ///
  /// [errorDetails] The Flutter error details containing exception, stack trace,
  /// and framework-specific context information.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {
  ///   if (!isLogging) return;
  ///   await crashlytics.recordFlutterError(errorDetails);
  /// }
  /// ```
  Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {}
}
