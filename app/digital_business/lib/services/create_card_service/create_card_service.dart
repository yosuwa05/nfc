import 'dart:io';
import 'package:digital_business/model/create_card_model/business_images_and_video_model/business_images_and_video_model.dart';
import 'package:dio/dio.dart';
import '../../entities/create_card_entity/create_card_entities.dart';
import '../../model/create_card_model/attach_links_model/get_attach_link_model.dart';
import '../../model/create_card_model/attach_links_model/update_attach_links_model.dart';
import '../../model/create_card_model/business_details_model/business_details_model.dart';
import '../../model/create_card_model/select_industries_model/get_all_Industries_model.dart';
import '../../model/create_card_model/select_industries_model/select_industries_model.dart';
import '../../model/create_card_model/user_flag_model/user_flag_model.dart';
import '../../network/dio_client.dart';

class CreateCardService {
  final Dio _dio = ApiClient.dio;

  Future<UserFlagModel> getUserFlags(String userId) async {
    try {
      final response = await _dio.get(
        'user/flags/',
        queryParameters: {'userId': userId},
      );
      if (response.statusCode == 200) {
        return UserFlagModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load user flags: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  //Business Details

  Future<BusinessDetailsModel> getBusinessDetails({
    required BusinessDetailsEntity businessDetailsEntity,
    required String userId,
    required File? companyLogo,
  }) async {
    try {
      // Create the businessDetails object as expected by API
      Map<String, dynamic> businessDetailsMap = {
        "companyName": businessDetailsEntity.companyName,
        "companyAddress": businessDetailsEntity.companyAddress,
        "companyMobile": businessDetailsEntity.companyMobile,
        "companyEmail": businessDetailsEntity.companyEmail,
        "companyWebsite": businessDetailsEntity.companyWebsite,
        if (companyLogo != null && companyLogo.path.isNotEmpty)
          "profileImage": await MultipartFile.fromFile(companyLogo.path.toString()),
      };

      FormData formData = FormData.fromMap({
        "businessDetails": businessDetailsMap,
      });

      final response = await _dio.patch(
        'user/business-details',
        data: formData,
        queryParameters: {
          "userId": userId,
        },
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 500,
        ),
      );

      print('DEBUG: API Response - ${response.statusCode}');
      print('DEBUG: API Response Data - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BusinessDetailsModel.fromJson(response.data);
      } else {
        // Handle validation errors or other errors
        return BusinessDetailsModel.fromJson(response.data);
      }
    } catch (e) {
      print("BusinessDetailsService ERROR: ${e.toString()}");
      throw Exception('Failed to submit business details: $e');
    }
  }


  //Profile Image
  Future<dynamic> getProfileImage({
    required String userId,
    required File profileImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(profileImage.path),
      });

      final response = await _dio.post(
        'user/profile-image?userId=$userId',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        print("Unexpected status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("ProfileImageService ERROR: ${e.toString()}");
      throw Exception('Failed to upload profile image: $e');
    }
  }

//Get All Industries
  Future<GetAllIndustriesModel> getAllIndustries() async {
    try {
      final response = await _dio.get('user/industries');

      if (response.statusCode == 200) {
        return GetAllIndustriesModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load industries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  //Selected Industries Tags

  Future<SelectIndustriesModel> selectedIndustriesTags({
    required String userId,
    required List<Map<String, dynamic>> selectedIndustries,
  }) async {
    try {
      final response = await _dio.patch(
        'user/selected-industries',
        queryParameters: {"userId": userId},
        data: {"selectedIndustries": selectedIndustries},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return SelectIndustriesModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to update industries tags: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error updating industries tags: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error updating industries tags: $e');
    }
  }

  //Get Attach Links
  Future<GetAttachLinksModel> getAttachLinks() async {
    try {
      final response = await _dio.get('user/links');
      if (response.statusCode == 200) {
        return GetAttachLinksModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load industries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  //Update Attach Links

  Future<UpdatedAttachLinksModel> updateAttachedLinks({required String userId, required Map<String, dynamic> payload}) async {
    try {
      final response = await _dio.patch(
        'user/attached-links',
        queryParameters: {'userId': userId},
        data: payload,
      );

      if (response.statusCode == 200) {
        return UpdatedAttachLinksModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update attached links: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Better error handling
      if (e.response != null) {
        print('Error Response: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
        throw Exception('API error: ${e.response?.data ?? e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  //Update Business Image and Video

  Future<BusinessImagesAndVideoModel> updateBusinessImagesAndVideo({
    required String userId,
    required List<File> images,
  }) async {
    try {
      FormData formData = FormData();

      // Add files with correct key "businessImages"
      for (var file in images) {
        formData.files.add(
          MapEntry(
            'businessImages', // 👈 must match Postman key
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.patch(
        'user/business-images',
        data: formData,
        queryParameters: {'userId': userId},
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return BusinessImagesAndVideoModel.fromJson(response.data);
      } else {
        throw Exception('Failed to upload files: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading files: $e');
    }
  }



}