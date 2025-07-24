import 'package:flutter/material.dart';

import '../../../../core/presentation/presentation.dart';
import '../../../../utilities/constants/constants.dart';

enum AppToastType {
  success(Color(0xFF0A7214), Colors.white),
  error(Color(0xFF990A0A), Colors.white),
  information(Color(0xFF606060), Colors.white);

  const AppToastType(this.bgColor, this.textColor);
  final Color bgColor;
  final Color textColor;
}

class AppToast {
  final String message;
  final bool userCanDismiss;
  final Duration duration;
  final Alignment alignment;
  final AppToastType type;

  @protected
  late AnimationController animationController;
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
    final toastWidget = AppToastWidget(this, key: key);
    _overlayEntry = OverlayEntry(builder: (_) => toastWidget);
    Navigator.of(context ?? AppNavigator.main.currentContext).overlay!.insert(_overlayEntry!);
    Future.delayed(duration).then((_) => remove());
  }

  /// Removes the toast message from the screen.
  ///
  /// If the toast is not showing, nothing happens
  /// Otherwise, it uses the animation controller to reverse the animation
  /// and then removes the overlay entry.
  void remove() {
    if (_overlayEntry?.mounted ?? false) {
      animationController.reverse().then((_) {
        _overlayEntry!.remove();
      });
    }
  }

  void dispose() {
    animationController.dispose();
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
  @override
  void initState() {
    super.initState();
    _toast = widget.toast;
    _toast.animationController = AnimationController(vsync: this, duration: Constants.toastAnimationDuration);
    _toast.animationController.forward();
  }

  @override
  void dispose() {
    _toast.dispose();
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
        opacity: _toast.animationController.drive(CurveTween(curve: Curves.easeOut)),
        child: ScaleTransition(
          scale: _toast.animationController.drive(CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: _toast.userCanDismiss ? _toast.remove : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: _toast.type.bgColor),
                alignment: Alignment.centerLeft,
                child: Text(
                  _toast.message,
                  style: AppStyles.of(context).body16Medium.copyWith(color: _toast.type.textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
