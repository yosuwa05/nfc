import 'package:digital_business/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:flutter/services.dart';

import '../../model/create_card_model/attach_links_model/get_attach_link_model.dart';
import '../theme/app_colors.dart';

class CustomAttachLinkContainer extends StatefulWidget {
  final double height;
  final double width;
  final double radius;
  final SubCategories? category;
  final SubCategories? subCategory;
  final Function(String, String)? onLinkAdded;
  final Function()? onLinkRemoved;

  const CustomAttachLinkContainer({
    super.key,
    this.height = 56,
    this.width = double.infinity,
    this.radius = 8,
    this.subCategory,
    this.onLinkAdded,
    this.onLinkRemoved,
    this.category,
  });

  @override
  State<CustomAttachLinkContainer> createState() => _CustomAttachLinkContainerState();
}

class _CustomAttachLinkContainerState extends State<CustomAttachLinkContainer> {
  late TextEditingController _linkController;
  bool _hasLink = false;
  bool _isAddButtonEnabled = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController();
    _linkController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      _isAddButtonEnabled = _linkController.text.isNotEmpty;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _linkController.text = clipboardData.text!;
        _isAddButtonEnabled = true;
      });
    }
  }

  void _addLink() {
    if (_linkController.text.isNotEmpty && widget.subCategory != null) {
      setState(() {
        _hasLink = true;
      });
      widget.onLinkAdded?.call(
          _linkController.text,
        widget.subCategory!.sId!,
      );
    }
  }

  void _clearLink() {
    setState(() {
      _linkController.clear();
      _hasLink = false;
      _isAddButtonEnabled = false;
    });
    widget.onLinkRemoved?.call();
  }

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
      child: _buildInputField(),
    );
  }

  Widget _buildInputField() {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(4.r),
            child: widget.subCategory?.icon != null &&
                widget.subCategory!.icon!.startsWith('http')
                ? Image.network(
              widget.subCategory!.icon!,
              errorBuilder: (context, error, stackTrace) =>
                  SvgPicture.asset(AppAssets.copyLinkIcon),
            )
                : Padding(
                  padding: EdgeInsets.all(6.r),
                  child: SvgPicture.asset(AppAssets.copyLinkIcon),
                ),
          ),

        ),
        SizedBox(width: 8.w),
        Expanded(
          child: TextFormField(
            controller: _linkController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              prefixIcon: _hasLink ? null : Padding(
                padding: EdgeInsets.all(14.0.w),
                child: SvgPicture.asset(
                  AppAssets.linkIcon,
                  height: 8.h,
                  width: 8.w,
                ),
              ),
              hintText: _hasLink
                  ? null
                  : (widget.subCategory?.name?.isNotEmpty == true
                  ? '${widget.subCategory!.name} Attach link'
                  : 'Attach link'),
              hintStyle: TextStyle(
                color: AppColors.textLightColor.withOpacity(0.82),
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.w,
                ),
              ),
              // Suffix widget that changes based on state
              suffixIcon: _hasLink
                  ? _buildLinkViewSuffix()
                  : _buildInputSuffix(),
            ),
            keyboardType: TextInputType.url,
            style: _hasLink
                ? TextStyle(
              fontSize: 16.sp,
              color: AppColors.textColor,
              fontWeight: FontWeight.w500
            )
                : TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
            readOnly: _hasLink,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSuffix() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _isAddButtonEnabled ? _addLink : null,
          child: Container(
            width: 47.w,
            height: 26.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              color: _isAddButtonEnabled ? AppColors.primaryColor : AppColors.buttonDisableColor,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Center(
              child: Text(
                'Add',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: _isAddButtonEnabled ? AppColors.whiteColor : AppColors.textLightColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkViewSuffix() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close button for when link is added
        GestureDetector(
          onTap: _clearLink,
          child: SvgPicture.asset(AppAssets.closeIcon)
        ),
      ],
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}