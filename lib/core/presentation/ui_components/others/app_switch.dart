import 'package:flutter/material.dart';

import '../../../../core/presentation/presentation.dart';

class AppSwitch extends StatelessWidget {
  final bool active;
  final VoidCallback? onTap;

  const AppSwitch({super.key, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // final color = colors.attitudeSuccessLight;
    // final mainAxisAlignment =
    //     active ? MainAxisAlignment.end : MainAxisAlignment.start;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colors.attitudeSuccessLight,
          border: Border.all(color: colors.grey600, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          alignment: active ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 400),
          child: Container(
            // alignment: Alignment.center,
            height: 16, width: 16,
            // constraints: const BoxConstraints.(),
            decoration: BoxDecoration(
              color: active ? colors.attitudeSuccessDark : colors.grey600,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
