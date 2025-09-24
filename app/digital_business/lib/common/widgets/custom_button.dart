import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final double radius;
  final Color color;
  final Color textColor;
  final bool isOutline;
  final bool filled;
  final double fontSize;
  final FontWeight fontWeight;
  final Widget? child;
  final Widget? icon;
  final bool iconLeft;
  final double iconGap;
  final EdgeInsetsGeometry? padding;
  final bool expanded;

  const CustomButton({
    super.key,
    required this.title,
    this.onTap,
    this.height = 50,
    this.width,
    this.radius = 10,
    this.color = AppColors.primaryColor,
    this.textColor = Colors.white,
    this.isOutline = false,
    this.filled = true,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.child,
    this.icon,
    this.iconLeft = true,
    this.iconGap = 8,
    this.padding,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = _buildButtonContent();

    return SizedBox(
      width: expanded ? double.infinity : width?.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius.r),
          child: Ink(
            decoration: BoxDecoration(
              color: filled ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(radius.r),
              border: Border.all(
                color: isOutline ? color : Colors.transparent,
                width: 1.w,
              ),
            ),
            padding: padding ?? EdgeInsets.symmetric(vertical: 16.h),
            height: height?.h,
            child: Center(child: buttonContent),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (child != null) return child!;

    final textWidget = Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
      ),
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconLeft) icon!,
        if (iconLeft) SizedBox(width: iconGap.w),
        textWidget,
        if (!iconLeft) SizedBox(width: iconGap.w),
        if (!iconLeft) icon!,
      ],
    );
  }
}