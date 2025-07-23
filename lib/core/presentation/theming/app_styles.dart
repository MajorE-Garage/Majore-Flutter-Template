import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles extends ThemeExtension<AppStyles> {
  final AppColors colors;
  final String headingFontFamily;
  final String bodyFontFamily;

  static const defaultHeadingFont = 'Poppins';
  static const defaultBodyFont = 'Poppins';

  static AppStyles of(BuildContext context) {
    final theme = Theme.of(context).extension<AppStyles>();
    if (theme == null) {
      throw Exception('AppStyles has not been added to app theme extensions');
    }
    return theme;
  }

  final TextStyle heading20Regular;
  final TextStyle heading20Semibold;
  final TextStyle heading20Bold;

  final TextStyle body16Regular;
  final TextStyle body16Medium;
  final TextStyle body16SemiBold;
  final TextStyle body16Bold;

  final TextStyle subtitle15Regular;
  final TextStyle subtitle15Light;

  final TextStyle body14Regular;
  final TextStyle body14Medium;
  final TextStyle body14SemiBold;
  final TextStyle body14Bold;

  final TextStyle caption12Regular;
  final TextStyle overline10Regular;

  final TextStyle value16Medium;
  final TextStyle label14Regular;
  final TextStyle hint12Medium;

  AppStyles({
    required this.colors,
    required this.headingFontFamily,
    required this.bodyFontFamily,
  })  :
        // Headings
        heading20Regular = TextStyle(
          fontFamily: headingFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 20,
          height: 32 / 20,
          color: colors.textColor,
        ),
        heading20Semibold = TextStyle(
          fontFamily: headingFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 32 / 20,
          color: colors.textColor,
        ),
        heading20Bold = TextStyle(
          fontFamily: headingFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          height: 32 / 20,
          color: colors.textColor,
        ),
        // Body
        body16Regular = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 24 / 16,
          color: colors.textColor,
        ),
        body16Medium = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 24 / 16,
          color: colors.textColor,
        ),
        body16SemiBold = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 24 / 16,
          color: colors.textColor,
        ),
        body16Bold = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          height: 24 / 16,
          color: colors.textColor,
        ),
        body14Regular = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 20 / 14,
          color: colors.textColor,
        ),
        body14Medium = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 20 / 14,
          color: colors.textColor,
        ),
        body14SemiBold = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 20 / 14,
          color: colors.textColor,
        ),
        body14Bold = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          height: 20 / 14,
          color: colors.textColor,
        ),

        // Subtitle
        subtitle15Regular = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 20 / 15,
          color: colors.textColor,
        ),
        subtitle15Light = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w300,
          fontSize: 15,
          height: 20 / 15,
          color: colors.textColor,
        ),
        caption12Regular = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: colors.textColor,
        ),
        overline10Regular = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 10,
          color: colors.textColor,
        ),
        value16Medium = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 24 / 16,
          color: colors.textColor,
        ),
        label14Regular = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 20 / 14,
          color: colors.textColor,
        ),
        hint12Medium = TextStyle(
          fontFamily: bodyFontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 16 / 12,
          color: colors.textColor,
        );

  @override
  ThemeExtension<AppStyles> copyWith(
      {AppColors? colors, String? headingFontFamily, String? bodyFontFamily}) {
    return AppStyles(
      colors: colors ?? this.colors,
      headingFontFamily: headingFontFamily ?? this.headingFontFamily,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
    );
  }

  @override
  ThemeExtension<AppStyles> lerp(
      covariant ThemeExtension<AppStyles>? other, double t) {
    return other ?? this;
  }
}
