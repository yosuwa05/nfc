import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/helper/app_routes.dart';
import '../../common/helper/pref.dart';
import '../../common/theme/app_colors.dart';
import '../../core/constants/toast.dart';
import '../../model/create_card_model/user_flag_model/user_flag_model.dart';
import '../../services/create_card_service/create_card_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  String? userId;
  final CreateCardService _createCardService = CreateCardService();
  bool _isNavigating = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    try {
      // Fade-in animation
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }

      // Navigate after 3 seconds total (1s fade + 2s delay)
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && !_isNavigating) {
        await _navigateBasedOnUserState();
      }
    } catch (e) {
      debugPrint("💥 ERROR in _initSplash: $e");
      if (mounted && !_isNavigating) {
        _navigateToRoute(Routes.loginAccount);
      }
    }
  }

  Future<void> _navigateBasedOnUserState() async {
    if (_isNavigating || !mounted) return; // Prevent multiple calls

    setState(() {
      _isNavigating = true;
    });

    try {
      final token = await SecureStorageHelper.getString("token");
      userId = await SecureStorageHelper.getString("userId");

      debugPrint("=== SPLASH SCREEN DEBUG ===");
      debugPrint("userId: $userId");
      debugPrint("token: ${token != null && token.isNotEmpty ? 'exists' : 'empty'}");

      // CASE 1: New user - no userId or token
      if (userId == null || userId!.isEmpty || token == null || token.isEmpty) {
        debugPrint("🆕 NEW USER - Navigating to login");
        _navigateToRoute(Routes.loginAccount);
        return;
      }

      // CASE 2: Existing user - call API to check flags
      debugPrint("👤 EXISTING USER - Checking onboarding status...");

      UserFlagModel userFlags;
      try {
        userFlags = await _createCardService.getUserFlags(userId!)
            .timeout(const Duration(seconds: 10)); // Add timeout
        debugPrint("✅ API call successful");
      } catch (apiError) {
        debugPrint("❌ API error: $apiError");
        // Fallback to local storage if API fails
        await _handleApiErrorFallback();
        return;
      }

      // Debug API response
      debugPrint("🚩 API FLAGS:");
      debugPrint("  businessDetails: ${userFlags.flags?.businessDetails}");
      debugPrint("  profilePicture: ${userFlags.flags?.profilePicture}");
      debugPrint("  selectedIndustries: ${userFlags.flags?.selectedIndustries}");
      debugPrint("  attachedLinks: ${userFlags.flags?.attachedLinks}");
      debugPrint("  businessImages: ${userFlags.flags?.businessImages}");

      // Update local storage with latest flags
      await _updateLocalStorageWithApiFlags(userFlags);

      // Determine navigation based on API flags
      final destinationRoute = _determineDestinationRoute(userFlags);
      debugPrint("🎯 Navigating to: $destinationRoute");

      _navigateToRoute(destinationRoute);

    } catch (e) {
      debugPrint("💥 ERROR in navigation: $e");
      await _handleErrorFallback();
    }
  }

  String _determineDestinationRoute(UserFlagModel userFlags) {
    // Safely check flags with null safety
    final flags = userFlags.flags;
    if (flags == null) {
      debugPrint("⚠️ Flags are null, going to business details");
      return Routes.businessDetails;
    }

    // Check if all flags are true
    final allCompleted = flags.businessDetails == true &&
        flags.profilePicture == true &&
        flags.selectedIndustries == true &&
        flags.attachedLinks == true &&
        flags.businessImages == true;

    if (allCompleted) {
      debugPrint("✅ All onboarding completed - going to home");
      return Routes.bottomNavigation;
    }

    // Find first incomplete step
    if (flags.businessDetails != true) {
      debugPrint("📋 Business details incomplete");
      return Routes.businessDetails;
    } else if (flags.profilePicture != true) {
      debugPrint("📸 Profile picture incomplete");
      return Routes.addProfilePicture;
    } else if (flags.selectedIndustries != true) {
      debugPrint("🏭 Industries selection incomplete");
      return Routes.selectIndustries;
    } else if (flags.attachedLinks != true) {
      debugPrint("🔗 Attached links incomplete");
      return Routes.attachLinks;
    } else if (flags.businessImages != true) {
      debugPrint("🖼️ Business images incomplete");
      return Routes.businessImages;
    }

    // Default fallback
    debugPrint("🏠 Default fallback to home screen");
    return Routes.bottomNavigation;
  }

  Future<void> _handleApiErrorFallback() async {
    try {
      debugPrint("🔄 Using local storage fallback...");
      final onboardingStatus = await OnboardingStorageHelper.getOnboardingStatus();

      String fallbackRoute;
      if (onboardingStatus.allOnboardingCompleted) {
        fallbackRoute = Routes.bottomNavigation;
      } else {
        // Go to first incomplete onboarding step
        if (!onboardingStatus.businessDetailsCompleted) {
          fallbackRoute = Routes.businessDetails;
        } else if (!onboardingStatus.profileImageCompleted) {
          fallbackRoute = Routes.addProfilePicture;
        } else if (!onboardingStatus.selectIndustryCompleted) {
          fallbackRoute = Routes.selectIndustries;
        } else if (!onboardingStatus.attachLinkCompleted) {
          fallbackRoute = Routes.attachLinks;
        } else if (!onboardingStatus.businessImageCompleted) {
          fallbackRoute = Routes.businessImages;
        } else {
          fallbackRoute = Routes.businessDetails; // Safe fallback
        }
      }

      debugPrint("🔀 Fallback navigation to: $fallbackRoute");
      _navigateToRoute(fallbackRoute);
    } catch (e) {
      debugPrint("💥 Fallback error: $e");
      _navigateToRoute(Routes.loginAccount);
    }
  }

  Future<void> _handleErrorFallback() async {
    debugPrint("🚨 Critical error - navigating to login");
    _navigateToRoute(Routes.loginAccount);
  }

  Future<void> _updateLocalStorageWithApiFlags(UserFlagModel userFlags) async {
    if (userFlags.flags != null) {
      try {
        await Future.wait([
          SecureStorageHelper.setString("businessDetailsCompleted", userFlags.flags!.businessDetails.toString()),
          SecureStorageHelper.setString("profileImageCompleted", userFlags.flags!.profilePicture.toString()),
          SecureStorageHelper.setString("selectIndustryCompleted", userFlags.flags!.selectedIndustries.toString()),
          SecureStorageHelper.setString("attachLinkCompleted", userFlags.flags!.attachedLinks.toString()),
          SecureStorageHelper.setString("businessImageCompleted", userFlags.flags!.businessImages.toString()),
        ]);

        // Update allOnboardingCompleted flag
        final allCompleted = userFlags.flags!.businessDetails == true &&
            userFlags.flags!.profilePicture == true &&
            userFlags.flags!.selectedIndustries == true &&
            userFlags.flags!.attachedLinks == true &&
            userFlags.flags!.businessImages == true;

        await SecureStorageHelper.setString("allOnboardingCompleted", allCompleted.toString());

        debugPrint("💾 Local storage updated with API flags");
      } catch (e) {
        debugPrint("❌ Error updating local storage: $e");
      }
    }
  }

  void _navigateToRoute(String route) {
    if (!mounted) {
      debugPrint("⚠️ Widget not mounted, skipping navigation");
      return;
    }

    debugPrint("📍 Navigation started to: $route");

    // Use addPostFrameCallback to ensure navigation happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
                (route) => false,
          );
          debugPrint("✅ Navigation completed to: $route");
        } catch (e) {
          debugPrint("❌ Navigation error: $e");
          // Try alternative navigation method
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Digital Business Card",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              if (_isNavigating)
                CircularProgressIndicator(
                  color: AppColors.whiteColor,
                  strokeWidth: 2.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingStatus {
  final String? userId;
  final bool businessDetailsCompleted;
  final bool profileImageCompleted;
  final bool selectIndustryCompleted;
  final bool attachLinkCompleted;
  final bool businessImageCompleted;
  final bool allOnboardingCompleted;

  OnboardingStatus({
    this.userId,
    required this.businessDetailsCompleted,
    required this.profileImageCompleted,
    required this.selectIndustryCompleted,
    required this.attachLinkCompleted,
    required this.businessImageCompleted,
    required this.allOnboardingCompleted,
  });

  factory OnboardingStatus.fromStorage(List<String?> storageValues) {
    return OnboardingStatus(
      userId: storageValues[0],
      businessDetailsCompleted: storageValues[1] == 'true',
      profileImageCompleted: storageValues[2] == 'true',
      selectIndustryCompleted: storageValues[3] == 'true',
      attachLinkCompleted: storageValues[4] == 'true',
      businessImageCompleted: storageValues[5] == 'true',
      allOnboardingCompleted: storageValues[6] == 'true',
    );
  }
}

class OnboardingStorageHelper {
  static Future<OnboardingStatus> getOnboardingStatus() async {
    try {
      final storageValues = await Future.wait([
        SecureStorageHelper.getString("userId"),
        SecureStorageHelper.getString("businessDetailsCompleted"),
        SecureStorageHelper.getString("profileImageCompleted"),
        SecureStorageHelper.getString("selectIndustryCompleted"),
        SecureStorageHelper.getString("attachLinkCompleted"),
        SecureStorageHelper.getString("businessImageCompleted"),
        SecureStorageHelper.getString("allOnboardingCompleted"),
      ]);

      debugPrint("📊 Local Storage Status:");
      debugPrint("  userId: ${storageValues[0]}");
      debugPrint("  businessDetailsCompleted: ${storageValues[1]}");
      debugPrint("  profileImageCompleted: ${storageValues[2]}");
      debugPrint("  selectIndustryCompleted: ${storageValues[3]}");
      debugPrint("  attachLinkCompleted: ${storageValues[4]}");
      debugPrint("  businessImageCompleted: ${storageValues[5]}");
      debugPrint("  allOnboardingCompleted: ${storageValues[6]}");

      return OnboardingStatus.fromStorage(storageValues);
    } catch (e) {
      debugPrint("❌ Error reading local storage: $e");
      return OnboardingStatus(
        userId: null,
        businessDetailsCompleted: false,
        profileImageCompleted: false,
        selectIndustryCompleted: false,
        attachLinkCompleted: false,
        businessImageCompleted: false,
        allOnboardingCompleted: false,
      );
    }
  }
}