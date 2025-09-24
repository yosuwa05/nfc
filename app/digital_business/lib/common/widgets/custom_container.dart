import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainer extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final double height;
  final double width;
  final double radius;
  final Color containerColor;
  final Color containerBorderColor;
  final Color textColor;
  final bool isOutline;
  final bool filled;
  final int fontSize;
  final Widget? child;
  final Widget? icon;
  final bool iconLeft;
  final double iconGap;

  const CustomContainer({
    super.key,
    required this.title,
    required this.onTap,
    required this.height,
    required this.width,
    required this.radius,
    required this.containerColor,
    required this.textColor,
    required this.containerBorderColor,
    this.isOutline = false,
    this.filled = true,
    this.fontSize = 16,
    this.child,
    this.icon,
    this.iconLeft = true,
    this.iconGap = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: filled ? containerColor : containerColor,
          borderRadius: BorderRadius.circular(radius.r),
          border: Border.all(
            color: isOutline ? containerBorderColor : containerBorderColor,
            width: 1.w,
          ),
        ),
        height: height.h,
        width: width.w,
        child: Center(
          child: child ?? _buildContent(),
        ),
      ),
    );
  }
  Widget _buildContent() {
    if (icon == null) {
      return Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconLeft) icon!,
        if (iconLeft) SizedBox(width: iconGap.w),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!iconLeft) SizedBox(width: iconGap.w),
        if (!iconLeft) icon!,
      ],
    );
  }
}
