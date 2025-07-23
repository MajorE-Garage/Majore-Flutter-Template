import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  final String separator;
  static const _maxLength = 8;
  DateInputFormatter({required this.separator});
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any non-numeric characters from the new value
    String sanitizedValue = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    // If the sanitized value is longer than the max length, truncate it
    if (sanitizedValue.length > _maxLength) {
      sanitizedValue = sanitizedValue.substring(0, _maxLength);
    }

    // Add dashes to the sanitized value at the appropriate positions
    String formattedValue = '';
    for (int i = 0; i < sanitizedValue.length; i++) {
      if (i == 2 || i == 4) {
        formattedValue += separator;
      }
      formattedValue += sanitizedValue[i];
    }

    // If the new value is the same as the formatted value, no need to update the text editing value
    if (newValue.text == formattedValue) {
      return newValue;
    }

    // Otherwise, create and return a new text editing value with the formatted value
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
