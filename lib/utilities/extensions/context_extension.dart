import 'package:flutter/material.dart';

import '../../core/presentation/theming/app_theme_manager.dart';

extension BuildContextExtension on BuildContext {
  AppColors get colors => AppColors.of(this);
  AppStyles get styles => AppStyles.of(this);
}
