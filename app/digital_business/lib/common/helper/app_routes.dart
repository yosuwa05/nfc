import 'package:digital_business/common/helper/common.dart';
import 'package:digital_business/ui/auth/otp_verification_screen.dart';
import 'package:digital_business/ui/create_card/add_profile_picture_screen.dart';
import 'package:digital_business/ui/create_card/attach_links_screen.dart';
import 'package:digital_business/ui/create_card/business_details_screen.dart';
import 'package:digital_business/ui/create_card/business_images_screen.dart';
import 'package:digital_business/ui/create_card/select_Industries_screen.dart';
import 'package:digital_business/ui/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import '../../bottom_navigation.dart';
import '../../ui/auth/login_account_screen.dart';
import '../../ui/home/followers_detail_screen.dart';
import '../../ui/home/followers_following_screen.dart';
import '../../ui/splash/splash_screen.dart';

class Routes {
  //Splash Screen
  static const String splashScreen = '/splash';

  //Auth and Create Card Routes
  static const String loginAccount = '/loginAccount';
  static const String otpVerification = '/otpVerification';
  static const String businessDetails = '/businessDetails';
  static const String addProfilePicture = '/addProfilePicture';
  static const String selectIndustries = '/selectIndustries';
  static const String attachLinks = '/attachLinks';
  static const String businessImages = '/businessImages';


  //Home screen
  static const String homeScreen = '/homeScreen';
  static const String followersFollowing = '/followersFollowing';
  static const String followersDetailScreen = '/followersDetailScreen';
  static const String bottomNavigation = '/bottomNavigation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

    //Auth and Create Card Routes
      case loginAccount: return _fadeAnimation(const LoginAccountScreen());
      case otpVerification: final arg = settings.arguments as OTPVerificationScreen; return _fadeAnimation(OTPVerificationScreen(phoneNumber: arg.phoneNumber, route: arg.route,countryCode: arg.countryCode,otpId: arg.otpId,));
      case Routes.businessDetails:
        if (settings.arguments != null) {
          final arg = settings.arguments as BusinessDetailsScreen;
          return _fadeAnimation(BusinessDetailsScreen(userId: arg.userId));
        } else {
          return _fadeAnimation(BusinessDetailsScreen(userId: null));
        }
      case addProfilePicture: return _fadeAnimation(const AddProfilePictureScreen());
      case selectIndustries: return _fadeAnimation(const SelectIndustriesScreen());
      case attachLinks: return _fadeAnimation(const AttachLinksScreen());
      case businessImages: return _fadeAnimation(const BusinessImagesScreen());

      //Home Screen
      case homeScreen: return _fadeAnimation(const HomeScreen());
      case followersFollowing: return _fadeAnimation(const FollowersFollowingScreen());
      case followersDetailScreen: return _fadeAnimation(const FollowersDetailScreen());
      case bottomNavigation: return _fadeAnimation(const BottomNavigation());

      default:
        return _fadeAnimation(const SplashScreen());
    }
  }


  static PageRouteBuilder _fadeAnimation(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 900),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutBack,
            ),
          ),
          child: child,
        );
      },
    );
  }
}