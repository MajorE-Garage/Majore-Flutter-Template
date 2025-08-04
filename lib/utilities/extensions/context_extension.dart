import 'package:flutter/material.dart';

import '../../core/presentation/theming/app_theme_manager.dart';
import '../../l10n/generated/app_translations.dart';

extension BuildContextExtension on BuildContext {
  AppColors get colors => AppColors.of(this);
  AppStyles get styles => AppStyles.of(this);
  AppTranslations get translations => AppTranslations.of(this)!;
}
