import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

/// A service that monitors app lifecycle states and notifies listeners.
///
/// This service extends [WidgetsBindingObserver] to track when the app
/// transitions between active and inactive states. It provides a simple
/// listener pattern for components that need to respond to app lifecycle
/// changes (e.g., pausing analytics uploads, saving data).
///
/// The service automatically handles:
/// - App resume events (when app becomes active)
/// - App pause events (when app becomes inactive, paused, detached, or hidden)
/// - Error handling for listener callbacks
/// - Duplicate listener prevention
///
/// Example usage:
/// ```dart
/// // Initialize the service
/// AppLifecycleService.instance.initialise();
///
/// // Add a listener
/// AppLifecycleService.instance.addListener((appIsPaused) {
///   if (appIsPaused) {
///     // App is going to background
///     saveCurrentState();
///   } else {
///     // App is returning to foreground
///     refreshData();
///   }
/// });
///
/// // Clean up when done
/// AppLifecycleService.instance.dispose();
/// ```
class AppLifecycleService extends WidgetsBindingObserver {
  /// Singleton instance of the app lifecycle service.
  ///
  /// Use this instance to add/remove listeners and manage the service lifecycle.
  static final AppLifecycleService instance = AppLifecycleService();

  /// Creates a new instance of [AppLifecycleService].
  ///
  /// This constructor is marked as [visibleForTesting] and should not be used
  /// directly. Use [AppLifecycleService.instance] instead.
  @visibleForTesting
  AppLifecycleService();

  /// Initializes the service and starts monitoring app lifecycle events.
  ///
  /// This method registers the service as a [WidgetsBindingObserver] to
  /// receive lifecycle callbacks. It should be called during app initialization,
  /// typically in the main widget's [initState] method.
  ///
  /// Must be paired with a call to [dispose] when the app is shutting down.
  void initialise() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Disposes the service and stops monitoring app lifecycle events.
  ///
  /// This method unregisters the service as a [WidgetsBindingObserver] to
  /// stop receiving lifecycle callbacks. It should be called during app
  /// cleanup, typically in the main widget's [dispose] method.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Internal list of listeners to be notified of lifecycle changes.
  final _listeners = <void Function(bool paused)>[];

  /// Adds a listener to be notified of app lifecycle changes.
  ///
  /// The listener function will be called whenever the app transitions
  /// between active and inactive states:
  /// - `listener(false)` is called when the app resumes (becomes active)
  /// - `listener(true)` is called when the app pauses (becomes inactive)
  ///
  /// If the listener is already registered, this method has no effect.
  /// Listener callbacks are automatically wrapped in error handling.
  ///
  /// [listener] The function to call on lifecycle changes.
  /// The boolean parameter indicates if the app is paused (true) or resumed (false).
  ///
  /// Example usage:
  /// ```dart
  /// AppLifecycleService.instance.addListener((appIsPaused) {
  ///   if (appIsPaused) {
  ///     // App is going to background - save data, pause operations
  ///     saveCurrentState();
  ///   } else {
  ///     // App is returning to foreground - resume operations
  ///     resumeOperations();
  ///   }
  /// });
  /// ```
  void addListener(void Function(bool appIsPaused) listener) {
    if (_listeners.contains(listener)) return;
    _listeners.add(listener);
  }

  /// Removes a previously added lifecycle listener.
  ///
  /// After calling this method, the specified listener will no longer
  /// receive app lifecycle notifications.
  ///
  /// [listener] The listener function to remove.
  void removeListener(void Function(bool appIsPaused) listener) {
    _listeners.remove(listener);
  }

  /// Called by the Flutter framework when the app lifecycle state changes.
  ///
  /// This method is protected and should not be called directly.
  /// It automatically maps Flutter's [AppLifecycleState] values to
  /// simple pause/resume notifications for listeners.
  ///
  /// State mapping:
  /// - [AppLifecycleState.resumed] → calls listeners with `false` (not paused)
  /// - [AppLifecycleState.inactive] → calls listeners with `true` (paused)
  /// - [AppLifecycleState.paused] → calls listeners with `true` (paused)
  /// - [AppLifecycleState.detached] → calls listeners with `true` (paused)
  /// - [AppLifecycleState.hidden] → calls listeners with `true` (paused)
  @protected
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resumeApp();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pauseApp();
        break;
    }
  }

  /// Internal flag to track the current pause state.
  ///
  /// This prevents duplicate notifications when the app lifecycle
  /// changes between different inactive states.
  bool _paused = false;

  /// Internal method called when the app resumes from background.
  ///
  /// This method notifies all listeners that the app has resumed
  /// (is no longer paused). It includes error handling to ensure
  /// that exceptions in one listener don't affect others.
  void _resumeApp() {
    if (!_paused) return;
    _paused = false;

    for (final listener in _listeners) {
      try {
        listener(false);
      } catch (e, t) {
        Logger(runtimeType.toString()).severe(e, t);
      }
    }
  }

  /// Internal method called when the app goes to background.
  ///
  /// This method notifies all listeners that the app has been paused
  /// (is going to background). It includes error handling to ensure
  /// that exceptions in one listener don't affect others.
  void _pauseApp() {
    if (_paused) return;
    _paused = true;

    for (final listener in _listeners) {
      try {
        listener(true);
      } catch (e, t) {
        Logger(runtimeType.toString()).severe(e, t);
      }
    }
  }
}
