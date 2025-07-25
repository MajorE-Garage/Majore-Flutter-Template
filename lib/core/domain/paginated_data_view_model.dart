import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'app_responses.dart';
import 'app_view_model.dart';

/// A specialized view model for handling paginated data.
///
/// This class extends [AppViewModel] to provide functionality for loading
/// and managing paginated data from a data source. It handles the common
/// patterns of pagination including loading states, error handling, and
/// data accumulation.
///
/// The class provides methods for refreshing data, loading more data,
/// and managing the pagination state (current page, whether more data
/// is available, etc.).
///
/// [T] The type of data items in the paginated list.
///
/// Example usage:
/// ```dart
/// class UserListViewModel extends PaginatedDataViewModel<User> {
///   @override
///   Future<DataResponse<Iterable<User>>> fetchData(int page) async {
///     // Implement data fetching logic
///     return await userRepository.getUsers(page: page);
///   }
/// }
/// ```
abstract class PaginatedDataViewModel<T> extends AppViewModel {
  /// The current page number for pagination.
  ///
  /// This field tracks the current page being loaded. It starts at 1
  /// and is incremented each time more data is successfully loaded.
  int _page = 1;

  /// Whether the maximum number of pages has been reached.
  ///
  /// This flag indicates whether there are more pages available to load.
  /// It's set to true when a page returns no data, indicating the end
  /// of the paginated data.
  bool _reachedMax = false;

  /// The list that stores all loaded data items.
  ///
  /// This list accumulates all data items from all loaded pages.
  /// It's protected to allow subclasses to access it for custom logic.
  @protected
  final dataList = <T>[];

  /// Returns true if the view model has encountered an error and has no data.
  ///
  /// This overrides the parent's [hasEncounteredError] to only return true
  /// if there's an error AND no data has been loaded. This prevents showing
  /// error states when there's existing data to display.
  @override
  bool get hasEncounteredError => super.hasEncounteredError && !hasData;

  /// Returns true if the view model has loaded any data.
  ///
  /// This getter checks if the [dataList] is not empty, indicating that
  /// at least some data has been successfully loaded.
  bool get hasData => data.isNotEmpty;

  /// Returns the current page number.
  ///
  /// This getter provides read-only access to the current page number
  /// for debugging or UI display purposes.
  int get page => _page;

  /// Returns true if there are no more pages to load.
  ///
  /// This getter indicates whether the end of the paginated data has
  /// been reached, useful for disabling "load more" functionality.
  bool get noMorePages => _reachedMax;

  /// Returns an unmodifiable view of the loaded data.
  ///
  /// This getter provides a read-only view of all loaded data items.
  /// The returned list cannot be modified, ensuring data integrity.
  UnmodifiableListView<T> get data => UnmodifiableListView(dataList);

  /// Fetches data for the specified page.
  ///
  /// This abstract method must be implemented by subclasses to provide
  /// the actual data fetching logic. It should return a [DataResponse]
  /// containing either the data for the specified page or an error.
  ///
  /// [page] The page number to fetch data for.
  ///
  /// Returns a [DataResponse] containing the fetched data or an error.
  Future<DataResponse<Iterable<T>>> fetchData(int page);

  /// Refreshes the data by resetting pagination and loading the first page.
  ///
  /// This method resets the pagination state (sets page to 1 and clears
  /// the reached max flag) and then loads the first page of data.
  ///
  /// It's typically called when the user pulls to refresh or when the
  /// data source has been updated.
  ///
  /// Returns a [Future] that completes when the refresh operation is done.
  Future<void> refresh() {
    _page = 1;
    _reachedMax = false;
    return _fetchData();
  }

  /// Fetches the next page of data.
  ///
  /// This method loads the next page of data and appends it to the
  /// existing data list. It's typically called when the user scrolls
  /// to the bottom of a list or clicks a "load more" button.
  ///
  /// Returns a [Future] that completes when the fetch operation is done.
  Future<void> fetchMore() {
    return _fetchData();
  }

  /// Internal method that handles the data fetching logic.
  ///
  /// This method implements the common pagination logic:
  /// 1. Checks if the view model is busy or has reached the max pages
  /// 2. Sets the state to busy and calls the abstract [fetchData] method
  /// 3. Handles errors by calling [handleErrorAndSetVmState]
  /// 4. On success, clears the data list if it's the first page
  /// 5. Adds the new data to the list and increments the page number
  /// 6. Sets the reached max flag if no data was returned
  /// 7. Sets the state back to none
  ///
  /// This method is called by both [refresh] and [fetchMore] to provide
  /// consistent data fetching behavior.
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
