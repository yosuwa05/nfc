import 'package:digital_business/model/user_auth_model/user_auth_model.dart';
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<dynamic> sendOtp(String mobileNumber, String signature) async {
    try {
      final response = await _dio.post('auth/send-otp',
          data: {'mobile': mobileNumber, 'smsId': signature});
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return response.data;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> verifyOtp(
      String otpId, String otpNo, String mobileNumber) async {
    try {
      final response = await _dio.post('auth/verify-otp', data: {
        'otpId': otpId,
        'otpNo': otpNo,
        'mobile': mobileNumber
      });
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return response.data;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserAuthModel> login(
      {required String mobileNumber,
        required String fcmToken}) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {
          'mobile': mobileNumber,
          'fcmToken': fcmToken
        },
        options: Options(
          validateStatus: (status) {
            return status != null && status >= 200 && status < 500;
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserAuthModel.fromJson(response.data);
      } else if (response.statusCode == 400) {
        return UserAuthModel.fromJson(response.data);
      } else {
        return UserAuthModel.fromJson(response.data);
      }
    } catch (e) {
      print('Unexpected Error: $e');
      return UserAuthModel.fromJson({});
    }
  }


  Future<dynamic> updateFCMToken(
      {required String fcmToken, required String userId}) async {
    try {
      final response = await _dio.put('user/update-fcm', data: {
        'fcmToken': fcmToken,
      }, queryParameters: {
        'userId': userId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else if (response.statusCode == 400) {
        return response.data;
      } else {
        return response.data;
      }
    } catch (e) {
      print('Unexpected Error: $e');
      return {};
    }
  }
}