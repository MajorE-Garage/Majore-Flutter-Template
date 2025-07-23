import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/domain/app_user.dart';
import '../../core/service_locator/service_locator.dart';
import '../app_lifecycle_service/app_lifecycle_service.dart';

abstract class AnalyticsService {
  static final AnalyticsService instance = ServiceLocator.get<AnalyticsService>();

  NavigatorObserver get navigatorObserver;

  bool _shouldRecord = false;
  bool _configured = false;

  bool get isRecording => _shouldRecord;
  bool get configured => _configured;

  @mustCallSuper
  Future<void> configure([bool shouldRecord = true]) async {
    _shouldRecord = shouldRecord && kReleaseMode;
    AppLifecycleService.instance.addListener((appIsPaused) {
      if (appIsPaused && isRecording && configured) flushLogUpload();
    });
    _configured = true;
  }

  FutureOr<void> logInUser(AppUser user);
  FutureOr<void> logOutUser();

  FutureOr<void> logEvent(String name, {Map<String, Object>? properties});

  Future<void> flushLogUpload();
}

class AnalyticsCombinatorService extends AnalyticsService {
  final List<AnalyticsService> _services;

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

class _CombinedlNavigatorObserver extends NavigatorObserver {
  final List<AnalyticsService> _services;

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
