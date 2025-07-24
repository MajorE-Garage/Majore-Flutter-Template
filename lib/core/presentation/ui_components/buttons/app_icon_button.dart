import 'package:flutter/material.dart';

import '../../../../core/presentation/presentation.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required Widget child,
    this.onPressed,
    this.size = 24,
    this.color,
    this.circled = true,
  }) : _child = child,
       _icon = null,
       iconColor = null,
       iconSize = 0;

  const AppIconButton.fromIconData({
    super.key,
    required IconData icon,
    this.onPressed,
    this.size = 24,
    this.iconSize = 20,
    this.iconColor,
    this.color,
    this.circled = true,
  }) : _child = null,
       _icon = icon,
       assert(
         (circled && size >= iconSize) || !circled,
         'size cannot be less than icon size for circled AppIconButton',
       );

  final Widget? _child;
  final IconData? _icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final double iconSize;
  final Color? iconColor;
  final bool circled;

  @override
  Widget build(BuildContext context) {
    if (!circled) {
      return InkResponse(
        // TODO(Toyyib): Add analytics for icon buttons
        onTap: onPressed,
        child: _child ?? Icon(_icon, color: iconColor ?? AppColors.of(context).primaryColor, size: iconSize),
      );
    }

    final color = this.color ?? AppColors.of(context).secondaryColor;

    return InkResponse(
      onTap: onPressed,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        alignment: Alignment.center,
        child: _child ?? Icon(_icon, color: iconColor ?? AppColors.of(context).grey800, size: iconSize),
      ),
    );
  }
}
