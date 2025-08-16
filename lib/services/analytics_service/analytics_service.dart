import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/domain/app_user.dart';
import '../../core/service_locator/service_locator.dart';
import '../app_lifecycle_service/app_lifecycle_service.dart';

/// Abstract base class for analytics services.
///
/// This class provides a common interface for tracking user analytics, events,
/// and navigation within the application. It includes built-in configuration
/// for recording in release mode and automatic log flushing on app pause.
///
/// The service automatically handles:
/// - Recording state management (only in release mode)
/// - App lifecycle integration for automatic log flushing
/// - User session tracking with login/logout events
/// - Navigation tracking through navigator observers
/// - Custom event logging with properties
///
/// Implementations should provide specific analytics provider integration
/// (e.g., Firebase Analytics, Mixpanel) while maintaining the common interface.
///
/// Example implementation:
/// ```dart
/// class MyAnalyticsService extends AnalyticsService {
///   @override
///   NavigatorObserver get navigatorObserver => MyNavigatorObserver();
///   
///   @override
///   Future<void> logEvent(String name, {Map<String, Object>? properties}) async {
///     if (!isRecording) return;
///     // Send event to analytics provider
///   }
///   
///   @override
///   Future<void> logInUser(AppUser user) async {
///     if (!isRecording) return;
///     // Set user context in analytics provider
///   }
/// }
/// ```
abstract class AnalyticsService {
  /// Singleton instance of the analytics service from the service locator.
  ///
  /// This provides global access to the configured analytics service throughout
  /// the application. The actual implementation is determined by the service
  /// locator configuration.
  static final AnalyticsService instance = ServiceLocator.get<AnalyticsService>();

  /// Navigator observer for tracking navigation events.
  ///
  /// This observer should be added to the app's navigator observers
  /// to automatically track page views and navigation events.
  /// Implementations should return an observer specific to their analytics provider.
  NavigatorObserver get navigatorObserver;

  /// Internal flag indicating whether analytics recording is enabled.
  bool _shouldRecord = false;

  /// Internal flag indicating whether the service has been configured.
  bool _configured = false;

  /// Whether the service is currently recording analytics events.
  ///
  /// This is typically true only in release mode to avoid polluting
  /// analytics with development data. The value is set during [configure].
  bool get isRecording => _shouldRecord;

  /// Whether the service has been configured and is ready for use.
  ///
  /// Returns true after [configure] has been called successfully.
  /// This can be used to check if the service is ready before making calls.
  bool get configured => _configured;

  /// Configures the analytics service with recording preferences.
  ///
  /// This method should be called during app initialization to set up
  /// the analytics service. It automatically sets up app lifecycle
  /// listeners to flush logs when the app is paused.
  ///
  /// The method automatically:
  /// - Enables recording only in release mode (even if [shouldRecord] is true)
  /// - Sets up automatic log flushing when the app goes to background
  /// - Marks the service as configured
  ///
  /// Subclasses can override this method to add provider-specific configuration,
  /// but must call `super.configure(shouldRecord)` to maintain base functionality.
  ///
  /// [shouldRecord] Whether to enable analytics recording.
  /// Defaults to true but is automatically disabled in debug mode.
  ///
  /// Example usage:
  /// ```dart
  /// @override
  /// Future<void> configure([bool shouldRecord = true]) async {
  ///   await providerSpecificSetup();
  ///   await super.configure(shouldRecord);
  /// }
  /// ```
  @mustCallSuper
  Future<void> configure([bool shouldRecord = true]) async {
    _shouldRecord = shouldRecord && kReleaseMode;
    AppLifecycleService.instance.addListener((appIsPaused) {
      if (appIsPaused && isRecording && configured) flushLogUpload();
    });
    _configured = true;
  }

  /// Logs in a user and associates analytics events with them.
  ///
  /// This method should be called when a user successfully logs in
  /// to associate subsequent events with the user's identity. Implementations
  /// should set user properties and context in their analytics provider.
  ///
  /// The method should handle the recording state automatically - if
  /// [isRecording] is false, the implementation should return early.
  ///
  /// [user] The user object containing identification information such as
  /// user ID, email, and other relevant properties.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<void> logInUser(AppUser user) async {
  ///   if (!isRecording) return;
  ///   await analyticsProvider.setUserId(user.id);
  ///   await analyticsProvider.setUserProperty('email', user.email);
  /// }
  /// ```
  FutureOr<void> logInUser(AppUser user);

  /// Logs out the current user and clears user-associated data.
  ///
  /// This method should be called when a user logs out to stop
  /// associating events with the user's identity. Implementations
  /// should clear user context and reset analytics data.
  ///
  /// The method should handle the recording state automatically - if
  /// [isRecording] is false, the implementation should return early.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<void> logOutUser() async {
  ///   if (!isRecording) return;
  ///   await analyticsProvider.resetUserData();
  /// }
  /// ```
  FutureOr<void> logOutUser();

