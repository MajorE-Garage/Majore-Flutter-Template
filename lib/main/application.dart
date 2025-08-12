import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../core/service_locator/service_locator.dart';
import '../services/error_logging_service/error_logging_service.dart';
import '../core/presentation/navigation/app_router.dart';
import '../core/presentation/presentation.dart';
import '../services/app_lifecycle_service/app_lifecycle_service.dart';
import '../services/remote_config/remote_config_service.dart';
import '../utilities/mixins/custom_will_pop_scope_mixin.dart';
import 'environment_config.dart';

void mainApp(FirebaseOptions options) {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: options);
      await ServiceLocator.registerDependencies();
      await AppThemeManager.initialise();
      runApp(const ThisApplication());
    },
    (error, stack) {
      ErrorLogService.instance.recordError(error, stack, fatal: true);
    },
  );
}

class ThisApplication extends StatefulWidget {
  const ThisApplication({super.key});

  @override
  State<ThisApplication> createState() => _ThisApplicationState();
}

class _ThisApplicationState extends State<ThisApplication> with CustomWillPopScopeMixin {
  @override
  void initState() {
    AppLifecycleService.instance.initialise();
    RemoteConfigService.instance.initialise();
    super.initState();
  }

  @override
  void dispose() {
    AppLifecycleService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppView<AppThemeManager>(
      model: AppThemeManager(
        lightTheme: AppTheme(
          colors: AppColors.defaultColors,
          headingFontFamily: AppStyles.defaultHeadingFont,
          bodyFontFamily: AppStyles.defaultBodyFont,
          child: const SizedBox.shrink(),
        ),
        darkTheme: null,
      ),
      builder: (themeManager, _) => PopScope(
        canPop: false,
        onPopInvokedWithResult: onSecondBackPop,
        child: MaterialApp.router(
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: themeManager.themeMode,
          debugShowCheckedModeBanner: !EnvironmentConfig.isProd,
          title: EnvironmentConfig.appName,
          localizationsDelegates: AppTranslations.localizationsDelegates,
          supportedLocales: AppTranslations.supportedLocales,
          locale: const Locale('en', ''),
          routerConfig: AppRouter.router,
          builder: (context, widget) {
            if (kReleaseMode) {
              const errT = Text('A rendering error occured');
              ErrorWidget.builder = (errorDetails) {
                if (widget is Scaffold || widget is Navigator) {
                  return const Scaffold(body: Center(child: errT));
                } else {
                  return errT;
                }
              };
            }
            return widget ?? const Scaffold();
          },
        ),
      ),
    );
  }
}
