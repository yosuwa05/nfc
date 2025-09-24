import 'package:digital_business/common/widgets/custom_button.dart';
import 'package:digital_business/ui/home/widgets/home_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/helper/app_routes.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_styled_page.dart';
import '../../core/constants/app_assets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isQRCode = false;

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlayStyle();
  }

  void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8112FF).withOpacity(0.2),
              Color(0xFFDED5FF).withOpacity(0.05),
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.white,
            ],
            stops: [0.0, 0.2, 0.5, 0.7, 0.9, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 10.h),
                  _buildStatsSection(),
                  SizedBox(height: 25.h),
                  Text(
                    "Welcome to Digital Business",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Stack(
                    children: [
                      Container(
                      height: 319.h,
                      width: 319.w,
                      decoration: BoxDecoration(
                        color: AppColors.appBarCenterColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            height: 65.25.h,
                            width: 65.25.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: BoxShape.circle
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ),
                  SizedBox(height: 20.h),
                  CustomButton(
                    title: 'Scan QR Code',
                    fontSize: 16.sp,
                    height: 46.h,
                    icon: SvgPicture.asset(AppAssets.scanIcon,height: 18.h,width: 18.w,),
                    iconGap: 30.w,
                    onTap: (){},
                  ),
                  SizedBox(height: 15.h),
                  _buildActionContainer()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
            ),
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(width: 16.w),

        // Name and Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mohammed Fazil',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'App Developer',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Action Icons
        Row(
          children: [
          GestureDetector(
            onTap: (){},
            child: SvgPicture.asset(
                AppAssets.profileViewIcon,
              width: 26.w,
              height: 26.h,
              ),
          ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: (){},
              child: SvgPicture.asset(
                AppAssets.accountSwitchIcon,
                width: 26.w,
                height: 26.h,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 52.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(7.r),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.r,
                color: AppColors.boxShadowColor.withOpacity(0.25),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: (){
              print('share');

            },
              child: _buildStatContent(AppAssets.shareIcon, 'Share', AppColors.statsColor)),
        ),
        Container(
          height: 52.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(7.r),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: AppColors.boxShadowColor.withOpacity(0.25),
              ),
            ],
          ),
            child: GestureDetector(
              onTap: (){
                print('download');
              },
                child: _buildStatContent(AppAssets.downloadIcon, 'Download', AppColors.statsColor,)),
        ),
        Container(
          height: 52.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(7.r),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: AppColors.boxShadowColor.withOpacity(0.25),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: (){
              print('copy link');
            },
              child: _buildStatContent(
                  AppAssets.copyLinkIcon, 'Copy Link', AppColors.statsColor)),
        ),
      ],
    );
  }

  Widget _buildStatContent(String assetPath, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          height: 16.h,
          width: 16.w,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.countColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
            onTap: (){
              print('followers');
              Navigator.pushNamed(
                context,
                Routes.followersFollowing,
              );
            },
            child: _buildStatItem('10k', 'Followers', AppColors.countColor)
        ),
        // _buildStatDivider(),
        GestureDetector(
            onTap: (){
              print('following');
              Navigator.pushNamed(
                context,
                Routes.followersFollowing,
              );
            },
            child: _buildStatItem('4.5k', 'Following', AppColors.countColor)
        ),
        // _buildStatDivider(),
        GestureDetector(
            onTap: (){
              print('visit count');
            },
            child: _buildStatItem('25', 'Visit Count', AppColors.countColor)
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.countColor.withOpacity(0.8.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: Colors.grey[300],
    );
  }
}