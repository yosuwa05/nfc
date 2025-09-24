import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../common/helper/app_routes.dart';
import '../../common/helper/pref.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_styled_page.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/toast.dart';
import '../../model/create_card_model/business_images_and_video_model/business_images_and_video_model.dart';
import '../../services/create_card_service/create_card_service.dart';

class BusinessImagesScreen extends StatefulWidget {
  const BusinessImagesScreen({super.key});

  @override
  State<BusinessImagesScreen> createState() => _BusinessImagesScreenState();
}

class _BusinessImagesScreenState extends State<BusinessImagesScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedMedia = [];
  final Map<String, Uint8List?> _videoThumbnails = {};
  final Map<String, bool> _thumbnailLoading = {};
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  final CreateCardService _createCardService = CreateCardService();

  // Supported file types
  final Set<String> _supportedImageExtensions = {
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.heic', '.heif'
  };

  final Set<String> _supportedVideoExtensions = {
    '.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm', '.m4v', '.3gp'
  };

  final Set<String> _supportedImageMimeTypes = {
    'image/jpeg', 'image/jpg', 'image/png', 'image/gif',
    'image/bmp', 'image/webp', 'image/heic', 'image/heif'
  };

  final Set<String> _supportedVideoMimeTypes = {
    'video/mp4', 'video/quicktime', 'video/avi', 'video/x-msvideo',
    'video/mkv', 'video/x-matroska', 'video/wmv', 'video/x-ms-wmv',
    'video/webm', 'video/3gpp'
  };

  Future<void> _pickMedia() async {
    try {
      final List<XFile>? pickedMedia = await _picker.pickMultipleMedia();

      if (pickedMedia != null && pickedMedia.isNotEmpty) {
        List<XFile> validMedia = [];
        List<String> unsupportedFiles = [];

        // Validate each selected file
        for (final media in pickedMedia) {
          final fileType = _getFileType(media);

          if (fileType == FileType.image || fileType == FileType.video) {
            validMedia.add(media);
          } else {
            unsupportedFiles.add(_getFileName(media));
          }
        }

        // Show error for unsupported files
        if (unsupportedFiles.isNotEmpty) {
          _showUnsupportedFileError(unsupportedFiles);
        }

        // Add valid media
        if (validMedia.isNotEmpty) {
          setState(() {
            _selectedMedia.addAll(validMedia);
            _isButtonEnabled = _selectedMedia.isNotEmpty;
          });

          // Generate thumbnails for videos
          for (final media in validMedia) {
            if (_getFileType(media) == FileType.video) {
              _generateVideoThumbnail(media);
            }
          }
        }
      }
    } catch (e) {
      print('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting media: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  FileType _getFileType(XFile file) {
    final fileName = file.name.toLowerCase();
    final mimeType = file.mimeType?.toLowerCase() ?? '';
    final extension = fileName.substring(fileName.lastIndexOf('.'));

    // Check if it's an image
    if (_supportedImageMimeTypes.contains(mimeType) ||
        _supportedImageExtensions.contains(extension)) {
      return FileType.image;
    }

    // Check if it's a video
    if (_supportedVideoMimeTypes.contains(mimeType) ||
        _supportedVideoExtensions.contains(extension)) {
      return FileType.video;
    }

    // Check for PDF specifically to show appropriate error
    if (extension == '.pdf' || mimeType == 'application/pdf') {
      return FileType.pdf;
    }

    return FileType.unsupported;
  }

  String _getFileName(XFile file) {
    return file.name.split('/').last;
  }

  void _showUnsupportedFileError(List<String> unsupportedFiles) {
    final String message;
    if (unsupportedFiles.length == 1) {
      final fileName = unsupportedFiles.first;
      if (fileName.toLowerCase().endsWith('.pdf')) {
        message = 'PDF files are not supported. Please select images or videos only.';
      } else {
        message = 'File "$fileName" is not supported. Please select images or videos only.';
      }
    } else {
      message = 'Some files are not supported. Please select images or videos only.';
    }

    showToast(
      message: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future<void> _generateVideoThumbnail(XFile videoFile) async {
    if (_thumbnailLoading[videoFile.path] == true) return;

    setState(() {
      _thumbnailLoading[videoFile.path] = true;
    });

    try {
      // First try getting thumbnail as bytes
      final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        maxHeight: 300,
        quality: 80,
      );

      if (thumbnailBytes != null && mounted) {
        setState(() {
          _videoThumbnails[videoFile.path] = thumbnailBytes;
          _thumbnailLoading[videoFile.path] = false;
        });
        return;
      }

      // Fallback method - generate file thumbnail
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: (await Directory.systemTemp.createTemp()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 300,
        maxWidth: 300,
        quality: 80,
      );

      if (thumbnailPath != null && mounted) {
        final File thumbnailFile = File(thumbnailPath);
        if (await thumbnailFile.exists()) {
          final Uint8List bytes = await thumbnailFile.readAsBytes();
          setState(() {
            _videoThumbnails[videoFile.path] = bytes;
            _thumbnailLoading[videoFile.path] = false;
          });
          // Clean up temp file
          thumbnailFile.delete().catchError((e) => print('Error deleting temp file: $e'));
          return;
        }
      }

      // Mark as failed if both methods don't work
      if (mounted) {
        setState(() {
          _videoThumbnails[videoFile.path] = null;
          _thumbnailLoading[videoFile.path] = false;
        });
      }

    } catch (e) {
      print('Error generating video thumbnail for ${videoFile.path}: $e');
      if (mounted) {
        setState(() {
          _videoThumbnails[videoFile.path] = null;
          _thumbnailLoading[videoFile.path] = false;
        });
      }
    }
  }

  void _removeMedia(int index) {
    final media = _selectedMedia[index];

    setState(() {
      _selectedMedia.removeAt(index);
      _isButtonEnabled = _selectedMedia.isNotEmpty;

      // Clean up video thumbnail data
      _videoThumbnails.remove(media.path);
      _thumbnailLoading.remove(media.path);
    });
  }

  Widget _buildMediaItem(XFile media, int index) {
    final fileType = _getFileType(media);
    final isVideo = fileType == FileType.video;
    final thumbnailBytes = _videoThumbnails[media.path];
    final isLoading = _thumbnailLoading[media.path] ?? false;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: isVideo
                ? _buildVideoThumbnail(thumbnailBytes, isLoading)
                : _buildImageThumbnail(media),
          ),
        ),

        // Video indicator overlay (only for videos)
        if (isVideo)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'VIDEO',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Close button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(index),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:  AppColors.primaryColor,
              ),
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.close,
                size: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoThumbnail(Uint8List? thumbnailBytes, bool isLoading) {
    if (isLoading) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 8.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
      return Image.memory(
        thumbnailBytes,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error displaying video thumbnail: $error');
          return _buildVideoPlaceholder();
        },
      );
    }

    return _buildVideoPlaceholder();
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 24.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 4.h),
            Text(
              'Video',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(XFile media) {
    return Image.file(
      File(media.path),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error displaying image: $error');
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 24.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Image',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadBusinessImages() async {
    if (_selectedMedia.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert XFile to File
      List<File> files = _selectedMedia.map((xFile) => File(xFile.path)).toList();

      final userId = await SecureStorageHelper.getString("userId");

      // Call the API
      BusinessImagesAndVideoModel response = await _createCardService.updateBusinessImagesAndVideo(
        userId: userId!,
        images: files,
      );

      if (response.status) {
        // Success - navigate to next screen
        showToast(
          message: response.message,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pushNamed(context, Routes.bottomNavigation);
      } else {
        // Show error message
        showToast(
          message: response.message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Handle error
      showToast(
        message: 'Error uploading files: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            customLinkButton: false,
            showBackButton: true,
            title: "Business Images",
            subtitle: 'Make your profile more engaging with a clear image.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 160.h),

                // Upload Area
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: GestureDetector(
                    onTap: _pickMedia,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(16),
                      padding: EdgeInsets.zero,
                      color: const Color(0xFFA9B0BC),
                      strokeWidth: 1,
                      dashPattern: [5, 3],
                      child: Container(
                        width: double.infinity,
                        height: 120.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: AppColors.uploadColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    AppAssets.uploadIcon,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                'Upload Image & Video',
                                style: TextStyle(
                                  color: AppColors.textHeaderColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Grid View
                if (_selectedMedia.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      height: 310.h,
                      child: GridView.builder(
                        itemCount: _selectedMedia.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.h,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          return _buildMediaItem(_selectedMedia[index], index);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Button
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
          //               Navigator.pushNamed(context, Routes.bottomNavigation);
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
          //               title: _isLoading ? 'Uploading...' : 'Continue (05/5)',
          //               onTap: _isButtonEnabled && !_isLoading
          //                   ? _uploadBusinessImages
          //                   : null,
          //               color: _isButtonEnabled
          //                   ? AppColors.primaryColor
          //                   : AppColors.buttonDisableColor,
          //               textColor: _isButtonEnabled
          //                   ? AppColors.whiteColor
          //                   : AppColors.textFieldColor,
          //               fontSize: 16.sp,
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
          color: AppColors.whiteColor,
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.bottomNavigation);
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
                    title: _isLoading ? 'Uploading...' : 'Continue (05/5)',
                    onTap: _isButtonEnabled && !_isLoading
                        ? _uploadBusinessImages
                        : null,
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

enum FileType {
  image,
  video,
  pdf,
  unsupported,
}