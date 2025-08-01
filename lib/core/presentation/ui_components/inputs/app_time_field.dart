import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../presentation.dart';

class AppTimeField extends StatelessWidget {
  AppTimeField({
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
  }

  final bool isRequired;
  final TimeFieldController controller;
  final DateFormat? displayFormat;
  final String? label;
  final String? hint;
  final ValueChanged<TimeOfDay>? onChanged;
  final String? Function(TimeOfDay?)? validator;

  String? Function(String)? _makeValidator() {
    if (validator != null) {
      return (_) => validator!(controller.selectedTime);
    } else if (isRequired) {
      return (_) {
        if (controller.selectedTime == null) {
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
      keyboardType: TextInputType.none,
      label: label,
      hint: hint,
      isRequired: isRequired,
      validator: _makeValidator(),
      suffix: AppIconButton(
        label: 'Time',
        view: 'Time Field',
        circled: false,
        child: Icon(Icons.watch_later_rounded, color: AppColors.of(context).textColor, size: 16),
      ),
    );
  }
}

class TimeFieldController extends TextEditingController {
  DateFormat _format;
  TimeOfDay? _time;

  bool _pickerIsOpen = false;

  TimeFieldController({TimeOfDay? initialTime, DateFormat? format})
    : _format = format ?? DateFormat('hh:mm a');

  TimeOfDay? get selectedTime => _time;

  set selectedTime(TimeOfDay? time) {
    _time = time;
    _displayTimeInFormat();
  }

  Future<void> select({String? title}) async {
    _pickerIsOpen = true;
    final picker = TimePickerDialog(
      helpText: title,
      initialTime: _time ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    final selection = await AppNavigator.main.openDialog(dialog: picker);
    if (selection != null) selectedTime = selection;
    Future.delayed(Duration.zero, () => _pickerIsOpen = false);
  }

  void _changeFormat(DateFormat dateFormat) {
    _format = dateFormat;
    _displayTimeInFormat();
  }

  void _displayTimeInFormat() {
    if (_time != null) {
      text = _format.format(DateTime.now().copyWith(hour: _time?.hour, minute: _time?.minute));
    }
  }
}
