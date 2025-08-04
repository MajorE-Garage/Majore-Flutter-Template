import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_translations.dart';

class LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLanguageChanged;

  const LanguageSelector({super.key, required this.currentLocale, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: currentLocale,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          onLanguageChanged(newLocale);
        }
      },
      items: AppTranslations.supportedLocales.map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(_getLanguageName(locale.languageCode)),
        );
      }).toList(),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'sw':
        return 'Kiswahili';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }
}
