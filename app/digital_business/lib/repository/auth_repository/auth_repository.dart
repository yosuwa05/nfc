import '../../model/user_auth_model/user_auth_model.dart';
import '../../services/auth_service/auth_service.dart';

class AuthRepository {
  final AuthService authService = AuthService();

  Future<dynamic> sendOtp(String mobileNumber, String signature) async {
    return await authService.sendOtp(mobileNumber, signature);
  }

  Future<dynamic> verifyOtp(
      String otpId, String otpNo, String mobileNumber) async {
    return await authService.verifyOtp(otpId, otpNo, mobileNumber);
  }

  Future<UserAuthModel> login(
      {required String mobileNumber,
        required String fcmToken}) async {
    return await authService.login(
        mobileNumber: mobileNumber, fcmToken: fcmToken);
  }

  Future<dynamic> updateFCMToken(
      {required String fcmToken, required String userId}) async {
    return await authService.updateFCMToken(fcmToken: fcmToken, userId: userId);
  }

}