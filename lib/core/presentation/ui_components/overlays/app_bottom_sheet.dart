import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppBottomSheet<T> extends StatefulWidget {
  AppBottomSheet({
    super.key,
    required String? heading,
    required this.builder,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 0),
    this.isDismissable = true,
    this.dismissCallback,
    this.builderHandlesScroll = false,
  }) : heading = heading != null ? Text(heading) : null;

  const AppBottomSheet.customHeading({
    super.key,
    required this.heading,
    required this.builder,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 0),
    this.isDismissable = true,
    this.dismissCallback,
    this.builderHandlesScroll = false,
  });

  final Widget? heading;
  final WidgetBuilder builder;
  final EdgeInsets padding;
  final bool isDismissable;
  final VoidCallback? dismissCallback;
  final bool builderHandlesScroll;

  @override
  State<AppBottomSheet<T>> createState() => _AppBottomSheetState<T>();

  Future<T?> show({
    BuildContext? context,
    String? routeName,
    bool isScrollControlled = true,
    bool enableDrag = true,
  }) async {
    final navigator = context != null ? AppNavigator.of(context) : AppNavigator.main;
    final value = await navigator.openBottomsheet(
      sheet: this,
      isDismissible: isDismissable,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      routeName: routeName,
    );
    return value;
  }
}

class _AppBottomSheetState<T> extends State<AppBottomSheet<T>> with SingleTickerProviderStateMixin {
  late AnimationController _sheetAnimationController;
  @override
  void initState() {
    _sheetAnimationController = BottomSheet.createAnimationController(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isDismissable,
      onPopInvokedWithResult: (pop, _) {
        if (pop) return;
        if (widget.dismissCallback != null) {
          widget.dismissCallback!();
        }
      },
      child: BottomSheet(
        showDragHandle: false,
        animationController: _sheetAnimationController,
        onClosing: () {
          if (widget.dismissCallback != null) {
            widget.dismissCallback!();
          }
        },
        builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 120,
                margin: const EdgeInsets.only(bottom: 24, top: 8),
                decoration: BoxDecoration(
                  color: AppColors.of(context).grey500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (widget.heading != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 24, right: 24),
                  child: DefaultTextStyle(
                    textAlign: TextAlign.start,
                    style: AppStyles.of(context).body16SemiBold,
                    child: widget.heading!,
                  ),
                ),
              Flexible(
                child: widget.builderHandlesScroll
                    ? Padding(padding: widget.padding, child: widget.builder(context))
                    : SingleChildScrollView(
                        padding: widget.padding,
                        child: widget.builder(context),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
