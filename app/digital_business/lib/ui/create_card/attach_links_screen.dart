import 'dart:io';

import 'package:digital_business/common/widgets/custom_attach_link_container.dart';
import 'package:digital_business/common/widgets/custom_tab_bar.dart';
import 'package:digital_business/common/widgets/custom_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/helper/app_routes.dart';
import '../../common/helper/pref.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_select_industries_container.dart';
import '../../common/widgets/custom_styled_page.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/toast.dart';
import '../../model/create_card_model/attach_links_model/get_attach_link_model.dart';
import '../../services/create_card_service/create_card_service.dart';

class AttachLinksScreen extends StatefulWidget {
  const AttachLinksScreen({super.key});

  @override
  State<AttachLinksScreen> createState() => _AttachLinksScreenState();
}

class _AttachLinksScreenState extends State<AttachLinksScreen> {
  String? _currentLink;
  int _currentIndex = 0;
  bool _isButtonEnabled = false;
  List<String> _tabs = [];
  List<AttachLinksData> _attachLinksData = [];
  List<SubCategories> _currentSubCategories = [];
  List<SubCategories> _filteredSubCategories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isUpdating = false;
  final CreateCardService _createCardService = CreateCardService();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _selectedLinks = [];


  @override
  void initState() {
    super.initState();
    _fetchAttachLinks();
    _searchController.addListener(_filterSubCategories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSubCategories);
    _searchController.dispose();
    super.dispose();
  }


  void _onLinkAdded(String link, String subCategoryId) {
    // Validate the inputs
    if (link.isEmpty || subCategoryId.isEmpty) {
      return;
    }

    setState(() {
      _currentLink = link;
      _isButtonEnabled = true;

      _selectedLinks.add({
        'category': _attachLinksData[_currentIndex].sId ?? '',
        'subCategoryId': subCategoryId,
        'url': link,
      });
    });
  }

  void _onLinkRemoved() {
    setState(() {
      if (_selectedLinks.isNotEmpty) {
        _selectedLinks.removeLast();
      }

      // Update button state based on whether we have any links
      _isButtonEnabled = _selectedLinks.isNotEmpty;
      _currentLink = _selectedLinks.isNotEmpty ? _selectedLinks.last['url'] : null;
    });
  }

  Future<void> _fetchAttachLinks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _createCardService.getAttachLinks();

