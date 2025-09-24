import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pin_code;
import 'package:pinput/pinput.dart' as pinput;

import '../../../common/theme/app_colors.dart';

Widget buildPinField(
    BuildContext context,
    TextEditingController controller, {
      String? Function(String?)? validator,
      Function(String)? onChanged,
      TextEditingController? otherController,
      int length = 4,
      bool isplaceHolder = false,
      bool enabled = true,
      bool hasError = false,
    }) {
  return pin_code.PinCodeTextField(
    appContext: context,
    length: length,
    controller: controller,
    keyboardType: TextInputType.number,
    obscureText: false,
    animationType: pin_code.AnimationType.fade,
    cursorHeight: 16.h,
    validator: validator,
    enabled: enabled,
    readOnly: !enabled,
    autoFocus: true,
    enablePinAutofill: true,
    obscuringWidget: isplaceHolder
        ? Container(
      height: 10.h,
      width: 10.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textFieldInputColor,
      ),
    )
        : null,
    pinTheme: pin_code.PinTheme(
      shape: pin_code.PinCodeFieldShape.box,
      borderRadius: BorderRadius.circular(8.r),
      fieldHeight: 50.h,
      fieldWidth: 48.w,
      borderWidth: 1.w,
      inactiveColor: hasError
          ? Colors.red.withOpacity(0.3)
          : enabled
          ? AppColors.borderColor
          : AppColors.borderColor.withOpacity(0.5),
      activeColor: hasError
          ? Colors.red
          : enabled
          ? AppColors.borderColor
          : AppColors.borderColor.withOpacity(0.5),
      selectedColor: hasError
          ? Colors.red
          : enabled
          ? AppColors.primaryColor
          : AppColors.primaryColor.withOpacity(0.5),
      inactiveFillColor:
      enabled ? AppColors.containerColor : AppColors.containerColor.withOpacity(0.7),
      activeFillColor:
      enabled ? AppColors.containerColor : AppColors.containerColor.withOpacity(0.7),
      selectedFillColor:
      enabled ? AppColors.containerColor : AppColors.containerColor.withOpacity(0.7),
      errorBorderColor: Colors.red,
    ),
    cursorColor: enabled
        ? AppColors.textFieldInputColor
        : AppColors.textFieldInputColor.withOpacity(0.5),
    textStyle: TextStyle(
      fontSize: 20.sp,
      color: enabled
          ? (hasError ? Colors.red : AppColors.textFieldInputColor)
          : AppColors.textFieldInputColor.withOpacity(0.5),
      fontWeight: FontWeight.w600,
    ),
    animationDuration: const Duration(milliseconds: 300),
    enableActiveFill: true,
    errorTextSpace: 20.h,
    onChanged: (value) {
      // Call the custom onChanged callback if provided
      if (onChanged != null) {
        onChanged(value);
      }

      // Keep the original functionality for otherController
      if (otherController != null) {
        (context as Element).markNeedsBuild();
      }
    },
    onCompleted: (value) {
      // Additional callback when PIN is completed (optional)
      if (onChanged != null) {
        onChanged(value);
      }
    },
  );
}