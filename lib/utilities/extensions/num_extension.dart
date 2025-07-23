import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';

extension NumExtension on num {
  String formatAsCurrency() {
    return NumberFormat.currency(symbol: Constants.currencySymbol).format(this);
  }

  TextSpan spanAsCurrency({TextStyle? style}) {
    return TextSpan(
      text: '${Constants.currencySymbol} ',
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: style?.fontSize,
        fontWeight: style?.fontWeight,
        color: style?.color,
      ),
      children: [
        TextSpan(
          text: NumberFormat.currency(symbol: '').format(this),
          style: style,
        )
      ],
    );
  }

  double ceilToDecimalPlaces(int decimals) {
    final adjuster = math.pow(10, decimals);
    final adjusted = this * adjuster;
    final ceil = adjusted.ceilToDouble();
    final result = ceil / adjuster;
    return result;
  }

  double roundToDecimalPlaces(int decimals) {
    final adjuster = math.pow(10, decimals);
    final adjusted = this * adjuster;
    final ceil = adjusted.roundToDouble();
    final result = ceil / adjuster;
    return result;
  }

  /// reduce a number to a scale between 0 and 1
  double scaleToSingleDouble(num min, num max) {
    return (this - min) / (max - min);
  }
}
