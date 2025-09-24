import 'dart:ui';
import 'package:digital_business/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Color backgroundColor;

  const CustomAppbar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBackPressed,
    this.showBackButton = true,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leadingWidth: 50.w,
      leading: showBackButton
          ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: onBackPressed ?? () => Navigator.pop(context),
              child: Container(
                width: 34.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1.w,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.backButtonIcon,
                    width: 7.w,
                    height: 12.h,
                  ),
                ),
              ),
            ),
          )
          : null,
      title: Padding(
        padding: EdgeInsets.only(top: 25.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeaderColor,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor,
                ),
              ),
          ],
        ),
      ),
      centerTitle: false,
      flexibleSpace: Stack(
        children: [
          // Background blur effects
          Positioned(
            top: 37.h,
            left: 128.w,
            right: 127.w,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 200.r,
                      spreadRadius: 1.r,
                      color: AppColors.appBarCenterColor,
                      offset: Offset(0, 10.h),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -20.w,
            right: 200.w,
            top: 600.h,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 160.r,
                      spreadRadius: 1.r,
                      color: AppColors.bottomLeftColor,
                      offset: Offset(0, 10.h),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(311.h);
}