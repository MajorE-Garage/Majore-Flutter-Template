import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppDialog<T> extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.heading,
    required this.builder,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 0),
    this.isDismissable = true,
    this.dismissCallback,
  });

  final String? heading;
  final WidgetBuilder builder;
  final EdgeInsets padding;
  final bool isDismissable;
  final VoidCallback? dismissCallback;

  Future<T?> show({BuildContext? context, String? routeName}) async {
    final ctx = context ?? AppNavigator.main.currentContext;
    final value = await AppNavigator.of(
      ctx
    ).openDialog<T>(dialog: this, barrierDismissable: isDismissable, routeName: routeName);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDismissable,
      onPopInvokedWithResult: (pop, _) {
        if (dismissCallback != null) {
          dismissCallback!();
        }
      },
      child: Dialog(
        insetPadding: MediaQuery.of(context).viewInsets.copyWith(left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                children: [
                  if (heading != null)
                    Expanded(
                      child: Text(
                        heading!,
                        textAlign: TextAlign.start,
                        style: AppStyles.of(context).body16SemiBold,
                      ),
                    ),
                  // else
                  //   const Spacer(),
                  // if (isDismissable)
                  //   CloseButton(
                  //     onPressed:
                  //         dismissCallback ?? AppNavigator.main.maybePop,
                  //     color: AppColors.of(context).grey700,
                  //   ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(padding: this.padding, child: builder(context)),
            ),
          ],
        ),
      ),
    );
  }
}
