import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({this.color, super.key});
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: AppNavigator.of(context).maybePop,
        child: Icon(
          CupertinoIcons.arrow_left,
          color: color ?? AppColors.of(context).textColor,
        ),
      ),
    );
  }
}
