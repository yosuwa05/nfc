import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabChanged;
  final int initialIndex;
  final List<int?>? overallCounts;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.onTabChanged,
    this.initialIndex = 0,
    this.overallCounts,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: widget.tabs.length,
        itemBuilder: (context, index) {
          final textStyle = TextStyle(
            color: _selectedIndex == index
                ? AppColors.primaryColor
                : AppColors.textLightColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          );

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onTabChanged(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedIndex == index
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 30.w, // Ensure minimum width
                  ),
                  child: Text(
                    widget.overallCounts != null
                        ? '${widget.overallCounts![index]} ${widget.tabs[index]}'
                        : widget.tabs[index],
                    style: textStyle.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: _selectedIndex == index
                          ? AppColors.primaryColor
                          : AppColors.textLightColor,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              )
            ),
          );
        },
      ),
    );
  }
}