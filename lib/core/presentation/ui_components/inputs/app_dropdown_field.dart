import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppDropdownField<T> extends StatefulWidget {
  const AppDropdownField({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.enabled = true,
    this.onChanged,
    this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.onTap,
    this.icon,
    this.validatorMode = AutovalidateMode.disabled,
  });

  final DropdownValueController<T> controller;
  final Widget Function(T item) itemBuilder;
  final String? label;
  final String? hint;
  final bool isRequired;
  final bool enabled;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final AutovalidateMode validatorMode;
  final String? Function(T?)? validator;
  final Widget? icon;

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  final _errorNotifier = ValueNotifier<String?>(null);
  late final FocusNode _focusNode;

  bool _sheetIsOpen = false;
  @override
  void initState() {
    widget.controller.addListener(listener);
    _focusNode = FocusNode(
      canRequestFocus: true,
      skipTraversal: false,
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
    );
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    setState(() {});
  }

  String? _validator(T? value) {
    final hasValidator = widget.validator != null;
    String? error;
    if (!hasValidator && widget.isRequired && (value == null)) {
      error = 'This field is required';
    }

    if (hasValidator) {
      error = widget.validator!(value);
    }
    Future.delayed(Duration.zero, () => _errorNotifier.value = error);
    return error != null ? '' : null;
  }

  Future<void> _showSelectionSheet(BuildContext context) async {
    AppBottomSheet selectionSheet;

    if (widget.controller._searchable) {
      selectionSheet = SearchableListSheet<T>(
        heading: widget.label,
        dataList: widget.controller.options.toSet(),
        searchQuery: widget.controller.searchOptions,
        itemBuilder: (context, item) => Container(
          constraints: const BoxConstraints(maxHeight: 56, minHeight: 48),
          padding: const EdgeInsets.only(left: 16, right: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: item == widget.controller.value ? AppColors.of(context).grey600 : null,
          ),
          child: widget.itemBuilder(item),
        ),
      );
    } else {
      selectionSheet = AppBottomSheet<T>(
        heading: widget.label,
        padding: const EdgeInsets.all(16),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (T item in widget.controller.options)
              InkWell(
                onTap: () => AppNavigator.of(context).pop(item),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 56, minHeight: 48),
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: item == widget.controller.value ? AppColors.of(context).grey600 : null,
                  ),
                  child: widget.itemBuilder(item),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    _sheetIsOpen = true;
    final selection = await selectionSheet.show(
      context: context,
      routeName: 'Dropdown(${widget.label})',
      isScrollControlled: true,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      _sheetIsOpen = false;
      listener();
    });

    if (widget.onChanged != null) widget.onChanged!(selection);
    if (selection != null) {
      widget.controller.value = selection;
      _focusNode.nextFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppStyles.of(context);

    final value = widget.controller.value;
    final isFocused = _focusNode.hasFocus;
    return GestureDetector(
      onTap: () async {
        if (isFocused) {
          _showSelectionSheet(context);
        } else {
          _focusNode.requestFocus();
        }
        if (widget.onTap != null) widget.onTap!();
      },
      child: Focus.withExternalFocusNode(
        focusNode: _focusNode,
        key: ObjectKey(widget.label),
        autofocus: false,
        onFocusChange: (focused) {
          if (focused && !_sheetIsOpen) {
            _showSelectionSheet(context);
          }
          listener();
        },
        child: ValueListenableBuilder(
          valueListenable: _errorNotifier,
          builder: (_, error, __) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(widget.label!, style: styles.label14Regular),
                ),
              Container(
                constraints: const BoxConstraints.tightFor(height: 56),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: isFocused
                        ? 1.2
                        : error != null
                        ? 1
                        : 0.5,
                    color: error != null
                        ? colors.attitudeErrorMain
                        : isFocused
                        ? colors.grey700
                        : colors.grey600,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: value != null
                          ? widget.itemBuilder(value)
                          : widget.hint != null
                          ? Text(widget.hint!, style: styles.caption12Regular)
                          : const SizedBox.shrink(),
                    ),
                    widget.icon ??
                        AppIconButton(
                          label: 'Dropdown',
                          view: 'Dropdown Field',
                          circled: false,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.of(context).grey700,
                            size: 24,
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Offstage(
                child: TextFormField(
                  autofocus: false,
                  readOnly: true,
                  enabled: false,
                  validator: (_) => _validator(value),
                  decoration: const InputDecoration(
                    isDense: true,
                    errorStyle: TextStyle(height: 1, fontSize: 1, color: Colors.transparent),
                  ),
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    error,
                    style: styles.body14Medium.copyWith(color: colors.attitudeErrorMain, height: 1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownValueController<T> extends ValueNotifier<T?> {
  DropdownValueController({T? initialValue, List<T> options = const []})
    : _options = options.toSet(),
      _searchable = false,
      _searchQueryHandler = null,
      super(initialValue);

  DropdownValueController.searchable({
    T? initialValue,
    List<T> options = const [],
    required Set<T> Function(String query, Set<T> options) searchQueryHandler,
  }) : _options = options.toSet(),
       _searchable = true,
       _searchQueryHandler = searchQueryHandler,
       super(initialValue);

  Set<T> _options;
  final bool _searchable;
  final Set<T> Function(String query, Set<T> options)? _searchQueryHandler;

  Set<T> searchOptions(String query) {
    if (_searchQueryHandler != null) {
      return _searchQueryHandler(query, _options);
    }
    if (T is String) {
      return _options.where((option) => (option as String).contains(query)).toSet();
    }
    return _options;
  }

  Iterable<T> get options => _options;

  set options(Iterable<T> val) {
    _options = val.toSet();
    notifyListeners();
  }

  void clear() {
    value = null;
  }
}
