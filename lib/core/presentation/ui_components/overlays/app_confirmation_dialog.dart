import 'package:flutter/material.dart';

import '../../presentation.dart';

// May be converted to a Sheet rather than a sheet,
// depending on design decision
class AppConfirmationDialog extends AppDialog<bool> {
  AppConfirmationDialog({
    super.key,
    required String heading,
    required String? body,
    VoidCallback? yesOnPressed,
    String? yesLabel,
    String? cancelLabel,
    Widget? illustration,
    Color? yesColor,
    Color? noColor,
  }) : super(
         heading: null,
         padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
         builder: (context) => Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisSize: MainAxisSize.min,
           children: [
             if (illustration != null) SizedBox(height: 124, width: 124, child: illustration),
             const SizedBox(height: 0),
             Text(heading, textAlign: TextAlign.center, style: AppStyles.of(context).heading20Regular),
             if (body != null)
               Padding(
                 padding: const EdgeInsets.only(top: 8),
                 child: Text(body, style: AppStyles.of(context).body16Regular, textAlign: TextAlign.center),
               ),
             const SizedBox(height: 24),
             SizedBox(
               height: 32,
               child: Row(
                 children: [
                   Expanded(
                     child: AppButton.secondary(
                       outlineColor: yesColor ?? AppColors.of(context).attitudeErrorMain,
                       label: yesLabel ?? 'Yes',
                       wrap: true,
                       onPressed: yesOnPressed ?? () => AppNavigator.of(context).pop(true),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: AppButton.secondary(
                       outlineColor: noColor ?? AppColors.of(context).primaryColor,
                       label: cancelLabel ?? 'No',
                       wrap: true,
                       onPressed: () => AppNavigator.of(context).pop(false),
                     ),
                   ),
                 ],
               ),
             ),
           ],
         ),
       );
}
