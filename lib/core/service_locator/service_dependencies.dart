import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../main/environment_config.dart';
import '../../services/analytics_service/analytics_service.dart';
import '../../services/analytics_service/firebase_analytics_service.dart';
import '../../services/build_info_service/build_info_service.dart';
import '../../services/error_logging_service/error_logging_service.dart';
import '../../services/local_storage_service/flutter_secure_local_storage_service.dart';
import '../../services/local_storage_service/local_storage_service.dart';
import '../../services/rest_network_service/dio_network_service.dart';
import '../../services/rest_network_service/rest_network_service.dart';
import '../../utilities/constants/constants.dart';
import '../domain/app_view_model.dart';
import '../domain/session_manager.dart';
import '../presentation/ui_components/overlays/app_toast_widget.dart';
import 'service_locator.dart';

class ServiceDependencies extends ServiceLocator {
  ServiceDependencies(super.locator);

  @override
  FutureOr<void> register() {
    locator.registerLazySingleton(
      () => SessionManager(
        localStorageService: locator(),
        errorLogService: ErrorLogService.instance,
        analyticsService: locator(),
      ),
    );

    locator.registerLazySingleton<MessageDisplayHandler>(() => ToastErrorHandler());

    locator.registerFactory<LocalStorageService>(
      () => FlutterSecureLocalStorage(flutterSecureStorage: const FlutterSecureStorage()),
    );

    locator.registerLazySingleton<RestNetworkService>(
      () => DioNetworkService(
        sessionManager: locator(),
        baseUrl: EnvironmentConfig.apiUrl,
        sendTimeout: Constants.networkTimeoutDuration,
        isProd: EnvironmentConfig.isProd,
      ),
    );

    locator.registerLazySingleton<AnalyticsService>(() {
      final service = AnalyticsCombinatorService([
        FirebaseAnalyticsService(firebaseAnalytics: FirebaseAnalytics.instance),
      ]);
      service.configure(EnvironmentConfig.isProd);
      return service;
    });

    locator.registerLazySingleton<BuildInfoService>(
      () => BuildInfoServiceImpl(deviceInfoPlugin: DeviceInfoPlugin()),
    );
  }
}
