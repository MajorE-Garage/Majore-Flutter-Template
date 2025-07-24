import 'package:flutter/material.dart';

import '../../presentation.dart';
import '../buttons/app_button_widget.dart';
import '../loaders/app_loading_indicator.dart';

class PaginatedViewRender<E extends PaginatedDataViewModel<T>, T> extends StatelessWidget {
  PaginatedViewRender({
    super.key,
    required this.vm,
    this.itemBuilder,
    this.header,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.overrideDataList,
    this.overrideDataListBuilder,
  }) : assert(
         itemBuilder != null || overrideDataListBuilder != null,
         'One of itemBuilder or overrideDataListBuilder must be provided',
       );

  final E vm;

  final Widget Function(BuildContext, T)? itemBuilder;
  final Widget Function(E vm)? header;
  final Widget Function(E vm)? emptyState;
  final Widget Function(E vm)? loadingState;
  final Widget Function(E vm)? errorState;
  final Iterable<T> Function(E)? overrideDataList;
  final Widget Function(E vm)? overrideDataListBuilder;
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final listToUse = overrideDataList != null ? overrideDataList!(vm) : vm.data;

    final hasData = listToUse.isNotEmpty;
    Widget child;

    if (hasData) {
      child = overrideDataListBuilder != null
          ? overrideDataListBuilder!(vm)
          : Scrollbar(
              controller: scrollController,
              child: ListView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  for (final item in listToUse) itemBuilder!(context, item),
                  if (vm.isBusy)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox.square(dimension: 48, child: AppLoadingIndicator()),
                    ),
                ],
              ),
            );
    } else if (vm.isBusy) {
      child = loadingState != null
          ? loadingState!(vm)
          : const Align(
              alignment: Alignment(0, -0.3),
              child:
                  // Best place to use shimmers
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox.square(dimension: 40, child: AppLoadingIndicator()),
                  ),
            );
    } else if (vm.hasEncounteredError) {
      child = errorState != null
          ? errorState!(vm)
          : EmptyStateWidget(
              mainText: vm.lastFailure?.message.trim() ?? 'Something went wrong',
              illustrationSize: 48,
              illustration: Icon(Icons.warning_rounded, color: AppColors.of(context).grey700, size: 48),
              button: AppButton.text(label: 'Retry', onPressed: vm.refresh, view: E),
            );
    } else {
      child = emptyState != null
          ? emptyState!(vm)
          : EmptyStateWidget(
              mainText: 'This list is empty',
              illustration: Icon(
                Icons.clear_all_rounded,
                color: context.colors.grey700,
                // size: 48,
              ),
              illustrationSize: 48,
              button: AppButton.text(label: 'Refresh', onPressed: vm.refresh, view: E),
            );
    }
    return Column(
      children: [
        if (header != null) header!(vm),
        Flexible(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              final atEnd = (metrics.maxScrollExtent - 60) <= metrics.pixels;
              if (metrics.maxScrollExtent < metrics.viewportDimension) {
                vm.refresh();
              } else if (atEnd) {
                vm.fetchMore();
              }
              return false;
            },
            child: RefreshIndicator(onRefresh: vm.refresh, child: child),
          ),
        ),
      ],
    );
  }
}
