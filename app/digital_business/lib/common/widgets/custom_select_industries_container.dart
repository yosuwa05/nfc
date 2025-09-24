import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../theme/app_colors.dart';

class CustomSelectIndustriesContainer extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  final double? height;
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
  final bool showCheckbox;
  final bool initiallyChecked;
  final bool? isChecked; // Add this as optional parameter
  final double minExpandedHeight;
  final double maxExpandedHeight;

  const CustomSelectIndustriesContainer({
    super.key,
    required this.title,
    required this.onTap,
    this.height,
    required this.width,
    required this.radius,
    required this.containerColor,
    required this.textColor,
    required this.containerBorderColor,
    this.isOutline = false,
    this.filled = true,
    this.fontSize = 18,
    this.child,
    this.icon,
    this.iconLeft = true,
    this.iconGap = 8,
    this.showCheckbox = false,
    this.initiallyChecked = false,
    this.isChecked, // Add this parameter properly
    this.minExpandedHeight = 168,
    this.maxExpandedHeight = 400,
  });

  @override
  State<CustomSelectIndustriesContainer> createState() => _CustomSelectIndustriesContainerState();
}

class _CustomSelectIndustriesContainerState extends State<CustomSelectIndustriesContainer>
    with SingleTickerProviderStateMixin {
  late bool _isChecked;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initiallyChecked;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: widget.height ?? 56.0,
      end: widget.minExpandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_isChecked) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomSelectIndustriesContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update checkbox state when isChecked prop changes
    if (widget.isChecked != null && widget.isChecked != _isChecked) {
      setState(() {
        _isChecked = widget.isChecked!;
      });

      if (_isChecked) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCheckbox() {
    setState(() {
      _isChecked = !_isChecked;
    });

    if (_isChecked) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.showCheckbox) {
          _toggleCheckbox();
        }
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFFBFBFB), AppColors.whiteColor],
                stops: [1, 1.0],
                transform: const GradientRotation(135 * 3.1415926535 / 180),
              ),
              borderRadius: BorderRadius.circular(widget.radius.r),
              border: _isChecked ? const GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0.8),
                    Color.fromRGBO(200, 202, 213, 0.168),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ),
                width: 3,
              ): const GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0.8),
                    Color.fromRGBO(200, 202, 213, 0.168),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ),
                width: 3,
              ),
            ),
            height: _isChecked ? _heightAnimation.value.h : (widget.height ?? 56.0).h,
            width: widget.width.w,
            child: _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section with fixed height
          Container(
            height: (widget.height ?? 56.0).h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left content
                Expanded(
                  child: Row(
                    children: [
                      if (widget.iconLeft && widget.icon != null) widget.icon!,
                      if (widget.iconLeft && widget.icon != null)
                        SizedBox(width: widget.iconGap.w),
                      Flexible(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: widget.fontSize.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkbox
                if (widget.showCheckbox) ...[
                  SizedBox(width: 8.w),
                  Container(
                    width: 18.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: _isChecked ? widget.containerBorderColor : Colors.transparent,
                      border: Border.all(
                        color: _isChecked ? widget.containerBorderColor : AppColors.primaryColor,
                        width: 1.0,
                      ),
                    ),
                    child: _isChecked
                        ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                        : null,
                  ),
                ],
              ],
            ),
          ),
          // Content area - only show when checked
          if (_isChecked && widget.child != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}