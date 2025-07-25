import 'package:flutter/material.dart';

import '../../../../utilities/constants/constants.dart';
import '../../presentation.dart';

class ToastErrorHandler implements MessageDisplayHandler {
  @override
  void showError(String message, [String? heading]) {
    AppToast.error(message).show();
  }

  @override
  void showInfo(String message, [String? heading]) {
    AppToast.info(message).show();
  }

  @override
  void showSuccess(String message, [String? heading]) {
    AppToast.success(message).show();
  }

  @override
  void showWarning(String message, [String? heading]) {
    AppToast.error(message).show();
  }
}

enum AppToastType {
  success,
  error,
  warning,
  information;

  Color getBackgroundColor(BuildContext context) {
    final colors = AppColors.of(context);
    switch (this) {
      case AppToastType.success:
        return colors.attitudeSuccessMain;
      case AppToastType.error:
        return colors.attitudeErrorMain;
      case AppToastType.warning:
        return colors.attitudeWarningMain;
      case AppToastType.information:
        return colors.grey600;
    }
  }

  Color getTextColor(BuildContext context) {
    final colors = AppColors.of(context);
    switch (this) {
      case AppToastType.success:
      case AppToastType.error:
      case AppToastType.warning:
        return colors.textAltColor;
      case AppToastType.information:
        return colors.textColor;
    }
  }

  IconData getIcon() {
    switch (this) {
      case AppToastType.success:
        return Icons.check_circle;
      case AppToastType.error:
        return Icons.error;
      case AppToastType.warning:
        return Icons.warning;
      case AppToastType.information:
        return Icons.info;
    }
  }
}

class AppToast {
  final String message;
  final bool userCanDismiss;
  final Duration duration;
  final Alignment alignment;
  final AppToastType type;

  OverlayEntry? _overlayEntry;

  AppToast.error(
    this.message, {
    Key? key,
    this.userCanDismiss = false,
    this.alignment = Alignment.topCenter,
    this.duration = Constants.toastDefaultDuration,
    BuildContext? context,
  }) : type = AppToastType.error;

  AppToast.success(
    this.message, {
    Key? key,
    this.userCanDismiss = true,
    this.alignment = Alignment.topCenter,
    this.duration = Constants.toastDefaultDuration,
    BuildContext? context,
  }) : type = AppToastType.success;

  AppToast.info(
    this.message, {
    Key? key,
    this.userCanDismiss = true,
    this.alignment = Alignment.topCenter,
    this.duration = Constants.toastDefaultDuration,
    BuildContext? context,
  }) : type = AppToastType.information;

  /// Shows the toast message on the screen.
  ///
  /// If the toast is already shown, nothing happens.
  /// Otherwise, it creates the toast widget using the given parameters and displays it in the
  /// nearest `Navigator`'s `Overlay`.
  /// It then removes the widget after the specified [duration] has passed.
  void show([BuildContext? context, Key? key]) {
    if (_overlayEntry?.mounted ?? false) return;

    // Ensure we have a valid context
    final navigatorContext = context ?? AppNavigator.main.currentContext;

    final toastWidget = AppToastWidget(this, key: key);
    _overlayEntry = OverlayEntry(builder: (_) => toastWidget);
    Navigator.of(navigatorContext).overlay?.insert(_overlayEntry!);
    Future.delayed(duration).then((_) => remove());
  }

  /// Removes the toast message from the screen.
  ///
  /// If the toast is not showing, nothing happens
  /// Otherwise, it uses the animation controller to reverse the animation
  /// and then removes the overlay entry.
  void remove() {
    if (_overlayEntry?.mounted ?? false) {
      // The animationController is now managed by the widget, so we don't dispose it here.
      // The widget will handle its own animation.
      _overlayEntry!.remove();
    }
  }

  void dispose() {
    // The animationController is now managed by the widget, so we don't dispose it here.
  }
}

class AppToastWidget extends StatefulWidget {
  final AppToast toast;

  /// A widget that displays a toast notification.
  ///
  /// Args:
  ///     toast (AppToast): The toast to display.
  const AppToastWidget(this.toast, {super.key});

  @override
  AppToastWidgetState createState() => AppToastWidgetState();
}

class AppToastWidgetState extends State<AppToastWidget> with SingleTickerProviderStateMixin {
  late AppToast _toast;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _toast = widget.toast;
    _animationController = AnimationController(
      vsync: this,
      duration: Constants.toastAnimationDuration,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;

    // final rectOfPosition = _toast.alignment.inscribe(
    //   Size(screenSize.width - 32, 56),
    //   Rect.fromLTRB(
    //     24,
    //     kToolbarHeight + 24,
    //     screenSize.width - 24,
    //     screenSize.height - (kToolbarHeight + 24),
    //   ),
    // );

    return Positioned(
      // rect: rectOfPosition,
      left: 16,
      right: 16,
      top: _toast.alignment.y.isNegative ? kToolbarHeight + 24 : null,
      bottom: !_toast.alignment.y.isNegative ? kToolbarHeight + 24 : null,
      child: FadeTransition(
        opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
        child: ScaleTransition(
          scale: _animationController.drive(CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: _toast.userCanDismiss ? _toast.remove : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _toast.type.getBackgroundColor(context),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(_toast.type.getIcon(), color: _toast.type.getTextColor(context), size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _toast.message,
                        style: AppStyles.of(
                          context,
                        ).body16Medium.copyWith(color: _toast.type.getTextColor(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
