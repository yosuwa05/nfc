import 'package:digital_business/core/app/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/theme/app_colors.dart';

class FollowersDetailScreen extends StatefulWidget {
  const FollowersDetailScreen({super.key});

  @override
  State<FollowersDetailScreen> createState() => _FollowersDetailScreenState();
}

class _FollowersDetailScreenState extends State<FollowersDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 175.h,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0.3, 0.8],
                colors: [
                  AppColors.followersDetailGradientColor1.withOpacity(0.83),
                  AppColors.followersDetailGradientColor2.withOpacity(0.52),],
              ),
            ),
          )
        ],
      ),
    );
  }
}
