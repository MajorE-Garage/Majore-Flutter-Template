import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static final instance = AppLifecycleService();

  @visibleForTesting
  AppLifecycleService();

  void initialise() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  final _listeners = <void Function(bool paused)>[];

  void addListener(void Function(bool appIsPaused) listener) {
    if (_listeners.contains(listener)) return;
    _listeners.add(listener);
  }

  void removeListener(void Function(bool appIsPaused) listener) {
    _listeners.remove(listener);
  }

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

  bool _paused = false;

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
