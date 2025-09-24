import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../common/helper/pref.dart';
import '../common/theme/app_colors.dart';

class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
      printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true));
  final Connectivity _connectivity = Connectivity();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath');
    logger.d('Error type: ${err.error} \n ' 'Error message: ${err.message}');
    _handleError(err);
    handler.next(err);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showToast("Please connect to the internet.");
      return handler.reject(
        DioException(
          requestOptions: options,
          error: "No internet connection",
          type: DioExceptionType.badResponse,
        ),
      );
    }
    if (options.method == 'POST' || options.method == 'PATCH') {
      options.headers['Content-Type'] = 'application/json';
    }

    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.f('STATUSCODE: ${response.statusCode} \n '
        'STATUSMESSAGE: ${response.statusMessage} \n'
        'HEADERS: ${response.headers} \n'
        'Data: ${response.data}');
    handler.next(response);
  }

  static void _handleError(DioException error) {
    String message = "An error occurred";

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      switch (statusCode) {
        case 400:
          message = _extractErrorMessage(responseData) ?? "Bad Request";
          break;
        case 401:
          message = "Unauthorized. Please login again";
          _handleUnauthorized();
          break;
        case 403:
          message = "Access forbidden";
          break;
        case 404:
          message = "Resource not found";
          break;
        case 408:
          message = "Request timeout";
          break;
        case 422:
          message = _extractErrorMessage(responseData) ?? "Validation error";
          break;
        case 500:
          message = "Internal server error";
          break;
        case 502:
          message = "Bad gateway";
          break;
        case 503:
          message = "Service unavailable";
          break;
        case 504:
          message = "Gateway timeout";
          break;
        default:
          message = _extractErrorMessage(responseData) ??
              "Server error ($statusCode)";
      }
    } else {
      if (error.type == DioExceptionType.connectionTimeout) {
        message = "Connection timeout. Please check your internet connection.";
      } else if (error.type == DioExceptionType.receiveTimeout) {
        message = "Receive timeout. Please check your internet connection.";
      } else if (error.type == DioExceptionType.sendTimeout) {
        message = "Send timeout. Please check your internet connection.";
      } else if (error.type == DioExceptionType.badResponse &&
          error.message != null &&
          error.message!.contains('SocketException')) {
        message = "Please connect to the internet.";
      } else {
        message = "Network error. Please try again.";
      }
    }

    _showToast(message);
  }

  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ??
          responseData['error'] ??
          responseData['msg'] ??
          responseData['detail'];
    } else if (responseData is String) {
      return responseData;
    }
    return null;
  }

  static void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.redColor,
        textColor: AppColors.whiteColor,
        fontSize: 12.sp);
  }

  static Future<void> _handleUnauthorized() async {
    try {
      await SecureStorageHelper.remove("token");
      await SecureStorageHelper.remove("customerId");
      if (NavigationService.navigatorKey.currentState != null) {
        await Future.delayed(const Duration(milliseconds: 1000));
        NavigationService.navigateAndRemoveUntil('/loginAccount');
      } else {
        print("Navigator key not initialized, cannot navigate.");
      }
    } catch (e) {
      print("Logout API failed: $e");
    } finally {
      print("User logged out due to 401 Unauthorized");
    }
  }
}

class AuthorizationInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageHelper.getString("token");

    options.headers['Authorization'] = "Zoho-oauthtoken $token";
    handler.next(options);
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    return navigatorKey.currentState!.pop();
  }

  static void navigateAndRemoveUntil(String routeName) {
    navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  }
}