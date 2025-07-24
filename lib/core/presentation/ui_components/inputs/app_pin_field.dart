import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/presentation.dart';
import '../../../../utilities/mixins/device_clipboard_mixin.dart';

class AppPinField extends StatefulWidget {
  final int count;
  final double size;
  final double fontSize;
  final ValueSetter<String>? onComplete;
  final TextEditingController? controller;
  final TextInputType textInputType;
  final bool obscureText;

  const AppPinField({
    super.key,
    required this.count,
    this.size = 56,
    this.fontSize = 20,
    required this.onComplete,
    this.controller,
    this.obscureText = true,
    this.textInputType = TextInputType.text,
  });

  @override
  AppPinFieldState createState() => AppPinFieldState();
}

class AppPinFieldState extends State<AppPinField> with DeviceClipboardMixin {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    super.initState();
  }

  void clear() {
    _controller.clear();
  }

  void _onPinChanged(String value) async {
    if (value.length == widget.count && widget.onComplete != null) {
      widget.onComplete!(value);
    }
    setState(() {});
  }

  void _pasteCode() async {
    final clipboard = await pasteFromClipboard();
    final pin = (clipboard ?? '').substring(0, widget.count);
    _controller.text = pin;
    _onPinChanged(pin);
  }

  @override
  Widget build(BuildContext context) {
    final pinCodeFields = Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PinCodeBoxArray(
            count: widget.count,
            controller: _controller,
            obscure: widget.obscureText,
            size: widget.size,
            fontSize: widget.fontSize,
          ),
          Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.transparent,
                selectionColor: Colors.transparent,
                selectionHandleColor: Colors.transparent,
              ),
            ),
            child: TextFormField(
              obscureText: true,
              obscuringCharacter: ' ',
              maxLength: widget.count,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              // toolbarOptions: ToolbarOptions(
              //   paste: !widget.obscureText,
              // ),
              controller: _controller,
              keyboardType: widget.textInputType,
              enableInteractiveSelection: !widget.obscureText,
              style: const TextStyle(
                fontSize: 1,
                color: Colors.transparent,
              ),
              textAlign: TextAlign.center,
              showCursor: false,
              autofocus: true,
              decoration: InputDecoration(
                counter: const SizedBox.shrink(),
                constraints: BoxConstraints.tightFor(height: widget.size),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              onChanged: _onPinChanged,
            ),
          ),
        ],
      ),
    );

    if (widget.obscureText) {
      return pinCodeFields;
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          pinCodeFields,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkResponse(
              onTap: _pasteCode,
              child: Text(
                'Paste Code',
                textAlign: TextAlign.center,
                style: AppStyles.of(context).body14SemiBold.copyWith(
                      color: AppColors.of(context).primaryColor,
                    ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class _PinCodeBoxArray extends StatelessWidget {
  const _PinCodeBoxArray({
    required this.count,
    required this.controller,
    required this.obscure,
    required this.size,
    required this.fontSize,
  });

  final int count;
  final TextEditingController controller;
  final bool obscure;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final focusIndex = controller.text.length;
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < count; i++)
            _PinCodeBox(
              text: i >= focusIndex ? null : controller.text[i],
              focus: focusIndex == i,
              obscure: obscure,
              size: size,
              fontSize: fontSize,
            ),
        ],
      ),
    );
  }
}

class _PinCodeBox extends StatelessWidget {
  const _PinCodeBox({
    this.text,
    required this.focus,
    required this.obscure,
    required this.size,
    required this.fontSize,
  }) : assert(text == null || text.length <= 1);

  final String? text;
  final bool focus;
  final bool obscure;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    String display;
    final isBlank = text == null;
    if (isBlank) {
      display = '';
    } else if (obscure) {
      display = '●';
    } else {
      display = text!;
    }
    final colors = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: size,
      width: size,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.overlayBackground,
        border: Border.all(
          color: focus || !isBlank ? colors.grey600 : colors.primaryColor,
          width: focus && isBlank ? 0.5 : 2,
          style: BorderStyle.solid,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          isBlank ? '-' : display,
          style: AppStyles.of(context).heading20Bold.copyWith(
                fontSize: fontSize,
              ),
        ),
      ),
    );
  }
}