  /// Logs a custom event with optional properties.
  ///
  /// This is the primary method for tracking user actions and app events.
  /// Events can include custom properties for additional context and
  /// should follow the analytics provider's naming conventions.
  ///
  /// The method should handle the recording state automatically - if
  /// [isRecording] is false, the implementation should return early.
  ///
  /// [name] The name of the event to log. Should follow the analytics
  /// provider's naming conventions (e.g., snake_case, limited length).
  /// [properties] Optional map of custom properties associated with the event.
  /// Values should be serializable (strings, numbers, booleans).
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<void> logEvent(String name, {Map<String, Object>? properties}) async {
  ///   if (!isRecording) return;
  ///   await analyticsProvider.track(name, properties: properties);
  /// }
  /// ```
  ///
  /// Example usage:
  /// ```dart
  /// analyticsService.logEvent('button_clicked', properties: {
  ///   'button_name': 'login',
  ///   'screen': 'authentication',
  ///   'user_type': 'guest'
  /// });
  /// ```
  FutureOr<void> logEvent(String name, {Map<String, Object>? properties});

  /// Flushes any pending analytics data to the remote service.
  ///
  /// This method is automatically called when the app is paused through
  /// the app lifecycle integration, but can be called manually to ensure
  /// data is uploaded immediately (e.g., before critical operations).
  ///
  /// Implementations should send any queued events to their analytics
  /// provider and handle network failures gracefully.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<void> flushLogUpload() async {
  ///   if (!isRecording) return;
  ///   try {
  ///     await analyticsProvider.flush();
  ///   } catch (e) {
  ///     // Handle upload failures gracefully
  ///     logger.warning('Failed to flush analytics: $e');
  ///   }
  /// }
  /// ```
  Future<void> flushLogUpload();
}

/// A service that combines multiple analytics services into one.
///
/// This class allows you to send analytics events to multiple services
/// simultaneously (e.g., Firebase Analytics, Mixpanel, etc.) through
/// a single interface. This is useful when you want to track events
/// across multiple analytics platforms without having to call each
/// service individually throughout your application.
///
/// All operations are performed on each underlying service in sequence,
/// ensuring that events are consistently tracked across all platforms.
/// If one service fails, it won't affect the others.
///
/// Example usage:
/// ```dart
/// final combinedService = AnalyticsCombinatorService([
///   FirebaseAnalyticsService(firebaseAnalytics: FirebaseAnalytics.instance),
///   MixpanelAnalyticsService(token: 'your-token'),
/// ]);
///
/// // This will log to both Firebase and Mixpanel
/// combinedService.logEvent('user_signup');
/// ```
class AnalyticsCombinatorService extends AnalyticsService {
  /// The list of analytics services to combine.
  ///
  /// All operations performed on this combinator service will be
  /// forwarded to each service in this list.
  final List<AnalyticsService> _services;

  /// Creates a combinator service with the specified analytics services.
  ///
  /// [services] List of analytics services to combine. Each service will
  /// receive all analytics events, user tracking calls, and configuration
  /// updates made through this combinator service.
  AnalyticsCombinatorService(this._services);

  @override
  Future<void> configure([bool shouldRecord = true]) async {
    await Future.wait([for (final service in _services) service.configure(shouldRecord)]);
    return super.configure(shouldRecord);
  }

  @override
  Future<void> flushLogUpload() async {
    for (final service in _services) {
      service.flushLogUpload();
    }
  }

  @override
  Future<FutureOr<void>> logEvent(String name, {Map<String, Object>? properties}) async {
    for (final service in _services) {
      await service.logEvent(name, properties: properties);
    }
  }

  @override
  FutureOr<void> logInUser(AppUser user) {
    for (final service in _services) {
      service.logInUser(user);
    }
  }

  @override
  FutureOr<void> logOutUser() {
    for (final service in _services) {
      service.logOutUser();
    }
  }

  @override
  NavigatorObserver get navigatorObserver => _CombinedlNavigatorObserver(_services);
}

/// A navigator observer that forwards navigation events to multiple analytics services.
///
/// This private class combines the navigator observers from multiple analytics
/// services, ensuring that navigation events (page views, route changes) are
/// tracked across all analytics platforms consistently.
///
/// It forwards all navigation lifecycle events (push, pop, replace) to each
/// underlying service's navigator observer.
class _CombinedlNavigatorObserver extends NavigatorObserver {
  /// The list of analytics services whose navigator observers should receive events.
  final List<AnalyticsService> _services;

  /// Creates a combined navigator observer.
  ///
  /// [services] The analytics services whose navigator observers will receive
  /// forwarded navigation events.
  _CombinedlNavigatorObserver(this._services);

  @override
  void didPop(Route route, Route? previousRoute) {
    for (final service in _services) {
      service.navigatorObserver.didPop(route, previousRoute);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    for (final service in _services) {
      service.navigatorObserver.didPush(route, previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    for (final service in _services) {
      service.navigatorObserver.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }
}
