import 'dart:async';

import 'package:get_it/get_it.dart';

import 'feature_dependencies.dart';
import 'service_dependencies.dart';

abstract class ServiceLocator {
  final GetIt locator;
  ServiceLocator(this.locator);

  FutureOr<void> register();

  static final get = GetIt.instance;
  static Future<void> registerDependencies() async {
    final services = ServiceDependencies(get);
    final features = FeatureDependencies(get);

    services.register();
    features.register();
  }

  static Future<void> reset() async {
    await get.reset();
    await registerDependencies();
  }

  static void resetInstance<T extends Object>() {
    get.resetLazySingleton<T>();
  }
}
