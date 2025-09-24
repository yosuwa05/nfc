import 'dart:io';

import 'package:digital_business/common/widgets/custom_container.dart';
import 'package:digital_business/common/widgets/custom_styled_page.dart';
import 'package:digital_business/core/constants/app_assets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/helper/app_routes.dart';
import '../../common/helper/pref.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_textfield.dart';
import '../../core/constants/toast.dart';
import '../../network/dio_client.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../../services/create_card_service/create_card_service.dart';

class AddProfilePictureScreen extends StatefulWidget {
  final String? userId;
  const AddProfilePictureScreen({
    this.userId,
    super.key
  });

  @override
  State<AddProfilePictureScreen> createState() => _AddProfilePictureScreenState();
}

class _AddProfilePictureScreenState extends State<AddProfilePictureScreen> {
  bool _isButtonEnabled = false;
  File? _selectedImage;
  bool _isLoading = false;
  bool _hasError = false;
  final CreateCardService _createCardService = CreateCardService();
  final AuthRepository authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  String fcmToken = "";
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    initFirebaseMessaging();
    _checkExistingProfileImage();
  }

  Future<void> _checkExistingProfileImage() async {
    // Check if profile image was already uploaded
    final profileImageCompleted = await SecureStorageHelper.getString("profileImageCompleted");
    if (profileImageCompleted == "true") {
      setState(() {
        _isButtonEnabled = true;
      });

      final savedImagePath = await SecureStorageHelper.getString("profileImagePath");
      if (savedImagePath != null) {
        final file = File(savedImagePath);
        if (await file.exists()) {
          setState(() {
            _selectedImage = file;
          });
        }
      }
    }
  }

  Future<void> _initializeUserId() async {
    if (widget.userId == null) {
      String? storedUserId = await SecureStorageHelper.getString("userId");
      if (storedUserId != null) {
        setState(() {
          _userId = storedUserId;
        });
      } else {
        showToast(
          message: "User ID not found. Please log in again.",
          backgroundColor: AppColors.redColor,
        );
        // Navigator.pushReplacementNamed(context, Routes.login);
      }
    } else {
      _userId = widget.userId;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        // Save the image path locally for future reference
        await SecureStorageHelper.setString("profileImagePath", pickedFile.path);

        setState(() {
          _selectedImage = File(pickedFile.path);
          _isButtonEnabled = true;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      showToast(
        message: "Error selecting image. Please try again.",
        backgroundColor: AppColors.redColor,
      );
    }
  }

  Future<void> initFirebaseMessaging() async {
    if (Platform.isAndroid || Platform.isIOS) {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null || _userId == null) {
      showToast(
        message: "Please select an image and ensure user ID is available.",
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _createCardService.getProfileImage(
        userId: _userId!,
        profileImage: _selectedImage!,
      );

      if (response != null && response['status'] == true) {
        // Mark profile image as completed
        await SecureStorageHelper.setString("profileImageCompleted", "true");

        // Check if all onboarding steps are completed
        final businessDetailsCompleted = await SecureStorageHelper.getString("businessDetailsCompleted");
        if (businessDetailsCompleted == "true") {
          // Mark all onboarding as completed
          await SecureStorageHelper.setString("allOnboardingCompleted", "true");
        }

        showToast(
          message: response['message'] ?? "Profile image uploaded successfully!",
          backgroundColor: AppColors.greenColor,
        );

        if (mounted) {
          await SecureStorageHelper.setString("userId", _userId!);
          Navigator.pushNamed(context, Routes.selectIndustries);
        }
      } else {
        showToast(
          message: "Failed to upload image. Please try again.",
          backgroundColor: AppColors.redColor,
        );
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      showToast(
        message: "Failed to upload image. Please check your connection and try again.",
        backgroundColor: AppColors.redColor,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> login() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      try {
        final mobileNumber =
        await SecureStorageHelper.getString("mobileNumber");
        final response = await authRepository.login(
          mobileNumber: mobileNumber ?? "1234567890",
          fcmToken: fcmToken,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.status == true) {
          if (mounted) {
            showToast(
                message: response.message ?? 'Profile Image uploaded Successfully',
                backgroundColor:
                AppColors.greenColor);
            await SecureStorageHelper.setString(
                "userId", response.data?.userId ?? '');
            await ApiClient.updateToken(
              userId: response.data?.userId ?? '',
            );
          }
        } else {
          setState(() {
            _hasError = true;
          });

        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });

        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            setState(() {
              _hasError = false;
            });
          }
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          CustomStyledPage(
            showTitle: true,
            showBackButton: true,
            title: "Add Profile Picture",
            subtitle: 'Make your profile more engaging with a clear image.',
            child: Column(
              children: [
                SizedBox(height: 190.h),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 72.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Center(
                           child: Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: LayoutBuilder(
                               builder: (context, constraints) {
                                 return CustomContainer(
                                   title: '',
                                   width: constraints.maxWidth * 0.6,
                                   height: constraints.maxWidth * 0.6 * (219 / 260),
                                   radius: 14.r,
                                   onTap: () => _pickImage(ImageSource.gallery),
                                   containerColor: AppColors.containerColor,
                                   textColor: Colors.transparent,
                                   containerBorderColor: AppColors.borderColor,
                                   child: Center(
                                     child: _selectedImage != null
                                         ? ClipRRect(
                                       borderRadius: BorderRadius.circular(14.r),
                                       child: Image.file(
                                         _selectedImage!,
                                         width: constraints.maxWidth * 0.7,
                                         height: constraints.maxWidth * 0.7,
                                         fit: BoxFit.cover,
                                       ),
                                     )
                                         : SvgPicture.asset(
                                       AppAssets.profileIcon,
                                       width: 80.w,
                                       height: 80.h,
                                     ),
                                   ),
                                 );
                               },
                             )
                           )
                       ),
                        SizedBox(height: 50.h,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                          child: CustomContainer(
                            title: 'Select from photo library',
                            onTap: () => _pickImage(ImageSource.gallery),
                            icon: SvgPicture.asset(
                              AppAssets.galleryIcon,
                              width: 20.w,
                              height: 20.h,
                            ),
                            iconLeft: true,
                            height: 40.h,
                            width: double.infinity,
                            radius: 12.r,
                            containerColor: AppColors.containerColor,
                            textColor: AppColors.textColor,
                            containerBorderColor: AppColors.borderColor,
                          ),
                        ),
                        SizedBox(height: 10.h,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                          child: CustomContainer(
                            title: 'Use camera to take photo',
                            onTap: () => _pickImage(ImageSource.camera),
                            icon: SvgPicture.asset(
                              AppAssets.cameraIcon,
                              width: 20.w,
                              height: 20.h,
                            ),
                            iconLeft: true,
                            height: 40.h,
                            width: double.infinity,
                            radius: 12.r,
                            containerColor: AppColors.containerColor,
                            textColor: AppColors.textColor,
                            containerBorderColor: AppColors.borderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed bottom buttons
          // Positioned(
          //   bottom: 5.h,
          //   left: 0,
          //   right: 0,
          //   child: SafeArea(
          //     top: false,
          //     child: Container(
          //       color: Colors.transparent,
          //       padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.h),
          //       child: Row(
          //         children: [
          //           GestureDetector(
          //             onTap: () {
          //               Navigator.pushNamed(
          //                 context,
          //                 Routes.selectIndustries,
          //                 // arguments: OTPVerificationScreen(
          //                 //   phoneNumber: _phoneNumberController.text.trim(),
          //                 //   route: Routes.loginAccount,
          //                 // ),
          //               );
          //             },
          //             child: Text(
          //               'Do Later',
          //               style: TextStyle(
          //                 color: AppColors.primaryColor,
          //                 fontSize: 16.sp,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ),
          //           SizedBox(width: 16.w),
          //           Expanded(
          //             child: CustomButton(
          //               title: _isLoading ? 'Uploading...' : 'Continue (02/5)',
          //               onTap: (_isButtonEnabled && !_isLoading) ? _uploadProfileImage : null,
          //               color: _isButtonEnabled
          //                   ? AppColors.primaryColor
          //                   : AppColors.buttonDisableColor,
          //               textColor: _isButtonEnabled
          //                   ? AppColors.whiteColor
          //                   : AppColors.textFieldColor,
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600,
          //               expanded: true,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
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
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.selectIndustries,
                      // arguments: OTPVerificationScreen(
                      //   phoneNumber: _phoneNumberController.text.trim(),
                      //   route: Routes.loginAccount,
                      // ),
                    );
                  },
                  child: Text(
                    'Do Later',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomButton(
                    title: _isLoading ? 'Uploading...' : 'Continue (02/5)',
                    onTap: (_isButtonEnabled && !_isLoading) ? _uploadProfileImage : null,
                    color: _isButtonEnabled
                        ? AppColors.primaryColor
                        : AppColors.buttonDisableColor,
                    textColor: _isButtonEnabled
                        ? AppColors.whiteColor
                        : AppColors.textFieldColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    expanded: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
