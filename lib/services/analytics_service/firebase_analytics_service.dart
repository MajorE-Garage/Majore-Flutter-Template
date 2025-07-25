import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../../core/domain/app_user.dart';
import 'analytics_service.dart';

class FirebaseAnalyticsService extends AnalyticsService {
  final FirebaseAnalytics firebaseAnalytics;

  FirebaseAnalyticsService({required this.firebaseAnalytics});

  @override
  FutureOr<void> logInUser(AppUser user) async {
    if (isRecording) {
      //? Login for Firebase Analytics
      firebaseAnalytics.setUserId(id: user.id);
      firebaseAnalytics.setUserProperty(name: 'email', value: user.email);
    }
  }

  @override
  FutureOr<void> logOutUser() async {
    if (isRecording) {
      //? Logout for Firebase Analytics
      firebaseAnalytics.resetAnalyticsData();
    }
  }

  @override
  FutureOr<void> logEvent(String name, {Map<String, Object>? properties}) async {
    if (!isRecording) return;
    /*  //? Log on MixPanel
    mixPanel.track(name, properties: properties); */
    //? Log on Firebase Analytics
    // Replaced all whitespace with '_' for firebase compatibility.
    final firebaseEventName = name.replaceAll(RegExp(r'\s\b|\b\s'), '_');
    firebaseAnalytics
        .logEvent(name: firebaseEventName, parameters: properties)
        .catchError((_) => null);
  }

  @override
  NavigatorObserver get navigatorObserver =>
      isRecording ? FirebaseAnalyticsObserver(analytics: firebaseAnalytics) : NavigatorObserver();

  @override
  Future<void> flushLogUpload() async {}
}
