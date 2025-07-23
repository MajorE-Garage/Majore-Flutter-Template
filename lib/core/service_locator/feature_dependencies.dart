import 'dart:async';

import 'service_locator.dart';

class FeatureDependencies extends ServiceLocator {
  FeatureDependencies(super.locator);

  @override
  FutureOr<void> register() {}
}
