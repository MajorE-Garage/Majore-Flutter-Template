import 'dart:collection';

import 'package:flutter/material.dart';

import '../presentation/ui_components/overlays/app_toast_widget.dart';
import 'app_responses.dart';
import 'failure.dart';

enum VmState { none, busy, error, noConnection }

/// A base class for creating view models as [ChangeNotifier]s that hold UI and other logic for a particular screen or feature.
/// The UI listens to children of this class and rebuilds itself based on its members. The UI (buttons and gestures) may also call methods on children of this class.
/// This class sits in between the UI and the data layer.
abstract class AppViewModel extends ChangeNotifier {
  VmState _viewState = VmState.none;
  bool _disposed = false;

  Failure? _lastFailure;
  Failure? get lastFailure => _lastFailure;

  /// The current state of the view model.
  VmState get viewState => _viewState;

  /// Returns true if the view model has encountered an error, false otherwise.
  bool get hasEncounteredError => _viewState == VmState.error || _viewState == VmState.noConnection;

  /// Returns true if the view model is currently busy, false otherwise.
  bool get isBusy => _viewState == VmState.busy;

  /// Called by the framework when the object is no longer needed.
  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }

  /// Sets the view model's state to [viewState] and notifies any listeners of the change.
  ///
  /// If [viewState] is null, the view model's state is not updated, but its listeners are still notified.
  @protected
  void setState([VmState? viewState]) {
    if (viewState != null) _viewState = viewState;
    if (!_disposed && hasListeners) notifyListeners();
  }

  /// Handles [failure] and sets the view model's state accordingly.
  ///
  /// If the view model has any listeners attached, an [AppToast] with the error message is displayed.
  /// If [failure] is a [NetworkFailure], the view model's state is set to [VmState.noConnection].
  /// Otherwise, the view model's state is set to [VmState.error].
  @protected
  void handleErrorAndSetVmState(Failure failure, [String? heading]) {
    handleError(failure);

    if (failure is NetworkFailure) {
      setState(VmState.noConnection);
    } else {
      setState(VmState.error);
    }
  }

  @protected
  void handleError(Failure failure, [String? heading]) {
    if (failure is BadAuthFailure) {
      // TODO(MajorE): Handle bad auth failure
    }
    if (hasListeners) {
      AppToast.error(failure.message).show();
      _lastFailure = failure;
    }
  }
}

abstract class PaginatedDataViewModel<T> extends AppViewModel {
  int _page = 1;
  bool _reachedMax = false;

  @protected
  final dataList = <T>[];

  @override
  bool get hasEncounteredError => super.hasEncounteredError && !hasData;

  bool get hasData => data.isNotEmpty;
  int get page => _page;
  bool get noMorePages => _reachedMax;
  UnmodifiableListView<T> get data => UnmodifiableListView(dataList);

  Future<DataResponse<Iterable<T>>> fetchData(int page);

  Future<void> refresh() {
    _page = 1;
    _reachedMax = false;
    return _fetchData();
  }

  Future<void> fetchMore() {
    return _fetchData();
  }

  Future<void> _fetchData() async {
    if (isBusy || _reachedMax) return;
    setState(VmState.busy);

    final fetchHistory = await fetchData(_page);
    if (fetchHistory.hasError) {
      handleErrorAndSetVmState(fetchHistory.error!);
    } else {
      if (_page == 1) dataList.clear();
      final data = fetchHistory.data!;
      if (data.isNotEmpty) {
        dataList.addAll(fetchHistory.data!);

        _page++;
      } else {
        _reachedMax = true;
      }
      setState(VmState.none);
    }
  }
}
