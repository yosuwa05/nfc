import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../../common/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class FollowersFollowingContainer extends StatefulWidget {
  final double height;
  final double width;
  final double radius;
  const FollowersFollowingContainer({
    super.key,
    this.height = 107,
    this.width = double.infinity,
    this.radius = 16,
  });

  @override
  State<FollowersFollowingContainer> createState() => _FollowersFollowingContainerState();
}

class _FollowersFollowingContainerState extends State<FollowersFollowingContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height.h,
      width: widget.width.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBFBFB), AppColors.whiteColor],
          stops: [1, 1.0],
          transform: GradientRotation(135 * 3.1415926535 / 180),
        ),
        borderRadius: BorderRadius.circular(widget.radius.r),
        border: const GradientBoxBorder(
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: _buildContent(),
    );
  }
  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56.h,
                width: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal:8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 24.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        color: AppColors.businessNameColor.withOpacity(0.09),
                      ),
                      child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w,vertical: 2.h),
                            child: Text("Business Name",style: TextStyle(color: AppColors.businessNameColor,fontSize: 12.sp,fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis),),
                          )
                      ),
                    ),
                    SizedBox(
                        width: 140.w,
                        child: Text("User Name",style: TextStyle(color: AppColors.textColor,fontSize: 20.sp,fontWeight: FontWeight.w600,overflow: TextOverflow.ellipsis),))
                  ],
                ),
              ),
              Spacer(),
              Text("01 Sep 2025",style: TextStyle(color: AppColors.dateFormatColor,fontSize: 14.sp,fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis),)
            ],
          ),
          Spacer(),
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.uploadIcon,
              ),
              SizedBox(width:8.w),
              SizedBox(width:250.w,child: Text("City Name : Kottar, nagercoil",style: TextStyle(color: AppColors.dateFormatColor,fontSize: 14.sp,fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis),))
            ],
          )
        ],
      ),
    );
  }
}
