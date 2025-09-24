import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmName;
  final String cancelName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmName,
    required this.cancelName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        children: [
          // Container(
          //   width: 80,
          //   height: 80,
          //   decoration: BoxDecoration(
          //     color: Color(0xFFF44748),
          //     shape: BoxShape.circle,
          //     border: Border.all(
          //       color: Color(0xFFFFF6F6),
          //       width: 6,
          //     ),
          //   ),
          //   child: Icon(Icons.close,color: Colors.white,size: 40,),
          // ),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF252525),
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              content,
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF434242)),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: cancelName,
                    onTap: onCancel,
                    height: 45.h,
                    width: 150.w,
                    radius: 6.r,
                    color: AppColors.primaryColor,
                    textColor: AppColors.primaryColor,
                    filled: false,
                    isOutline: true,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    title: confirmName,
                    onTap: onConfirm,
                    height: 45.h,
                    width: 150.w,
                    radius: 6.r,
                    color: AppColors.primaryColor,
                    textColor: AppColors.whiteColor,
                    filled: true,
                    fontSize: 14.sp,

                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
