import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme extends Theme {
  final AppColors colors;
  final AppStyles styles;

  factory AppTheme({
    required AppColors colors,
    required String headingFontFamily,
    required String bodyFontFamily,
    required Widget child,
  }) {
    final styles = AppStyles(
      colors: colors,
      headingFontFamily: headingFontFamily,
      bodyFontFamily: bodyFontFamily,
    );

    final theme = AppTheme.raw(colors: colors, styles: styles, child: child);
    return theme;
  }

  AppTheme.raw({
    super.key,
    required this.colors,
    required this.styles,
    required super.child,
  }) : super(
            data: ThemeData(
          fontFamily: styles.bodyFontFamily,
          scaffoldBackgroundColor: colors.backgroundColor,
          primaryColor: colors.primaryColor,
          appBarTheme: AppBarTheme(backgroundColor: colors.primaryColor),
          splashColor: colors.secondaryColor,
          extensions: [colors, styles],
          textTheme: TextTheme(
            bodySmall: styles.body14Regular,
            titleSmall: styles.body14Medium,
          ),
          canvasColor: colors.backgroundColor,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: colors.grey800,
            selectionColor: colors.secondaryColor,
            selectionHandleColor: colors.primaryColor,
          ),
          dividerTheme: DividerThemeData(
            color: colors.textColor.withOpacity(0.07),
            thickness: 1,
            space: 1,
          ),
          tabBarTheme: TabBarThemeData(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(64),
              color: colors.textAltColor,
            ),
            labelStyle: styles.body14Medium,
            unselectedLabelStyle: styles.body14Medium,
            unselectedLabelColor: colors.textColor,
            labelColor: colors.primaryColor,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: colors.backgroundColor,
            // elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          datePickerTheme: DatePickerThemeData(
            yearStyle: styles.body14Regular,
          ),
          colorScheme: ColorScheme(
            primary: colors.primaryColor,
            onPrimary: colors.backgroundColor,
            secondary: colors.primaryColor,
            onSecondary: colors.backgroundColor,
            surface: colors.backgroundColor,
            onSurface: colors.textColor,
            error: colors.attitudeErrorDark,
            onError: colors.attitudeErrorDark,
            brightness: Brightness.light,
          ),
          dialogBackgroundColor: colors.backgroundColor,
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: colors.backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
          ),
        ));

  static AppTheme of(BuildContext context) {
    final theme = context.findAncestorWidgetOfExactType<AppTheme>();
    if (theme == null) {
      throw Exception('AppColors has not been added to app theme extensions');
    }
    return theme;
  }
}
