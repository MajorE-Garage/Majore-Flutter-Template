import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.hint,
    required this.controller,
    this.onChanged,
    this.onTap,
    this.onEditComplete,
    this.autoFocus = false,
    this.clearCallback,
  });
  final bool autoFocus;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditComplete;
  final VoidCallback? onTap;
  final VoidCallback? clearCallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;
    final enabled = controller != null;
    final field = TextFormField(
      enabled: enabled,
      controller: controller,
      autofocus: autoFocus,
      onChanged: onChanged,
      onTap: onTap,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.only(bottom: 40),
      onEditingComplete: onEditComplete ?? () => FocusScope.of(context).unfocus(),
      style: styles.value16Medium,
      textAlignVertical: TextAlignVertical.center,
      cursorColor: colors.grey800,
      cursorWidth: 1,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint ?? 'Search',
        hintMaxLines: 1,
        filled: true,
        fillColor: colors.grey100,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.search_rounded, color: colors.grey700, size: 16)],
          ),
        ),
        suffix: clearCallback != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIconButton.fromIconData(
                    label: 'Clear',
                    view: 'Search Field',
                    circled: false,
                    iconSize: 16,
                    icon: Icons.close_rounded,
                    iconColor: colors.grey700,
                    onPressed: clearCallback!,
                  ),
                ],
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        errorStyle: styles.body14Medium.copyWith(color: colors.attitudeErrorMain, height: 1),
        hintStyle: styles.caption12Regular.copyWith(color: colors.grey700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(width: 1, color: colors.grey500),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(width: 1, color: colors.grey500),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(width: 1, color: colors.grey500),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(width: 0.8, color: colors.primaryColor.withAlpha(128)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(width: 1, color: colors.attitudeErrorMain),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(width: 1, color: colors.attitudeErrorMain),
        ),
      ),
    );

    if (enabled) {
      return field;
    } else {
      return GestureDetector(onTap: onTap, child: field);
    }
  }
}
