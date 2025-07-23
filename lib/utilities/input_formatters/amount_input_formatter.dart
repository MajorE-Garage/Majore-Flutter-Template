import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AmountThousandthFormatter extends TextInputFormatter {
  TextEditingValue format(dynamic value) {
    // Remove any non-numeric characters from the input
    final inputNum = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');

    // Insert thousand separators every three digits from the right
    final parts = inputNum.split('.');
    String formattedNum = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    if (parts.length > 1) {
      // include two decimal spaces
      final decimalPart = parts[1].characters.take(2);
      formattedNum = '$formattedNum.$decimalPart';
    }

    // Return the updated text editing value with the formatted input and cursor position
    return TextEditingValue(
      text: formattedNum,
      selection: TextSelection.collapsed(offset: formattedNum.length),
    );
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formattedNum = format(newValue.text);
    return formattedNum;
  }
}
