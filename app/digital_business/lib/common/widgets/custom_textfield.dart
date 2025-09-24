import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/constants/app_assets.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final words = newValue.text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() +
            (word.length > 1 ? word.substring(1).toLowerCase() : '');
      }
      return word;
    }).toList();
    final String newText = capitalizedWords.join(' ');

    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

// Custom TextFormField
class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? enabled;
  final bool showVerifyButton;
  final bool enableMaxLength;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool isSuffixIcon;
  final Widget? suffixIcon;
  final bool isPrefixIcon;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool showAddButton;
  final VoidCallback? onAddTap;
  final bool isVerified;
  final bool isLoading;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool forceLowerCase;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.validator,
    this.keyboardType,
    this.enabled,
    this.showVerifyButton = false,
    this.enableMaxLength = false,
    this.maxLength,
    this.inputFormatters,
    this.isSuffixIcon = false,
    this.showAddButton = false,
    this.isPrefixIcon = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.onAddTap,
    this.isVerified = false,
    this.isLoading = false,
    this.readOnly = false,
    this.maxLines,
    this.minLines = 1,
    this.forceLowerCase = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.textLightColor,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
      maxLength: maxLength,
      inputFormatters: [
        if (forceLowerCase)
          LowerCaseTextFormatter(),
        ...?inputFormatters,
      ],
      onChanged: (value) {
        if (onChanged != null) onChanged!(value);
        if (showAddButton) (context as Element).markNeedsBuild();
      },
      maxLines: maxLines,
      minLines: minLines, // Set minimum lines
      onTap: onTap,
      style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.textColor,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.borderColor,
            width: 1.w,
          ),
        ),
        suffixIcon: _buildSuffixIcon(context),
        prefixIcon: _buildPrefixIcon(context),
        hintText: hintText,
        hintStyle: TextStyle(
            color: AppColors.textLightColor.withOpacity(0.82),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 1.w,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
        errorText: errorText,
        counterText: enableMaxLength ? null : '',
      ),
    );
  }
  Widget? _buildSuffixIcon(BuildContext context) {
    if (!isSuffixIcon) return null;
    if (!showAddButton) return suffixIcon;

    final hasText = controller.text.trim().isNotEmpty;
    final isButtonEnabled = hasText && !isLoading;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 47.w,
        height: 25.h,
        child: Material(
          borderRadius: BorderRadius.circular(32.r),
          color: isButtonEnabled
              ? AppColors.primaryColor
              : AppColors.buttonDisableColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(32.r),
            onTap: isButtonEnabled ? onAddTap : null,
            child: Center(
              child: Text(
                'Add',
                style: TextStyle(
                  color: isButtonEnabled
                      ? AppColors.whiteColor
                      : AppColors.textFieldColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildPrefixIcon(BuildContext context) {
    if (!isPrefixIcon) return null;
    if (!showAddButton) return prefixIcon;

    final hasText = controller.text.trim().isNotEmpty;
    final isButtonEnabled = hasText && !isLoading;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 47.w,
        height: 25.h,
        child: Material(
          borderRadius: BorderRadius.circular(32.r),
          color: isButtonEnabled
              ? AppColors.primaryColor
              : AppColors.buttonDisableColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(32.r),
            onTap: isButtonEnabled ? onAddTap : null,
            child: Center(
              child: Text(
                'Add',
                style: TextStyle(
                  color: isButtonEnabled
                      ? AppColors.whiteColor
                      : AppColors.textFieldColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom TextFormField  Header
class CustomTextHeader extends StatelessWidget {
  final String? textHeader;
  final TextStyle? style;

  const CustomTextHeader({
    super.key,
    this.textHeader,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontFamily: 'DM Sans',
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      fontSize: 16.sp,
      height: 1.0,
      letterSpacing: 0.0,
      color: AppColors.textColor,
    );

    return Visibility(
      visible: textHeader != null,
      child: Text(
        textHeader ?? '',
        style: defaultStyle.merge(style),
      ),
    );
  }
}

//Custom Phone field
class CustomPhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Function(Country)? onCountryChanged;
  final bool enabled;
  final Map<String, int> countryPhoneLengths; // Added to pass the map

  const CustomPhoneField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.onCountryChanged,
    this.enabled = true,
    required this.countryPhoneLengths, // Required parameter
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  Country _selectedCountry = Country.parse('IN'); // Default to India
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _countryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCountryChanged?.call(_selectedCountry);
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _countryFocusNode.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
        widget.onCountryChanged?.call(country);
      },
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(10.r),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Search country',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Country get selectedCountry => _selectedCountry;

  @override
  Widget build(BuildContext context) {
    // Get the required length for the selected country, default to 10 if not found
    final requiredLength = widget.countryPhoneLengths[_selectedCountry.countryCode] ?? 10;

    return Row(
      children: [
        // Country code selector
        GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            width: 83.w,
            height: 45.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedCountry.flagEmoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
                Text(
                  '+${_selectedCountry.phoneCode}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textFieldInputColor,
                  ),
                ),
                SizedBox(width: 5.w),
                SvgPicture.asset(AppAssets.mobileNoDropdownIcon),
              ],
            ),
          ),
        ),
        SizedBox(width: 15.w),
        // Phone number field
        Expanded(
          child: Container(
            height: 45.h,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.textFieldInputColor,
              enabled: widget.enabled,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(requiredLength), // Dynamic length
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your mobile number';
                }
                if (!RegExp('^\\d{$requiredLength}\$').hasMatch(value)) {
                  return 'Please enter a valid $requiredLength-digit mobile number';
                }
                return null;
              },
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textFieldInputColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Enter $requiredLength digit phone number',
                hintStyle: TextStyle(
                  color: AppColors.textFieldColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.borderColor,
                    width: 1.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.borderColor,
                    width: 1.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.w,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14.h,
                  horizontal: 16.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.textLightColor,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      style: TextStyle(
        fontSize: 16.sp,
        color: AppColors.textColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.searchBorderColor.withOpacity(0.20),
          ),
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: prefixIcon,
        )
            : null,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textLightColor.withOpacity(0.82),
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.searchBorderColor.withOpacity(0.20),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: AppColors.searchBorderColor.withOpacity(0.20), // Same color for enabled state
            width: 1.0,
          ),
        ),
      ),
    );
  }
}