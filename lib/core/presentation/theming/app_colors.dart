import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color primary200;
  final Color backgroundColor;
  final Color overlayBackground;
  final Color textColor;
  final Color textAltColor;
  final Color grey900;
  final Color grey800;
  final Color grey700;
  final Color grey600;
  final Color grey500;
  final Color grey400;
  final Color grey300;
  final Color grey200;
  final Color grey100;
  final Color attitudeErrorLight;
  final Color attitudeErrorMain;
  final Color attitudeErrorDark;
  final Color attitudeSuccessLight;
  final Color attitudeSuccessMain;
  final Color attitudeSuccessDark;
  final Color attitudeWarningLight;
  final Color attitudeWarningMain;
  final Color attitudeWarningDark;
  final Color attitudeInfoLight;
  final Color attitudeInfoMain;
  final Color attitudeInfoDark;
  final Color brown300;
  final Color brown900;

  const AppColors({
    required this.primaryColor,
    required this.primary200,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.overlayBackground,
    required this.textColor,
    required this.textAltColor,
    required this.grey900,
    required this.grey800,
    required this.grey700,
    required this.grey600,
    required this.grey500,
    required this.grey400,
    required this.grey300,
    required this.grey200,
    required this.grey100,
    required this.attitudeErrorLight,
    required this.attitudeErrorMain,
    required this.attitudeErrorDark,
    required this.attitudeSuccessLight,
    required this.attitudeSuccessMain,
    required this.attitudeSuccessDark,
    required this.attitudeWarningLight,
    required this.attitudeWarningMain,
    required this.attitudeWarningDark,
    required this.attitudeInfoLight,
    required this.attitudeInfoMain,
    required this.attitudeInfoDark,
    required this.brown300,
    required this.brown900,
  });

  static AppColors of(BuildContext context) {
    final theme = Theme.of(context).extension<AppColors>();
    if (theme == null) {
      throw Exception('AppColors has not been added to app theme extensions');
    }
    return theme;
  }

  static const defaultColors = AppColors(
    primaryColor: Color(0xFF118B30),
    primary200: Color(0xFF9CCDA9),
    secondaryColor: Color(0xFFE2FAD9),
    backgroundColor: Color(0xFFFBFCFB),
    overlayBackground: Color(0xFFFBFCFB),
    textColor: Color(0xFF50555C),
    textAltColor: Color(0xFFFFFFFF),
    grey100: Color(0xFFF4F6F4),
    grey200: Color(0xFFF3F3F4),
    grey300: Color(0xFFF0F1F2),
    grey400: Color(0xFFE3E4E6),
    grey500: Color(0xFFD5D7DB),
    grey600: Color(0xFFBCC0C7),
    grey700: Color(0xFF8B97A7),
    grey800: Color(0xFF63748E),
    grey900: Color(0xFF50555C),
    attitudeErrorLight: Color(0xFFFCD2D2),
    attitudeErrorMain: Color(0xFFBF000B),
    attitudeErrorDark: Color(0xFF7C2C2D),
    attitudeSuccessLight: Color(0xFFCCECE4),
    attitudeSuccessMain: Color(0xFF118B30),
    attitudeSuccessDark: Color(0xFF00503D),
    attitudeWarningLight: Color(0xFFFFEDDC),
    attitudeWarningMain: Color(0xFFFFA552),
    attitudeWarningDark: Color(0xFF805229),
    attitudeInfoLight: Color(0xFFD6EBFF),
    attitudeInfoMain: Color(0xFF339DFF),
    attitudeInfoDark: Color(0xFF113455),
    brown300: Color(0xFFFFF5E9),
    brown900: Color(0xffa13a01),
  );

  @override
  AppColors copyWith({
    Color? primaryColor,
    Color? primary200,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? overlayBackground,
    Color? textColor,
    Color? textAltColor,
    Color? grey900,
    Color? grey800,
    Color? grey700,
    Color? grey600,
    Color? grey500,
    Color? grey400,
    Color? grey300,
    Color? grey200,
    Color? grey100,
    Color? attitudeErrorLight,
    Color? attitudeErrorMain,
    Color? attitudeErrorDark,
    Color? attitudeSuccessLight,
    Color? attitudeSuccessMain,
    Color? attitudeSuccessDark,
    Color? attitudeWarningLight,
    Color? attitudeWarningMain,
    Color? attitudeWarningDark,
    Color? attitudeInfoLight,
    Color? attitudeInfoMain,
    Color? attitudeInfoDark,
    Color? brown300,
    Color? brown900,
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      primary200: primary200 ?? this.primary200,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overlayBackground: overlayBackground ?? this.overlayBackground,
      textAltColor: textAltColor ?? this.textAltColor,
      textColor: textColor ?? this.textColor,
      grey900: grey900 ?? this.grey900,
      grey100: grey100 ?? this.grey100,
      grey200: grey200 ?? this.grey200,
      grey300: grey300 ?? this.grey300,
      grey400: grey400 ?? this.grey400,
      grey500: grey500 ?? this.grey500,
      grey600: grey600 ?? this.grey600,
      grey700: grey700 ?? this.grey700,
      grey800: grey800 ?? this.grey800,
      attitudeErrorLight: attitudeErrorLight ?? this.attitudeErrorLight,
      attitudeErrorMain: attitudeErrorMain ?? this.attitudeErrorMain,
      attitudeErrorDark: attitudeErrorDark ?? this.attitudeErrorDark,
      attitudeSuccessLight: attitudeSuccessLight ?? this.attitudeSuccessLight,
      attitudeSuccessMain: attitudeSuccessMain ?? this.attitudeSuccessMain,
      attitudeSuccessDark: attitudeSuccessDark ?? this.attitudeSuccessDark,
      attitudeWarningLight: attitudeWarningLight ?? this.attitudeWarningLight,
      attitudeWarningMain: attitudeWarningMain ?? this.attitudeWarningMain,
      attitudeWarningDark: attitudeWarningDark ?? this.attitudeWarningDark,
      attitudeInfoLight: attitudeInfoLight ?? this.attitudeInfoLight,
      attitudeInfoMain: attitudeInfoMain ?? this.attitudeInfoMain,
      attitudeInfoDark: attitudeInfoDark ?? this.attitudeInfoDark,
      brown300: brown300 ?? this.brown300,
      brown900: brown900 ?? this.brown900,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    return other ?? this;
  }
}
