import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/constants/app_assets.dart';
import '../../ui/create_card/attach_links_screen.dart';
import '../theme/app_colors.dart';
import 'custom_appbar.dart';

class CustomStyledPage extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final bool customLinkButton;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Color backgroundColor;
  final bool showTitle;

  const CustomStyledPage({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.customLinkButton = false,
    this.onBackPressed,
    this.backgroundColor = Colors.white,
    this.showTitle = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background blur effects
          Positioned(
            top: 37.h,
            left: 128.w,
            right: 127.w,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 250.r,
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
            right: 250.w,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                  BoxShadow(
                  blurRadius: 250.r,
                  spreadRadius: 1.r,
                  color: AppColors.bottomLeftColor,
                  offset: Offset(0, 10.h),
                  )
                  ],
                ),
              ),
            ),
          ),

          if (customLinkButton)
            Positioned(
              top: 60,
              right: 16,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (BuildContext context) {
                      return const CustomLinkBottomSheet();
                    },
                  );
                },

                child: Center(
                  child: Row(
                    children: [
                      Icon(Icons.add, color: AppColors.primaryColor),
                      SizedBox(width: 2.w),
                      Text(
                        "Custom Link",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (showBackButton)
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap:  onBackPressed ?? () => Navigator.of(context).pop(),
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
          ),
          if (showTitle && title != null)
            Positioned(
              top: 80.h,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeaderColor,
                      ),
                    ),
                    SizedBox(height: 11.h,),
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
            ),
          // The actual page content
          child,
        ],
      ),
    );
  }
}