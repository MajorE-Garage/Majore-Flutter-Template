import 'package:flutter/material.dart';

import '../../../../services/analytics_service/analytics_service.dart';
import '../../presentation.dart';

enum _ButtonType {
  primary,
  secondary,
  text;

  bool get isPrimary => this == primary;
  bool get isSecondary => this == secondary;
}

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.color,
    this.textColor = Colors.white,
    this.enabled = true,
    this.view,
    this.wrap = false,
    this.icon,
  }) : _type = _ButtonType.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    // this.color,
    Color? outlineColor,
    this.enabled = true,
    this.view,
    this.wrap = false,
    this.icon,
  }) : _type = _ButtonType.secondary,
       color = null,
       textColor = outlineColor;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.textColor,
    this.enabled = true,
    this.view,
    this.wrap = false,
    this.icon,
  }) : _type = _ButtonType.text,
       color = Colors.transparent;

  final String label;
  final bool busy;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final Object? view;
  final _ButtonType _type;
  final bool wrap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    //? Get label text color
    Color tColor;
    if (_type.isPrimary) {
      final textColor = this.textColor ?? colors.textAltColor;
      tColor = enabled ? textColor : colors.textAltColor;
    } else {
      final textColor = this.textColor ?? colors.primaryColor;
      tColor = enabled ? textColor : colors.grey600;
    }

    //? Get label text
    final textStyle = AppStyles.of(context).body16SemiBold.copyWith(color: tColor);
    final labelText = FittedBox(
      child: Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    //? Get full button child
    Widget child;
    if (busy) {
      child = const AppLoadingIndicator();
    } else if (icon == null) {
      child = labelText;
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(child: labelText),
        ],
      );
    }

    return TextButton(
      onPressed: enabled && !busy
          ? () {
              FocusScope.of(context).unfocus();
              onPressed();
              AnalyticsService.instance.logEvent(
                'Button Pressed',
                properties: {
                  'Name': label,
                  'Location': view?.toString() ?? context.immediateAncestor,
                  'Type': _type.name,
                },
              );
            }
          : null,
      style: ButtonStyle(
        splashFactory: InkSplash.splashFactory,
        minimumSize: WidgetStateProperty.all(wrap ? const Size(40, 48) : const Size.fromHeight(48)),
        padding: WidgetStateProperty.all(
          busy ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (!_type.isPrimary) return Colors.transparent;
          if (states.contains(WidgetState.disabled)) {
            return colors.grey600;
          }
          if (states.contains(WidgetState.pressed) || states.contains(WidgetState.focused)) {
            return colors.attitudeSuccessMain;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.attitudeWarningLight;
          }
          return color ?? colors.primaryColor;
        }),
        shape: WidgetStateProperty.resolveWith((states) {
          if (_type == _ButtonType.text) return null;

          Color? getBorderColor(Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return tColor.withAlpha(204);
            }
            if (!_type.isSecondary) return null;
            if (states.contains(WidgetState.disabled)) {
              return colors.grey600;
            }
            // if (states.contains(WidgetState.pressed)) {
            //   return tColor;
            // }
            return tColor;
          }

          final color = getBorderColor(states);

          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(wrap ? 48 : 20),
            side: color != null ? BorderSide(width: 1, color: color) : BorderSide.none,
          );
        }),
      ),
      child: child,
    );
  }
}
