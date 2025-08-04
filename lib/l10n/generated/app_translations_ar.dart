// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_translations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppTranslationsAr extends AppTranslations {
  AppTranslationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'قالب ماجور إم في إم';

  @override
  String get select => 'Select';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';
}
