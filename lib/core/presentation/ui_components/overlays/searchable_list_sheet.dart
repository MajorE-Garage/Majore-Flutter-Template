import 'package:flutter/material.dart';

import '../../presentation.dart';

class SearchableListSheet<T> extends AppBottomSheet<T> {
  SearchableListSheet({
    super.key,
    required Set<T> dataList,
    required Set<T> Function(String query) searchQuery,
    required Widget Function(BuildContext context, T item) itemBuilder,
    T? currentValue,
    Listenable? listenable,
    super.heading,
  }) : super(
         builder: (ctx) => _SearchableListSheet(
           dataList: dataList,
           searchQuery: searchQuery,
           itemBuilder: itemBuilder,
           currentValue: currentValue,
           listenable: listenable,
         ),
       );
}

class _SearchableListSheet<T> extends StatefulWidget {
  const _SearchableListSheet({
    super.key,
    required this.dataList,
    required this.searchQuery,
    required this.itemBuilder,
    this.currentValue,
    this.listenable,
  });

  final T? currentValue;
  final Set<T> dataList;
  final Set<T> Function(String query) searchQuery;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Listenable? listenable;

  @override
  State<_SearchableListSheet<T>> createState() => _SearchableListSheetState<T>();
}

class _SearchableListSheetState<T> extends State<_SearchableListSheet<T>> {
  late Set<T> _dataList;
  final _controller = TextEditingController();
  @override
  void initState() {
    _dataList = widget.dataList;
    widget.listenable?.addListener(_listener);
    super.initState();
  }

  void _filter(String query) {
    setState(() {
      _dataList = widget.searchQuery(query);
    });
  }

  @override
  void dispose() {
    widget.listenable?.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(controller: _controller, onChanged: _filter, hint: 'Type to search...'),
        const SizedBox(height: 8),
        for (final item in _dataList)
          InkWell(
            onTap: () => AppNavigator.of(context).pop(item),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 56, minHeight: 48),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: item == widget.currentValue ? AppColors.of(context).grey600 : null),
              child: widget.itemBuilder(context, item),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }
}
