import 'package:digital_business/common/widgets/custom_tab_bar.dart';
import 'package:digital_business/common/widgets/custom_textfield.dart';
import 'package:digital_business/ui/home/widgets/followers_following_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../common/helper/app_routes.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_styled_page.dart';
import '../../core/constants/app_assets.dart';
import 'followers_detail_screen.dart';

class FollowersFollowingScreen extends StatefulWidget {
  const FollowersFollowingScreen({super.key});

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> {

  final _searchController = TextEditingController();
  bool _isDropdownOpen = false;
  final List<String> _tabs = ['Followers', 'Following'];
  int _currentIndex = 0;
  int followersCount = 0;
  int followingCount = 0;

  // final PagingController<int, User> _pagingController = PagingController(firstPageKey: 0);
  static const _pageSize = 10;



  // @override
  // void initState() {
  //   // Add listener to fetch data when a new page is requested
  //   _pagingController.addPageRequestListener((pageKey) {
  //     _fetchPage(pageKey);
  //   });
  //   super.initState();
  // }

  // Future<void> _fetchPage(int pageKey) async {
  //   try {
  //     // Simulate fetching data from an API
  //     final newItems = List.generate(
  //       _pageSize,
  //           (index) => User(
  //         businessName: 'Business ${pageKey + index + 1}',
  //         userName: 'User ${pageKey + index + 1}',
  //         city: 'Kottar, Nagercoil',
  //         date: '01 Sep 2025',
  //       ),
  //     );
  //
  //     // Simulate network delay
  //     await Future.delayed(const Duration(seconds: 1));
  //
  //     // Check if this is the last page
  //     final isLastPage = newItems.length < _pageSize;
  //     if (isLastPage) {
  //       _pagingController.appendLastPage(newItems);
  //     } else {
  //       final nextPageKey = pageKey + newItems.length;
  //       _pagingController.appendPage(newItems, nextPageKey);
  //     }
  //   } catch (error) {
  //     _pagingController.error = error;
  //   }
  // }

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap:  () => Navigator.of(context).pop(),
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
                    Expanded(
                      child: Center(
                        child: Text(
                          "Mohammed Fazil",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHeaderColor
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.h),
                CustomTabBar(
                  tabs: _tabs,
                  onTabChanged: _onTabChanged,
                  overallCounts: [followersCount,followingCount],
                ),
                SizedBox(height: 20.h),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     // Business Dropdown
                //     Expanded(
                //       child: Padding(
                //         padding: EdgeInsets.only(right: 8.w),
                //         child: Container(
                //           height: 42.h,
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(8),
                //             border: Border.all(
                //               width: 0.2,
                //               color: const Color(0xFF4B4B4B).withOpacity(0.2),
                //             ),
                //             boxShadow: [
                //               BoxShadow(
                //                 offset: const Offset(0, 0),
                //                 blurRadius: 4,
                //                 spreadRadius: 0,
                //                 color: const Color(0xFF949494).withOpacity(0.25),
                //               ),
                //             ],
                //           ),
                //           child: DropdownButtonHideUnderline(
                //             child: ButtonTheme(
                //               alignedDropdown: true,
                //               child: DropdownButton<String>(
                //                 isExpanded: true,
                //                 value: selectedBusiness,
                //                 hint: Padding(
                //                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //                   child: Text(
                //                     "Select Business",
                //                     style: TextStyle(
                //                       color: AppColors.textFieldColor,
                //                       fontWeight: FontWeight.w400,
                //                       fontSize: 14.sp,
                //                     ),
                //                   ),
                //                 ),
                //                 icon: Icon(
                //                   Icons.keyboard_arrow_down_outlined,
                //                   size: 20.sp,
                //                   color: AppColors.textFieldColor,
                //                 ),
                //                 items: businesses.map((String business) {
                //                   return DropdownMenuItem<String>(
                //                     value: business,
                //                     child: Text(
                //                       business,
                //                       style: TextStyle(
                //                         color: AppColors.textFieldColor,
                //                         fontWeight: FontWeight.w400,
                //                         fontSize: 14.sp,
                //                       ),
                //                       overflow: TextOverflow.ellipsis,
                //                     ),
                //                   );
                //                 }).toList(),
                //                 onChanged: (String? newValue) {
                //                   setState(() {
                //                     selectedBusiness = newValue;
                //                   });
                //                 },
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //     // City Dropdown
                //     // Expanded(
                //     //   child: Container(
                //     //     height: 42.h,
                //     //     decoration: BoxDecoration(
                //     //       color: Colors.white,
                //     //       borderRadius: BorderRadius.circular(8),
                //     //       border: Border.all(
                //     //         width: 0.2,
                //     //         color: const Color(0xFF4B4B4B).withOpacity(0.2),
                //     //       ),
                //     //       boxShadow: [
                //     //         BoxShadow(
                //     //           offset: const Offset(0, 0),
                //     //           blurRadius: 4,
                //     //           spreadRadius: 0,
                //     //           color: const Color(0xFF949494).withOpacity(0.25),
                //     //         ),
                //     //       ],
                //     //     ),
                //     //     child: DropdownButtonHideUnderline(
                //     //       child: ButtonTheme(
                //     //         alignedDropdown: true,
                //     //         child: DropdownButton<String>(
                //     //           isExpanded: true,
                //     //           value: selectedCity,
                //     //           hint: Padding(
                //     //             padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //     //             child: Text(
                //     //               "Select City",
                //     //               style: TextStyle(
                //     //                 color: AppColors.textFieldColor,
                //     //                 fontWeight: FontWeight.w400,
                //     //                 fontSize: 14.sp,
                //     //               ),
                //     //             ),
                //     //           ),
                //     //           icon: Icon(
                //     //             Icons.keyboard_arrow_down_outlined,
                //     //             size: 20.sp,
                //     //             color: AppColors.textFieldColor,
                //     //           ),
                //     //           items: cities.map((String city) {
                //     //             return DropdownMenuItem<String>(
                //     //               value: city,
                //     //               child: Text(
                //     //                 city,
                //     //                 style: TextStyle(
                //     //                   color: AppColors.textFieldColor,
                //     //                   fontWeight: FontWeight.w400,
                //     //                   fontSize: 14.sp,
                //     //                 ),
                //     //                 overflow: TextOverflow.ellipsis,
                //     //               ),
                //     //             );
                //     //           }).toList(),
                //     //           onChanged: (String? newValue) {
                //     //             setState(() {
                //     //               selectedCity = newValue;
                //     //             });
                //     //           },
                //     //         ),
                //     //       ),
                //     //     ),
                //     //   ),
                //     // ),
                //   ],
                // ),
                CustomTextfield(
                    controller: _searchController,
                    isPrefixIcon: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.h),
                      child: SvgPicture.asset(AppAssets.searchIcon),
                    ),
                    hintText: 'Search users',
                ),
                SizedBox(height: 15.h),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.followersDetailScreen,
                      );
                    },
                    child: FollowersFollowingContainer())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
