import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../utilities/input_formatters/amount_input_formatter.dart';
import 'app_text_field.dart';

class AppAmountField extends AppTextField {
  AppAmountField({
    super.key,
    required AmountFieldController super.controller,
    super.label,
    super.hint,
    String? Function(double amount)? validator,
    List<TextInputFormatter>? formatters,
    super.isRequired,
    ValueChanged<double>? onChanged,
    super.onEditComplete,
    super.prefixText,
    super.prefix,
    super.suffix,
  }) : super(
         validator: validator != null ? (_) => validator(controller.amount) : null,
         formatters: [
           // If formatters is not null, remove AmountThousandthFormatter from it
           // and spread the rest into this input's formatters
           ...(formatters ?? [])
             ..removeWhere((frt) => frt.runtimeType == AmountThousandthFormatter),
           // AmountThousandthFormatter included wether formatters is null or not
           AmountThousandthFormatter(),
         ],
         onChanged: onChanged != null ? (_) => onChanged(controller.amount) : null,
         keyboardType: const TextInputType.numberWithOptions(decimal: true),
       );
}

class AmountFieldController extends TextEditingController {
  double get amount {
    final clean = text.replaceAll(',', '');
    final val = double.tryParse(clean);
    return val ?? 0;
  }

  set amount(double amount) {
    TextEditingValue text;
    final formatter = AmountThousandthFormatter();
    if (amount.truncateToDouble() == amount) {
      text = formatter.format(amount.truncate());
    } else {
      text = formatter.format(amount);
    }
    value = text;
  }
}
