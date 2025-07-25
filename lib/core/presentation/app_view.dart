import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'presentation.dart';

/// A widget that provides a standardized way to build views using the MVVM pattern.
///
/// This widget wraps a view model and provides it to the builder function through
/// a Provider pattern. It handles the lifecycle of the view model and provides
/// error handling for the builder function.
///
/// The widget automatically manages the view model's lifecycle and provides it
/// to the builder function through the Provider pattern. It also handles errors
/// that may occur during the build process and provides logging for debugging.
///
/// Example usage:
/// ```dart
/// AppView<LoginViewModel>(
///   model: LoginViewModel(),
///   builder: (viewModel, child) => LoginView(viewModel: viewModel),
///   autoDispose: true,
/// )
/// ```
///
/// [T] The type of the view model that extends [AppViewModel].
class AppView<T extends AppViewModel> extends StatefulWidget {
  /// Creates an [AppView] widget.
  ///
  /// A widget that provides a standardized way to build views using the MVVM pattern.
  ///
  /// This widget wraps a view model and provides it to the builder function through
  /// a Provider pattern. It handles the lifecycle of the view model and provides
  /// error handling for the builder function.
  ///
  /// The widget automatically manages the view model's lifecycle and provides it
  /// to the builder function through the Provider pattern. It also handles errors
  /// that may occur during the build process and provides logging for debugging.
  ///
  /// Example usage:
  /// ```dart
  /// AppView<LoginViewModel>(
  ///   model: LoginViewModel(),
  ///   builder: (viewModel, child) => LoginView(viewModel: viewModel),
  ///   autoDispose: true,
  /// )
  /// ```
  /// The [model] and [builder] parameters are required. The [model] is the view
  /// model that will be provided to the builder function, and the [builder] is
  /// the function that builds the widget tree.
  ///
  /// [key] The widget key for this widget.
  ///
  /// [model] The view model instance that extends [AppViewModel].
  ///
  /// [builder] The function that builds the widget tree using the view model.
  ///
  /// [autoDispose] Whether to automatically dispose the view model when the widget is disposed.
  ///
  /// [child] An optional child widget that can be accessed in the builder function.
  ///
  /// [initState] An optional callback that is called during widget initialization.
  ///
  /// [postFrameCallback] An optional callback that is called after the first frame is rendered.
  ///
  /// [keepAlive] Whether to keep the widget alive when it's not visible.
  const AppView({
    super.key,
    required this.model,
    required this.builder,
    this.autoDispose = true,
    this.child,
    this.initState,
    this.postFrameCallback,
    this.keepAlive = false,
  });

  /// The view model instance that will be provided to the builder function.
  ///
  /// This view model must extend [AppViewModel] and will be used to manage
  /// the state and business logic for the view.
  final T model;

  /// Whether to automatically dispose the view model when the widget is disposed.
  ///
  /// If true, the view model's [dispose] method will be called when this widget
  /// is disposed. This is useful for cleaning up resources like streams or timers.
  final bool autoDispose;

  /// An optional child widget that can be accessed in the builder function.
  ///
  /// This child widget is passed to the builder function and can be used
  /// to build the widget tree. It's typically used for providing additional
  /// context or data to the view.
  final Widget? child;

  /// An optional callback that is called during widget initialization.
  ///
  /// This callback is called in the [initState] method and can be used to
  /// perform any initialization logic for the view model. It receives the
  /// view model instance as a parameter.
  final void Function(T vm)? initState;

  /// An optional callback that is called after the first frame is rendered.
  ///
  /// This callback is called using [WidgetsBinding.addPostFrameCallback] and
  /// can be used to perform any logic that needs to happen after the widget
  /// has been built for the first time. It receives the view model instance
  /// as a parameter.
  final void Function(T vm)? postFrameCallback;

  /// The function that builds the widget tree using the view model.
  ///
  /// This function receives the view model instance and an optional child widget
  /// as parameters and should return a widget tree. The view model is provided
  /// through the Provider pattern, so any child widgets can access it using
  /// [Provider.of] or [Consumer].
  final Widget Function(T vm, Widget? child) builder;

  /// Whether to keep the widget alive when it's not visible.
  ///
  /// If true, the widget will not be disposed when it's not visible, which
  /// can be useful for preserving state or avoiding expensive rebuilds.
  /// This is implemented using [AutomaticKeepAliveClientMixin].
  final bool keepAlive;

  @override
  AppViewState<T> createState() => AppViewState<T>();
}

/// The state class for [AppView].
///
/// This class manages the lifecycle of the view model and provides it to the
/// builder function through the Provider pattern. It also handles errors that
/// may occur during the build process and provides logging for debugging.
///
/// The state class uses [AutomaticKeepAliveClientMixin] to support the [keepAlive]
/// functionality, which allows the widget to stay alive when it's not visible.
///
/// [T] The type of the view model that extends [AppViewModel].
class AppViewState<T extends AppViewModel> extends State<AppView<T>>
    with AutomaticKeepAliveClientMixin {
  /// The view model instance that is provided to the builder function.
  ///
  /// This is initialized in the [initState] method and is used throughout
  /// the widget's lifecycle to manage state and business logic.
  late T model;

  @override
  void initState() {
    // Initialize the view model instance
    model = widget.model;

    // Call the optional initState callback if provided
    final initState = widget.initState;
    if (initState != null) {
      try {
        initState(model);
      } catch (e, t) {
        Logger(widget.runtimeType.toString()).severe('Error in initState of AppViewState', e, t);
      }
    }

    // Set up the optional postFrameCallback if provided
    final callback = widget.postFrameCallback;
    if (callback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          callback(model);
        } catch (e, t) {
          Logger(
            widget.runtimeType.toString(),
          ).severe('Error in postFrameCallback of AppViewState', e, t);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the view model if autoDispose is enabled
    if (widget.autoDispose) model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Call super.build if keepAlive is enabled
    if (widget.keepAlive) {
      super.build(context);
    }

    // Provide the view model through ChangeNotifierProvider and build the widget tree
    return ChangeNotifierProvider<T>.value(
      value: model,
      builder: (BuildContext context, Widget? child) {
        try {
          return widget.builder(model, child);
        } catch (e) {
          Logger(widget.runtimeType.toString()).severe('Error in builder of AppView: $e');
          return Container();
        }
      },
      child: widget.child,
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

class AppViewBuilder<T extends AppViewModel> extends StatelessWidget {
  const AppViewBuilder({super.key, required this.builder, this.child});
  final Widget Function(T vm, Widget? child) builder;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(child: child, builder: (_, value, child) => builder(value, child));
  }
}

class AppViewSelector<T extends AppViewModel, E extends Object> extends StatelessWidget {
  const AppViewSelector({super.key, required this.selector, required this.builder, this.child});
  final E Function(T model) selector;
  final Widget Function(E value, Widget? child) builder;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Selector<T, E>(
      selector: (_, model) => selector(model),
      child: child,
      builder: (_, value, child) => builder(value, child),
    );
  }
}
