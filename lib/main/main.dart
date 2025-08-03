import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/presentation/theming/app_theme_manager.dart';
import '../core/service_locator/service_locator.dart';
import '../services/error_logging_service/error_logging_service.dart';
import 'application.dart';
import 'environment_config.dart';
import 'firebase_options_prod.dart' as prod;
import 'firebase_options_staging.dart' as staging;

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      Firebase.initializeApp(
        options: EnvironmentConfig.isProd
            ? prod.DefaultFirebaseOptions.currentPlatform
            : staging.DefaultFirebaseOptions.currentPlatform,
      );
      await ServiceLocator.registerDependencies();
      await AppThemeManager.initialise();
      runApp(const ThisApplication());
    },
    (error, stack) {
      ErrorLogService.instance.recordError(error, stack, fatal: true);
    },
  );
}