      if (response.success == true && response.data != null) {
        setState(() {
          _attachLinksData = response.data!;
          _tabs = _attachLinksData.map((item) => item.name ?? '').toList();
          _isLoading = false;

          // Set initial subcategories for first tab
          if (_attachLinksData.isNotEmpty) {
            _currentSubCategories = _attachLinksData[0].subCategories ?? [];
            _filteredSubCategories = List.from(_currentSubCategories);
          }
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAttachedLinks() async {
    final userId = await SecureStorageHelper.getString("userId");

    if (userId == null || userId.isEmpty) {
      showToast(message: 'User ID not found');
      return;
    }

    // Check if we have any valid links
    final groupedLinks = _groupLinksByCategory();
    if (groupedLinks.isEmpty) {
      showToast(message: 'Please add at least one link before continuing');
      return;
    }

    try {
      setState(() {
        _isUpdating = true;
      });
      final payload = {
        "attachedLinks": groupedLinks,
      };

      print('Sending payload: $payload');

      final response = await _createCardService.updateAttachedLinks(userId: userId, payload: payload);

      if (response.status == true) {
        showToast(message: response.message ?? 'Attached links updated successfully', backgroundColor: AppColors.greenColor);
        if (mounted) {
          Navigator.pushNamed(
            context,
            Routes.businessImages,
          );
        }
      } else {
        showToast(message: response.message ?? 'Failed to update links');
      }
    } catch (e) {
      showToast(message: 'Error updating links: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }


  List<Map<String, dynamic>> _groupLinksByCategory() {
    Map<String, List<Map<String, String>>> groupedLinks = {};

    for (var link in _selectedLinks) {
      String categoryId = link['category'] ?? '';
      String subCategoryId = link['subCategoryId'] ?? '';
      String url = link['url'] ?? '';

      // Only process if we have valid data
      if (categoryId.isNotEmpty && subCategoryId.isNotEmpty && url.isNotEmpty) {
        if (!groupedLinks.containsKey(categoryId)) {
          groupedLinks[categoryId] = [];
        }
        groupedLinks[categoryId]!.add({
          'subCategoryId': subCategoryId,
          'url': url,
        });
      }
    }

    // If no links were selected, return empty array
    if (groupedLinks.isEmpty) {
      return [];
    }

    return groupedLinks.entries.map((entry) => {
      'category': entry.key,
      'subCategories': entry.value,
    }).toList();
  }



  void _onTabChanged(int index) {
    if (_currentIndex != index && index < _attachLinksData.length) {
      setState(() {
        _currentIndex = index;
        _currentSubCategories = _attachLinksData[index].subCategories ?? [];
        _filteredSubCategories = List.from(_currentSubCategories);
      });
    }
  }

  void _filterSubCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSubCategories = List.from(_currentSubCategories);
      } else {
        _filteredSubCategories = _currentSubCategories
            .where((subCategory) =>
        subCategory.name?.toLowerCase().contains(query) == true)
            .toList();
      }
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _fetchAttachLinks,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesList() {
    if (_filteredSubCategories.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No apps found for "${_searchController.text}"'
              : 'No apps available',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textFieldColor,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSubCategories.length,
      itemBuilder: (context, index) {
        final subCategory = _filteredSubCategories[index];

        // Only show active subcategories
        if (subCategory.isActive != true) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: CustomAttachLinkContainer(
            key: ValueKey(subCategory.sId ?? subCategory.name ?? index),
            height: 56.h,
            width: double.infinity,
            radius: 6.r,
            subCategory: subCategory,
            onLinkAdded: _onLinkAdded,
            onLinkRemoved: _onLinkRemoved,
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          CustomStyledPage(
            showTitle: true,
            customLinkButton: false,
            showBackButton: true,
            title: "Attach Links",
            subtitle: 'Make your profile more engaging with a clear image.',
            child: Column(
              children: [
                SizedBox(height: 170.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 72.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16.w,left: 16.w),
                          child: CustomSearchField(
                            controller: _searchController,
                            hintText: 'Search apps',
                            prefixIcon: SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: SvgPicture.asset(AppAssets.searchIcon),
                            ),
                          ),
                        ),
                        if(_tabs.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(right: 16.w,left: 16.w,top: 10.h),
                          child: CustomTabBar(
                              tabs: _tabs,
                              onTabChanged: _onTabChanged
                          ),
                        ),
                        _buildSubCategoriesList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
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
        child:SafeArea(
          top: false,
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _isUpdating ? null : () {
                    Navigator.pushNamed(
                      context,
                      Routes.businessImages,
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
                    title: 'Continue (04/5)',
                    onTap: (_isButtonEnabled && !_isUpdating)
                        ? _updateAttachedLinks
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


class CustomLinkBottomSheet extends StatefulWidget {
  const CustomLinkBottomSheet({super.key});

  @override
  State<CustomLinkBottomSheet> createState() => _CustomLinkBottomSheetState();
}

class _CustomLinkBottomSheetState extends State<CustomLinkBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  final _companyNameController = TextEditingController();
  final _customLinkController = TextEditingController();

  void _validateForm() {
    final companyName = _companyNameController.text.trim();
    final customLink = _customLinkController.text.trim();
  }


  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Add Custom Link',
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: AppColors.textHeaderColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34.w,
                        height: 29.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1.w,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 18.sp,
                            color: AppColors.textHeaderColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // Upload area
              if (_selectedImage == null)
              // Upload area (show only if no image selected)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(16),
                      padding: EdgeInsets.zero,
                      color: const Color(0xFFA9B0BC),
                      strokeWidth: 1,
                      dashPattern: [5, 3],
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.h,
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
                                'Upload App Icon',
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
                )
              else
              // Image preview with remove option (centered)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: 72.w,
                          height: 58.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: AppColors.backgroundColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  CustomTextHeader(
                    textHeader: 'Company Name',
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              CustomTextfield(
                controller: _companyNameController,
                hintText: 'Your business name (e.g., Technologies)',
                inputFormatters: [CapitalizeFirstLetterFormatter()],
                onChanged: (_) => _validateForm(),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  CustomTextHeader(
                    textHeader: 'Custom Link',
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              CustomTextfield(
                controller: _customLinkController,
                hintText: 'Attach link (e.g., www.example.com)',
                inputFormatters: [CapitalizeFirstLetterFormatter()],
                onChanged: (_) => _validateForm(),
              ),
              SizedBox(height: 10.h),
              CustomButton(
                title: 'Add Link',
                color: AppColors.primaryColor,
                height: 40.h,
                radius: 8.r,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

