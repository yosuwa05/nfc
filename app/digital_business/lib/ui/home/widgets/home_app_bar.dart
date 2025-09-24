import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

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

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10.r,
                  spreadRadius: 1.r,
                  color: AppColors.appBarCenterColor.withOpacity(0.1),
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}


// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../../common/theme/app_colors.dart';
// import '../../../core/constants/app_assets.dart';
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String userName;
//   final String industriesName;
//   final VoidCallback? onBackPressed;
//   final bool switchAccountIcon;
//   final bool profilePreviewIcon;
//   final Function()? showBackButtonAction;
//   final Function()? showAddButtonIcon;
//   final bool? isBlocked;
//   final Function()? showBlockIconAction;
//   final bool showDateButton;
//   final Function(List<DateTime?>)? showDateButtonAction;
//   final List<DateTime?>? selectedDateRange;
//   final String? displayDateText;
//   final dynamic overAllGold;
//   final double height;
//   final Widget? goldRate;
//
//   const CustomAppBar({
//     super.key,
//     required this.userName,
//     required this.industriesName,
//     this.onBackPressed,
//     this.showCoinIcon = true,
//     this.showBackButton = true,
//     this.showBackButtonAction,
//     this.showAddButtonIcon,
//     this.showBlockIcon = false,
//     this.isBlocked,
//     this.showBlockIconAction,
//     this.showDateButton = false,
//     this.showDateButtonAction,
//     this.selectedDateRange,
//     this.displayDateText,
//     this.overAllGold,
//     this.height = 114,
//     this.goldRate,
//   });
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w),
//       alignment: Alignment.center,
//       height: height.h,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             AppColors.appBarGradientBottomCenterColor,
//             AppColors.appBarGradientTopCenterColor,
//           ],
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(top: 20.h),
//         child: Row(
//           children: [
//             // showBackButton
//             //     ? GestureDetector(
//             //   onTap: showBackButtonAction ?? () => Navigator.pop(context),
//             //   child: Container(
//             //     padding: EdgeInsets.only(left: 12.w, right: 2.w),
//             //     height: 24.h,
//             //     width: 24.w,
//             //     child: SvgPicture.asset(AppAssets.leftArrowIcon),
//             //   ),
//             // )
//             //     : const SizedBox(),
//             SizedBox(width: 12.w),
//             Text(
//               userName,
//               style: TextStyle(
//                 color: AppColors.textColor,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const Spacer(),
//             // showCoinIcon
//             //     ? Padding(
//             //   padding: EdgeInsets.only(top: 20.h),
//             //   child: Image.asset(
//             //     AppAssets.coinsIcon,
//             //     width: 32.w,
//             //     height: 32.h,
//             //   ),
//             // )
//             //     : const SizedBox(),
//             if (overAllGold != null)
//               // Row(
//               //   children: [
//               //     Image.asset(
//               //       AppAssets.goldBarIc,
//               //       width: 34.w,
//               //       height: 34.h,
//               //     ),
//               //     SizedBox(width: 6.w),
//               //     Text(
//               //       "${overAllGold.toString()}g",
//               //       style: TextStyle(
//               //         fontWeight: FontWeight.w800,
//               //         fontSize: 20.sp,
//               //         height: 1.4,
//               //         letterSpacing: 0.2,
//               //         color: AppColors.textColor,
//               //       ),
//               //     )
//               //   ],
//               // ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => Size.fromHeight(122.h);
// }

