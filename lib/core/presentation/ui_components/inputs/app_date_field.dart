import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../presentation.dart';
import '../others/app_datepicker.dart';

class AppDateField extends StatelessWidget {
  AppDateField({
    super.key,
    required this.controller,
    this.validator,
    this.isRequired = false,
    this.displayFormat,
    this.label,
    this.hint,
    this.onChanged,
  }) {
    if (displayFormat != null) controller._changeFormat(displayFormat!);
    controller._addOnChanged(onChanged);
  }

  final bool isRequired;
  final DateFieldController controller;
  final DateFormat? displayFormat;
  final String? label;
  final String? hint;
  final ValueChanged<DateTime?>? onChanged;
  final String? Function(DateTime?)? validator;

  String? Function(String)? _makeValidator() {
    if (validator != null) {
      return (_) => validator!(controller.selectedDate);
    } else if (isRequired) {
      return (_) {
        if (controller.selectedDate == null) {
          return 'This field is required';
        } else {
          return null;
        }
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      onTap: () => controller.select(title: label),
      onFocusChange: (inFocus) async {
        if (inFocus && !controller._pickerIsOpen) {
          await controller.select(title: label);
        }
      },
      // onChanged:
      //     onChanged != null ? (_) => onChanged!(controller.selectedDate) : null,
      keyboardType: TextInputType.none,
      label: label,
      hint: hint,
      isRequired: isRequired,
      validator: _makeValidator(),
      suffix: AppIconButton(
        label: '$label DateField',
        view: context.immediateAncestor,
        circled: false,
        child: Icon(Icons.calendar_today_rounded, color: AppColors.of(context).textColor, size: 16),
      ),
    );
  }
}

class DateFieldController extends TextEditingController {
  final DateTime earliestDateAllowed;
  final DateTime latestDateAllowed;
  final DateTime? initialDate;
  DateFormat _format;
  DateTime? _date;
  ValueChanged<DateTime?>? _onChanged;

  bool _pickerIsOpen = false;

  DateFieldController({
    required this.earliestDateAllowed,
    required this.latestDateAllowed,
    this.initialDate,
    DateFormat? format,
  }) : _format = format ?? DateFormat('dd MMM, yyyy');

  DateTime? get selectedDate => _date;

  set selectedDate(DateTime? date) {
    _date = date;
    _displayDateInFormat();
  }

  Future<void> select({String? title}) async {
    _pickerIsOpen = true;
    final picker = AppDatePicker(
      title: title,
      initialSelection: _date ?? initialDate,
      firstDate: earliestDateAllowed,
      lastDate: latestDateAllowed,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    final selection = await picker.show();
    if (selection != null) {
      selectedDate = selection;
      if (_onChanged != null) _onChanged!(selectedDate);
    }
    Future.delayed(Duration.zero, () => _pickerIsOpen = false);
  }

  void _changeFormat(DateFormat dateFormat) {
    _format = dateFormat;
    _displayDateInFormat();
  }

  void _addOnChanged(ValueChanged<DateTime?>? onChanged) {
    _onChanged = onChanged;
  }

  void _displayDateInFormat() {
    if (_date != null) {
      text = _format.format(_date!);
    }
  }
}
