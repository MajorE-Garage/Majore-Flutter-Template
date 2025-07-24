import 'package:flutter/material.dart';

import '../../../../core/presentation/presentation.dart';
import '../buttons/app_button_widget.dart';

class AppDatePicker extends StatefulWidget {
  const AppDatePicker({
    super.key,
    required this.initialSelection,
    required this.firstDate,
    required this.lastDate,
    this.title,
  });

  final String? title;
  final DateTime? initialSelection;
  final DateTime firstDate;
  final DateTime lastDate;

  Future<DateTime?> show([BuildContext? context]) {
    final navigator = context != null ? AppNavigator.of(context) : AppNavigator.main;
    return navigator.openDialog<DateTime>(routeName: 'CustomDatePicker(${title ?? 'No Title'})', dialog: this);
  }

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    _selectedDate = widget.initialSelection ?? widget.lastDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(widget.title!, style: AppStyles.of(context).body16Regular),
            ),
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onDateChanged: (date) {
              _selectedDate = date;
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton.primary(
                  wrap: true,
                  onPressed: () => AppNavigator.of(context).maybePop(_selectedDate),
                  label: 'Select',
                ),
                const SizedBox(width: 8),
                AppButton.secondary(
                  wrap: true,
                  onPressed: () => AppNavigator.of(context).maybePop(null),
                  label: 'Cancel',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
