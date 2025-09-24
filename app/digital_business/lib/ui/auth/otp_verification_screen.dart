import 'dart:async';
import 'package:digital_business/common/widgets/custom_styled_page.dart';
import 'package:digital_business/core/constants/app_assets.dart';
import 'package:digital_business/model/user_auth_model/user_auth_model.dart';
import 'package:digital_business/ui/auth/widgets/pin_textfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../common/helper/app_routes.dart';
import '../../common/helper/pref.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_button.dart';
import '../../core/constants/toast.dart';
import '../../network/dio_client.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../create_card/business_details_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? countryCode;
  final String route;
  final String? otpId;
  const OTPVerificationScreen({
    super.key,
    this.phoneNumber,
    this.countryCode,
    required this.route,
    this.otpId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with SingleTickerProviderStateMixin, CodeAutoFill {
  final TextEditingController otpController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  final FocusNode _otpFocusNode = FocusNode();
  bool _isButtonEnabled = false;
  Timer? _timer;
  String? _otpId;
  int _countdown = 60;
  bool _canResend = false;
  String? countryCode;
  String? countryFlag;
  bool _isLoading = false;
  StreamSubscription? _smsSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    listenForCode();
    otpController.addListener(_validateOtp);
    _otpId = widget.otpId;
    _startTimer();
    initCountry();
    _initializeSmsAutofill();
    countryCode = widget.countryCode;
    if (countryCode == null) {
      _initCountryFromStorage();
    }
  }

  Future<void> _initializeSmsAutofill() async {
    try {
      await SmsAutoFill().listenForCode();
      _smsSubscription = SmsAutoFill().code.listen((code) {
        if (code.isNotEmpty) {
          _handleSmsCode(code);
        }
      });
    } catch (e) {
      print("SMS autofill initialization error: $e");
    }
  }

  Future<void> _initCountryFromStorage() async {
    final storedCode = await SecureStorageHelper.getString("countryCode");
    if (storedCode != null && mounted) {
      setState(() {
        countryCode = storedCode;
      });
    }
  }

  void _handleSmsCode(String smsCode) {
    String extractedOtp = _extractOtpFromMessage(smsCode);
    if (extractedOtp.isNotEmpty && extractedOtp.length == 6) {
      setState(() {
        otpController.text = extractedOtp;
        _isButtonEnabled = true;
      });
      _otpFocusNode.unfocus();
    } else {
      showToast(
        message: extractedOtp.isEmpty
            ? 'Could not extract OTP. Please enter manually.'
            : 'Invalid OTP format. Please enter manually.',
        backgroundColor: AppColors.redColor,
      );
      _otpFocusNode.requestFocus();
    }
  }

  String _extractOtpFromMessage(String message) {
    List<RegExp> patterns = [
      RegExp(r'(?:OTP|Code|Verification)\s*(?:is|:|-)?\s*(\d{6})',
          caseSensitive: false),
      RegExp(r'(\d{6})\s*(?:is|-)?\s*(?:your|the)?\s*(?:OTP|Code|Verification)',
          caseSensitive: false),
      RegExp(r'(?:use|enter)\s*(\d{6})\s*(?:to|for)', caseSensitive: false),
      RegExp(
          r'(?:verification|confirm|auth)\s*(?:code|number)\s*(?:is|:|-)?\s*(\d{6})',
          caseSensitive: false),
      RegExp(r'(\d{6})\s*-\s*(?:your|verification|code)', caseSensitive: false),
      RegExp(r'(?:^|\s)(\d{6})(?:\s|$)', caseSensitive: false),
      RegExp(r'\b(\d{6})\b'),
    ];

    for (var pattern in patterns) {
      Match? match = pattern.firstMatch(message);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }
    return '';
  }

  @override
  void dispose() {
    otpController.removeListener(_validateOtp);
    _timer?.cancel();
    _smsSubscription?.cancel();
    SmsAutoFill().unregisterListener();
    _animationController.dispose();
    _otpFocusNode.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _validateOtp() {
    final otp = otpController.text.trim();
    setState(() {
      _isButtonEnabled = otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
    });
  }

  void _startTimer() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    UserAuthModel  userData = UserAuthModel();
    if (!_formKey.currentState!.validate() || !_isButtonEnabled) {
      print('Form validation failed or button disabled');
      return;
    }

    if (_otpId == null || widget.phoneNumber == null) {
      print('Error: OTP ID or phone number is null');
      showToast(
        message: 'OTP ID or phone number not found. Please resend OTP.',
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _animationController.repeat(reverse: true);
    });

    try {
      // Step 1: Verify OTP
      final otpResponse = await authRepository.verifyOtp(
        _otpId!,
        otpController.text.trim(),
        widget.phoneNumber!.trim(),
      );

      if (otpResponse != null && otpResponse['status'] == true) {
        // Step 2: Get FCM token (if using Firebase Messaging)
        String? fcmToken;
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
          print('DEBUG: FCM Token: $fcmToken');
        } catch (e) {
          print('Error fetching FCM token: $e');
          fcmToken = ''; // Fallback to empty string if FCM token retrieval fails
        }

        // Step 3: Call login API
        final loginResponse = await authRepository.login(
          mobileNumber: widget.phoneNumber!.trim(),
          fcmToken: fcmToken ?? '',
        );

        setState(() {
          _isLoading = false;
          _animationController.stop();
        });

        // Step 4: Handle login response
        if (loginResponse.status == true) {
          // Store user details in local storage
          await SecureStorageHelper.setString("mobileNumber", widget.phoneNumber!.trim());

          if (loginResponse.data != null) {
            userData = loginResponse;
            await SecureStorageHelper.setString("userId", userData.data?.userId ?? '');
            await SecureStorageHelper.setString("token", userData.data?.token ?? '');
            await SecureStorageHelper.setString("username", userData.data?.username ?? '');
            await SecureStorageHelper.setString("subscriptionPlan", userData.data?.subscriptionPlan ?? '');
            await SecureStorageHelper.setBool("isActive", userData.data?.isActive ?? false);
            await SecureStorageHelper.setString("lastLogin", userData.data?.lastLogin?.toString() ?? '');

            // Verify storage
            final storedUserId = await SecureStorageHelper.getString("userId");
            print('DEBUG: Verified stored userId: $storedUserId');

            // Update token in API client
            if (userData.data?.token != null && userData.data?.userId != null) {
              await ApiClient.updateToken(
                userId: userData.data?.userId!,
                newToken: userData.data?.token!,
              );
            }
            showToast(
              message: loginResponse.message ?? 'Login Successful',
              backgroundColor: AppColors.greenColor,
            );

            // Navigate to business details screen
            if (mounted) {
              Navigator.pushNamed(context, Routes.businessDetails, arguments: BusinessDetailsScreen(userId: userData.data?.userId));
            }
          }

        } else {
          // Handle login failure
          showToast(
            message: loginResponse.message ?? 'Login failed. Please try again.',
            backgroundColor: AppColors.redColor,
          );
          otpController.clear();
          _otpFocusNode.requestFocus();
        }
      } else {
        // Handle OTP verification failure
        setState(() {
          _isLoading = false;
          _animationController.stop();
        });
        showToast(
          message: otpResponse['message'] ?? 'Invalid OTP. Please try again.',
          backgroundColor: AppColors.redColor,
        );
        otpController.clear();
        _otpFocusNode.requestFocus();
      }
    } catch (e) {
      print('Verify OTP or Login Error: $e');
      setState(() {
        _isLoading = false;
        _animationController.stop();
      });
      showToast(
        message: 'Error: $e',
        backgroundColor: AppColors.redColor,
      );
      otpController.clear();
      _otpFocusNode.requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _animationController.repeat(reverse: true);
    });

    try {
      final response = await authRepository.sendOtp(
        widget.phoneNumber!.trim(),
        await SmsAutoFill().getAppSignature ?? '',
      );

      if (response != null && response['status'] == true) {
        _otpId = response['otpId'];
        await SecureStorageHelper.setString("otpId", _otpId!);

        if (mounted) {
          showToast(
            message: response['message'] ?? 'OTP Sent Successfully',
            backgroundColor: AppColors.greenColor,
          );
          otpController.clear();
          _otpFocusNode.requestFocus();
          await _restartSmsListener();
        }
      } else {
        if (mounted) {
          showToast(
            message: response['message'] ?? 'Failed to send OTP',
            backgroundColor: AppColors.redColor,
          );
        }
      }
    } catch (e) {
      print('Resend OTP Error: $e');
      if (mounted) {
        showToast(
          message: 'Error: $e',
          backgroundColor: AppColors.redColor,
        );
        otpController.clear();
        _otpFocusNode.requestFocus();
      }
    } finally {
      setState(() {
        _isLoading = false;
        _animationController.stop();
      });
    }
  }

  Future<void> _restartSmsListener() async {
    try {
      await _smsSubscription?.cancel();
      await SmsAutoFill().unregisterListener();
      await Future.delayed(const Duration(milliseconds: 500));
      _smsSubscription = SmsAutoFill().code.listen((code) {
        if (code.isNotEmpty) {
        _handleSmsCode(code);
        }
      });
      await SmsAutoFill().listenForCode();
    } catch (e) {
      print("Error restarting SMS listener: $e");
    }
  }

  Future<void> resendOtp() async {
    if (!_canResend) return;
    await _resendOtp();
    _startTimer();
  }

  Future<void> initCountry() async {
    countryCode = await SecureStorageHelper.getString("countryCode");
    countryFlag = await SecureStorageHelper.getString("countryFlag");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomStyledPage(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    if (widget.phoneNumber != null &&
                        countryCode != null &&
                        countryFlag != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '+$countryCode',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHeaderColor,
                            ),
                          ),
                        SizedBox(width: 5.w),
                        Text(
                          widget.phoneNumber ?? "",
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHeaderColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 11.h),
                    ],
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.editIcon,
                            height: 16.h,
                            width: 16.w,
                          ),
                          SizedBox(width: 6.w),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Color(0xFF825BDD),
                                Color(0xFF5A23DB),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              "Edit number",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Text(
                            "OTP Verification",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Form(
                        key: _formKey,
                        child: buildPinField(
                          context,
                          otpController,
                          length: 6,
                          isplaceHolder: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'OTP is required';
                            }
                            if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                              return 'Enter a valid 6-digit OTP';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _isButtonEnabled = value.length == 6;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    GestureDetector(
                      onTap: _canResend ? resendOtp : null,
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.resendOtpIcon,
                              color: _canResend
                                  ? AppColors.textHeaderColor
                                  : AppColors.textHeaderColor.withOpacity(0.5),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              _canResend
                                  ? 'Resend OTP'
                                  : 'Resend OTP in $_countdown secs',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: _canResend
                                    ? AppColors.textHeaderColor
                                    : AppColors.textHeaderColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomButton(
                        title: 'Sign In to Get OTP',
                        onTap: _isButtonEnabled && !_isLoading ? _verifyOtp : null,
                        height: 40.h,
                        width: double.infinity,
                        radius: 10.r,
                        color: _isButtonEnabled
                            ? AppColors.primaryColor
                            : AppColors.buttonDisableColor,
                        textColor: _isButtonEnabled
                            ? AppColors.whiteColor
                            : AppColors.textFieldColor,
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void codeUpdated() {
    if (mounted) {
      setState(() {
        _isButtonEnabled = otpController.text.isNotEmpty;
      });
    }
  }
}