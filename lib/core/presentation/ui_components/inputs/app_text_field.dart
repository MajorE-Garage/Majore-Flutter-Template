import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/presentation.dart';
import '../buttons/app_icon_button.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.fieldKey,
    required this.controller,
    this.label,
    this.hint,
    this.isRequired = false,
    this.focusNode,
    this.onFocusChange,
    this.autoFocus = false,
    this.onChanged,
    this.onTap,
    this.onEditComplete,
    this.validator,
    this.validatorMode = AutovalidateMode.disabled,
    this.prefixText,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.keyboardAction = TextInputAction.next,
    this.capitalization = TextCapitalization.sentences,
    this.keyboardPadding = 40,
    this.enabled = true,
    this.formatters,
    this.maxLines = 1,
  }) : _isSecret = false,
       obscuringCharacter = '•';

  const AppTextField.secret({
    super.key,
    this.fieldKey,
    required this.controller,
    this.label,
    this.hint,
    this.isRequired = false,
    this.focusNode,
    this.onFocusChange,
    this.autoFocus = false,
    this.onChanged,
    this.onTap,
    this.onEditComplete,
    this.validator,
    this.validatorMode = AutovalidateMode.disabled,
    this.prefixText,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.keyboardAction = TextInputAction.next,
    this.capitalization = TextCapitalization.none,
    this.keyboardPadding = 40,
    this.enabled = true,
    this.formatters,
    this.obscuringCharacter = '•',
  }) : _isSecret = true,
       suffix = null,
       maxLines = 1;

  final Key? fieldKey;
  final String? label;
  final String? hint;
  final bool isRequired;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool autoFocus;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditComplete;
  final AutovalidateMode validatorMode;
  final String? Function(String)? validator;
  final String? prefixText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType keyboardType;
  final TextInputAction keyboardAction;
  final TextCapitalization capitalization;
  final double keyboardPadding;
  final bool enabled;
  final List<TextInputFormatter>? formatters;
  final String obscuringCharacter;
  final int maxLines;
  final bool _isSecret;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  late bool _visible;

  @override
  void initState() {
    _visible = !widget._isSecret;
    _focusNode = widget.focusNode ?? FocusNode();
    final focusChangeCallback = widget.onFocusChange;
    if (focusChangeCallback != null) {
      _focusNode.addListener(() => focusChangeCallback(_focusNode.hasFocus));
    }
    super.initState();
  }

  void _toggleVisibility() {
    setState(() {
      _visible = !_visible;
    });
  }

  String? _validator(String? value) {
    final hasValidator = widget.validator != null;
    String? error;
    if (!hasValidator && widget.isRequired && (value == null || value.isEmpty)) {
      if (widget.label != null) {
        error = '${widget.label} is required';
      } else {
        error = 'This field is required';
      }
    }

    if (hasValidator) {
      error = widget.validator!(value ?? '');
    }

    return error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(widget.label!, style: styles.label14Regular),
          ),
        TextFormField(
          key: widget.fieldKey,
          focusNode: _focusNode,
          autofocus: widget.autoFocus,
          enabled: widget.enabled,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.keyboardAction,
          textCapitalization: widget.capitalization,
          obscureText: !_visible,
          obscuringCharacter: widget.obscuringCharacter,
          scrollPadding: EdgeInsets.only(bottom: widget.keyboardPadding),
          validator: _validator,
          autovalidateMode: widget.validatorMode,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditComplete ?? () => FocusScope.of(context).nextFocus(),
          style: styles.value16Medium.copyWith(letterSpacing: (!_visible && widget.controller.text.isNotEmpty) ? 7 : 0),
          inputFormatters: widget.formatters,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: colors.grey800,
          cursorWidth: 1,
          maxLines: widget.maxLines,
          minLines: 1,
          decoration: InputDecoration(
            isDense: false,
            hintText: widget.hint,
            hintMaxLines: 1,
            prefixText: widget.prefixText != null ? '${widget.prefixText} ' : null,
            prefixIcon: widget.prefix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [widget.prefix!]),
                  ),
            suffixIcon: !widget._isSecret && widget.suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 16, left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget._isSecret)
                          ExcludeFocus(
                            child: AppIconButton.fromIconData(
                              icon: _visible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                              onPressed: _toggleVisibility,
                              circled: false,
                            ),
                          )
                        else
                          widget.suffix!,
                      ],
                    ),
                  ),
            contentPadding: const EdgeInsets.all(16),
            errorStyle: styles.body14Medium.copyWith(color: colors.attitudeErrorMain, height: 1),
            hintStyle: styles.caption12Regular.copyWith(color: colors.textColor.withOpacity(0.5)),
            prefixStyle: styles.value16Medium.copyWith(color: colors.textColor.withOpacity(0.8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 0.5, color: colors.grey600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 0.5, color: colors.grey600),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1.2, color: colors.primaryColor.withOpacity(0.5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1, color: colors.attitudeErrorMain),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1, color: colors.attitudeErrorMain),
            ),
          ),
        ),
      ],
    );
  }
}
