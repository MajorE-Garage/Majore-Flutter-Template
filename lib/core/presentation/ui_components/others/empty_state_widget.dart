import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/presentation.dart';
import '../buttons/app_button_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.mainText,
    required this.illustration,
    this.button,
    this.illustrationSize = 32,
  });

  final String mainText;
  final AppButton? button;
  final Widget illustration;
  final double illustrationSize;

  @override
  Widget build(BuildContext context) {
    final styles = AppStyles.of(context);
    return Align(
      alignment: const Alignment(0, -0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: illustrationSize,
              child: illustration
                  .animate(onPlay: (controller) => controller.loop(reverse: true))
                  .scale(begin: const Offset(1.2, 1.2), curve: Curves.elasticOut, duration: const Duration(seconds: 4)),
            ),
            const SizedBox(height: 16),
            Text(mainText, style: styles.body16Regular, textAlign: TextAlign.center),
            if (button != null) Padding(padding: const EdgeInsets.only(top: 32.0), child: button),
          ],
        ).animate().slideY(begin: -0.2, end: 0, curve: Curves.ease, duration: 900.milliseconds),
      ),
    );
  }
}
