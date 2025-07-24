import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/presentation.dart';
import 'app_dropdown_field.dart';
import 'app_text_field.dart';

class AppPhoneNumberField extends StatefulWidget {
  const AppPhoneNumberField({
    super.key,
    required this.controller,
    this.validator,
    this.isRequired = false,
    this.label,
    this.hint,
    this.suffix,
    this.keyboardAction = TextInputAction.next,
    this.onEditComplete,
    this.enabled = true,
    this.onChanged,
    this.formatters = const [],
  });

  final PhoneInputController controller;
  final String? label;
  final String? hint;
  final bool isRequired;
  final String? Function(String? number, PhoneCountryModel? country)? validator;
  final Widget? suffix;
  final TextInputAction keyboardAction;
  final VoidCallback? onEditComplete;
  final bool enabled;
  final List<TextInputFormatter> formatters;
  final ValueChanged<String>? onChanged;

  @override
  State<AppPhoneNumberField> createState() => _AppPhoneNumberFieldState();
}

class _AppPhoneNumberFieldState extends State<AppPhoneNumberField> {
  late PhoneInputController controller;
  String? _errorText;

  @override
  void initState() {
    controller = widget.controller;
    controller.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }

  void _listener() => setState(() {});

  String? _validator() {
    final hasValidator = widget.validator != null;
    final country = controller.country.value;
    final phone = controller.phone.text;
    String? error;
    if (!hasValidator &&
        widget.isRequired &&
        (country == null || phone.isEmpty)) {
      error = 'This field is required';
    }

    if (hasValidator) {
      error = widget.validator!(phone, country);
    }
    _errorText = error;
    _listener();
    return error != null ? '' : null;
  }

  @override
  Widget build(BuildContext context) {
    final styles = AppStyles.of(context);
    final colors = AppColors.of(context);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.label!,
                  style: styles.label14Regular,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width * 0.24)
                      .clamp(104.0, 144.0),
                  child: AppDropdownField<PhoneCountryModel>(
                    controller: controller.country,
                    itemBuilder: (country) => FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${country.flag}${country.phoneCode}',
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                        style: styles.value16Medium,
                      ),
                    ),
                    validator: (_) => _validator(),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    controller: controller.phone,
                    label: null,
                    hint: widget.hint,
                    validator: (_) => _validator(),
                    keyboardType: TextInputType.phone,
                    keyboardAction: widget.keyboardAction,
                    onEditComplete: widget.onEditComplete,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ...widget.formatters,
                    ],
                    isRequired: false,
                    suffix: widget.suffix,
                    enabled: widget.enabled,
                    onChanged: widget.onChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_errorText != null)
          Positioned(
            bottom: 0,
            left: 16,
            child: Text(
              _errorText!,
              style: styles.body14Medium.copyWith(
                color: colors.attitudeErrorMain,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class PhoneCountryModel {
  final String name;
  final String iso2;
  final String _phoneCode;

  PhoneCountryModel({
    required this.name,
    required this.iso2,
    required String phoneCode,
  }) : _phoneCode = phoneCode;

  factory PhoneCountryModel.fromMap(Map<String, dynamic> map) {
    return PhoneCountryModel(
      name: map['name'],
      iso2: map['iso2'],
      phoneCode: map['phone_code'],
    );
  }
  String get phoneCode => '+$_phoneCode';
  String get flag => String.fromCharCodes([
        127365 + iso2.toLowerCase().codeUnitAt(0),
        127365 + iso2.toLowerCase().codeUnitAt(1),
      ]);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iso2': iso2,
      'phone_code': _phoneCode,
    };
  }
}

class PhoneInputController extends ChangeNotifier {
  PhoneInputController();

  final phone = TextEditingController();
  final country = DropdownValueController<PhoneCountryModel>.searchable(
      searchQueryHandler: (query, countries) {
    final searchQuery = query.toLowerCase();
    final startsWithQuery = countries.where(
      (country) =>
          country.name.toLowerCase().startsWith(searchQuery) ||
          country.phoneCode.startsWith(searchQuery),
    );

    final containsQuery = countries.where(
      (country) =>
          country.name.toLowerCase().contains(searchQuery) ||
          country.phoneCode.contains(searchQuery),
    );

    final filteredList = startsWithQuery.followedBy(containsQuery).toSet();
    return filteredList;
  });

  void addCountries(Iterable<PhoneCountryModel> countries) {
    country.options = country.options.toList()..addAll(countries);
    notifyListeners();
  }
}
