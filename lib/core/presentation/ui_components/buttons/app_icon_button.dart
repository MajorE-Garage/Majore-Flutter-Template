import 'package:flutter/material.dart';
import '../../../../services/analytics_service/analytics_service.dart';
import '../../presentation.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required Widget child,
    this.onPressed,
    this.size = 24,
    this.color,
    this.circled = true,
    required  this.label, // Add label parameter
    this.view, // Add view parameter
  })  : _child = child,
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
    required this.label, // Add label parameter
     this.view, // Add view parameter
  })  : _child = null,
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
  final String label; // For analytics
  final Object? view; // For screen/location tracking

  @override
  Widget build(BuildContext context) {
    if (!circled) {
      return InkResponse(
        onTap: onPressed != null
            ? () {
                onPressed?.call();
                AnalyticsService.instance.logEvent(
                  'Icon Button Press',
                  properties: {
                    'Name': label, // Use label instead of analyticsName
                    if (view != null) 'Location': view.toString(), // Add location tracking
                    'Type': 'Plain', 
                  },
                );
              }
            : null,
        child: _child ??
            Icon(_icon, color: iconColor ?? AppColors.of(context).primaryColor, size: iconSize),
      );
    }

    final color = this.color ?? AppColors.of(context).secondaryColor;

    return InkResponse(
      onTap: onPressed != null
          ? () {
              onPressed?.call();
              AnalyticsService.instance.logEvent(
                'Icon Button Press',
                properties: {
                  'Name': label, // Use label instead of analyticsName
                  if (view != null) 'Location': view.toString(), // Add location tracking
                  'Type': 'Circled' 
                },
              );
            }
          : null,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        alignment: Alignment.center,
        child: _child ??
            Icon(_icon, color: iconColor ?? AppColors.of(context).grey800, size: iconSize),
      ),
    );
  }
}
