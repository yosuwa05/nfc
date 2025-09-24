import 'package:digital_business/ui/contact/contact_screen.dart';
import 'package:digital_business/ui/home/home_screen.dart';
import 'package:digital_business/ui/settings/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'common/theme/app_colors.dart';
import 'common/widgets/custom_dialog.dart';
import 'core/constants/app_assets.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ContactScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: "Exit",
        content: "Are you sure you want to exit the app?",
        cancelName: "No, Cancel",
        confirmName: "Yes, Exit",
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {
        'icon': AppAssets.homeIcon,
        'activeIcon': AppAssets.homeFilledIcon,
        'label': 'Home',
      },
      {
        'icon': AppAssets.contactIcon,
        'activeIcon': AppAssets.contactFilledIcon,
        'label': 'Contact',
      },
      {
        'icon': AppAssets.settingsIcon,
        'activeIcon': AppAssets.settingsFilledIcon,
        'label': 'Settings',
      },
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        body: _pages[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            // gradient: LinearGradient(
            //   begin: Alignment.bottomLeft,
            //   end: Alignment.topRight,
            //   colors: [
            //     AppColors.primaryColor.withOpacity(0.1),
            //     AppColors.whiteColor,
            //     AppColors.whiteColor,
            //     AppColors.whiteColor,
            //     AppColors.whiteColor,
            //   ],
            // ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(navItems.length, (index) {
                final bool isSelected = _currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Container(
                              height: 36.h,
                              width: 99.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32.r),
                                  gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF825BDD),
                                        Color(0xFF5A23DB),
                                      ]
                                  )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    navItems[index]['icon'],
                                    width: 16.sp,
                                    height: 16.sp,
                                    color: AppColors.whiteColor,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    navItems[index]['label'],
                                    style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ],
                              )
                          ),
                        if (!isSelected)
                          Container(
                            height: 36.h,
                            width: 36.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.whiteColor,
                              border: Border.all(
                                color: AppColors.borderColor,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.h),
                              child: SvgPicture.asset(
                                navItems[index]['icon'],
                                width: 16.sp,
                                height: 16.sp,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}