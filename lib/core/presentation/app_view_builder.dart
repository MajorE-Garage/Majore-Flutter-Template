import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:riverpod/riverpod.dart';

import '../../features/shared/components/buttons_and_ctas/app_button_widget.dart';
import '../../features/shared/components/loaders/app_loading_indicator.dart';
import 'presentation.dart';

export '../../features/shared/components/others/empty_state_widget.dart';

class AppViewBuilder<T extends AppViewModel> extends StatefulWidget {
  const AppViewBuilder({
    super.key,
    required this.model,
    required this.builder,
    this.autoDispose = false,
    this.child,
    this.initState,
    this.postFrameCallback,
    this.keepAlive = false,
  });

  final T model;
  final bool autoDispose;
  final Widget? child;
  final void Function(T vm)? initState;
  final void Function(T vm)? postFrameCallback;
  final Widget Function(T vm, Widget? child) builder;
  final bool keepAlive;

  @override
  AppViewBuilderState<T> createState() => AppViewBuilderState<T>();
}

class AppViewBuilderState<T extends AppViewModel> extends State<AppViewBuilder<T>> with AutomaticKeepAliveClientMixin {
  late T model;

  @override
  void initState() {
    model = widget.model;

    final initState = widget.initState;
    if (initState != null) {
      try {
        initState(model);
      } catch (e, t) {
        Logger(widget.runtimeType.toString()).severe('Error in initState of AppViewBuilderState', e, t);
      }
    }

    final callback = widget.postFrameCallback;
    if (callback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          callback(model);
        } catch (e, t) {
          Logger(widget.runtimeType.toString()).severe('Error in postFrameCallback of AppViewBuilderState', e, t);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.autoDispose) model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.keepAlive) {
      super.build(context);
    }
    return ChangeNotifierProvider<T>.value(
      value: model,
      child: Consumer<T>(
        builder: (BuildContext context, T value, Widget? child) {
          try {
            return widget.builder(value, child);
          } catch (e) {
            Logger(widget.runtimeType.toString()).severe('Error in builder of AppViewBuilder: $e');
            return Container();
          }
        },
        child: widget.child,
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

// class PaginatedViewBuilder<E extends PaginatedDataViewModel<T>, T>
//     extends AppViewBuilder<E> {
//   PaginatedViewBuilder({
//     super.key,
//     required E model,
//     super.child,
//     super.autoDispose = false,
//     required super.builder,
//     void Function(E vm)? postFrameCallback,
//     super.initState,
//   }) : super(
//           model: model,
//           postFrameCallback: (vm) {
//             if (postFrameCallback != null) postFrameCallback(vm);
//             vm.refresh();
//           },
//         );
// }

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
                color: AppColors.of(context).grey700,
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
