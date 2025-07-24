import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = const Size(40, 32)});

  final Size size;
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: CircularProgressIndicator(
        color: context.colors.grey200,
        valueColor: AlwaysStoppedAnimation(context.colors.primaryColor),
      ),
    );
  }
}
