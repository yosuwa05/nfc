import 'dart:developer';
import 'package:dio/dio.dart';
import '../common/helper/common.dart';
import '../common/helper/pref.dart';
import '../core/constants/api_url.dart';
import 'interceptor.dart';


class ApiClient {
  static final Dio _dio = Dio();

  static Dio get dio => _dio;

  ApiClient._();

  static Future<void> initialize() async {
    _dio.options.baseUrl = ApiUrl.baseUrl;
    token = await SecureStorageHelper.getString("token");
    userId = await SecureStorageHelper.getString("userId");

    _dio.options.headers = {
      'Authorization': 'Bearer $token',
    };

    _dio.interceptors.add(LoggerInterceptor());
  }

  static Future<bool> updateToken({
    String? sId,
    String? userId,
    String? email,
    String? userName,
    String? mobileNumber,
    String? city,
    String? state,
    String? fcmToken,
    bool? isDeleted,
    String? newToken,
  }) async {
    token = newToken;

    await SecureStorageHelper.setString("id", sId ?? '');
    await SecureStorageHelper.setString("userId", userId ?? '');
    await SecureStorageHelper.setString("email", email ?? '');
    await SecureStorageHelper.setString("userName", userName ?? '');
    await SecureStorageHelper.setString("mobileNumber", mobileNumber ?? '');
    await SecureStorageHelper.setString("city", city ?? '');
    await SecureStorageHelper.setString("state", state ?? '');
    await SecureStorageHelper.setString("fcmToken", fcmToken ?? '');
    await SecureStorageHelper.setBool("isDeleted", isDeleted ?? false);
    await SecureStorageHelper.setString("token", token ?? '');
    _dio.options.headers['Authorization'] = 'Bearer $token';
    log("Token Updated: $token");
    return true;
  }
}
