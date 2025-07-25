import 'package:flutter/material.dart';

import '../../../services/local_storage_service/local_storage_service.dart';
import '../../service_locator/service_locator.dart';
import '../presentation.dart';

export 'app_colors.dart';
export 'app_styles.dart';
export 'app_theme.dart';

class AppThemeManager extends AppViewModel {
  final AppTheme _lightTheme;
  final AppTheme? _darkTheme;

  AppThemeManager({required AppTheme lightTheme, required AppTheme? darkTheme})
    : _lightTheme = lightTheme,
      _darkTheme = darkTheme;

  ThemeData? get lightTheme => _lightTheme.data;
  ThemeData? get darkTheme => _darkTheme?.data;

  ThemeMode get themeMode {
    final mode = _themeMode;
    if (mode == null) {
      throw Exception('Tried accessing themeMode before initialise was called or finished');
    } else {
      return mode;
    }
  }

  static ThemeMode? _themeMode;

  static Future<void> initialise([
    ThemeMode defaultMode = ThemeMode.system,
    bool forceDefault = false,
  ]) async {
    if (forceDefault) {
      _themeMode = defaultMode;
    } else {
      final mode = await _getLastTheme(defaultMode);
      _themeMode = mode;
    }
    // setState();
  }

  static Future<ThemeMode> _getLastTheme(ThemeMode defaultMode) async {
    final localStore = ServiceLocator.get<LocalStorageService>();
    final name = await localStore.fetchString(LocalStoreKeys.THEME_MODE);
    final mode = ThemeMode.values.firstWhere(
      (element) => element.name == name,
      orElse: () => defaultMode,
    );
    return mode;
  }

  void changeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    if (mode == ThemeMode.dark && _darkTheme == null) return;
    _themeMode = mode;
    final localStore = ServiceLocator.get<LocalStorageService>();
    localStore.saveString(LocalStoreKeys.THEME_MODE, themeMode.name);
    setState();
  }
}
