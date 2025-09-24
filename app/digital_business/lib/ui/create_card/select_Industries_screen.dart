import 'package:digital_business/common/widgets/custom_textfield.dart';
import 'package:digital_business/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/helper/app_routes.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_select_industries_container.dart';
import '../../common/widgets/custom_styled_page.dart';
import '../../core/constants/api_url.dart';
import '../../core/constants/toast.dart';
import '../../model/create_card_model/select_industries_model/get_all_Industries_model.dart';
import '../../services/create_card_service/create_card_service.dart';

class SelectIndustriesScreen extends StatefulWidget {
  const SelectIndustriesScreen({super.key});

  @override
  State<SelectIndustriesScreen> createState() => _SelectIndustriesScreenState();
}

class _SelectIndustriesScreenState extends State<SelectIndustriesScreen> {
  bool _isButtonEnabled = false;
  bool _isSubmitting = false;
  final CreateCardService _createCardService = CreateCardService();

  // Pagination variables
  List<GetAllIndustriesData> _industriesList = [];
  int _currentPage = 1;
  final int _perPageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Selection and services tracking
  final Set<int> _selectedIndustries = {};
  final Map<int, List<String>> _servicesMap = {};
  final Map<int, TextEditingController> _controllersMap = {};

  @override
  void initState() {
    super.initState();
    _fetchIndustries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final c in _controllersMap.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _fetchIndustries();
      }
    }
  }

  Future<void> _fetchIndustries() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _createCardService.getAllIndustries();

      if (response.success) {
        setState(() {
          _industriesList.addAll(response.data);
          _currentPage++;
          _hasMore = response.data.length == _perPageSize;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      print('Error fetching industries: $e');
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  void _addService(int index) {
    final controller = _controllersMap[index]!;
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _servicesMap.putIfAbsent(index, () => []).add(text);
        controller.clear();
        _updateButtonState();
      });
    }
  }

  void _removeService(int index, int chipIndex) {
    setState(() {
      _servicesMap[index]?.removeAt(chipIndex);
      _updateButtonState();
    });
  }

  void _toggleIndustrySelection(int index) {
    setState(() {
      if (_selectedIndustries.contains(index)) {
        _selectedIndustries.remove(index);
        // Clear services when unselecting industry
        _servicesMap.remove(index);
      } else {
        _selectedIndustries.add(index);
      }
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    bool hasValidSelections = false;

    for (int index in _selectedIndustries) {
      final services = _servicesMap[index] ?? [];
      if (services.isNotEmpty) {
        hasValidSelections = true;
        break;
      }
    }

    setState(() {
      _isButtonEnabled = hasValidSelections;
    });
  }

  Future<void> _submitSelectedIndustries() async {
    if (_isSubmitting || !_isButtonEnabled) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare the selected industries data
      List<Map<String, dynamic>> selectedIndustriesData = [];

      for (int index in _selectedIndustries) {
        final services = _servicesMap[index] ?? [];
        if (services.isNotEmpty) {
          selectedIndustriesData.add({
            "industry": _industriesList[index].id, // Assuming the industry model has an id field
            "tags": services,
          });
        }
      }

      if (selectedIndustriesData.isEmpty) {
        showToast(
          message: 'Please select at least one industry with services',
          backgroundColor: Colors.red,
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Call the API - you'll need to get the actual userId from your auth system
      const String userId = ""; // Replace with actual user ID

      final response = await _createCardService.selectedIndustriesTags(
        userId: userId,
        selectedIndustries: selectedIndustriesData,
      );

      setState(() {
        _isSubmitting = false;
      });

      // Handle success
      showToast(
        message: 'Industries updated successfully',
        backgroundColor: AppColors.greenColor,
      );

      // Navigate to next screen
      Navigator.pushNamed(context, Routes.attachLinks);

    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      showToast(
        message: 'Error: ${e.toString()}',
        backgroundColor: AppColors.redColor,
      );
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
            showBackButton: true,
            title: "Select Industries",
            subtitle: 'Make your profile more engaging with a clear image.',
            child: Column(
              children: [
                SizedBox(height: 140.h),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 72.h),
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _industriesList.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _industriesList.length) {
                              return _isLoading
                                  ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                                  : const SizedBox.shrink();
                            }

                            final industry = _industriesList[index];
                            final isSelected = _selectedIndustries.contains(index);

                            // Ensure controller exists
                            _controllersMap.putIfAbsent(
                                index, () => TextEditingController());

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.r,vertical: 8.h),
                              child: CustomSelectIndustriesContainer(
                                title: industry.title,
                                onTap: () => _toggleIndustrySelection(index),
                                height: 56.h,
                                width: double.infinity,
                                radius: 12.r,
                                containerColor: AppColors.whiteColor,
                                textColor: AppColors.textColor,
                                containerBorderColor: AppColors.primaryColor,
                                icon: Container(
                                  width: 40.h,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0.r),
                                    child: ClipOval(
                                      child: industry.image.isNotEmpty
                                          ? Image.network(
                                        '${ApiUrl.imageUrl}${industry.image}',
                                        width: 38.h,
                                        height: 38.h,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        width: 40.h,
                                        height: 40.h,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: SvgPicture.asset(
                                            AppAssets.googleIcon,
                                            width: 20.h,
                                            height: 20.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                showCheckbox: true,
                                initiallyChecked: false,
                                isChecked: isSelected,
                                child: isSelected ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8.h), // Add some spacing
                                    if ((_servicesMap[index] ?? []).isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: 8.h),
                                        child: Wrap(
                                          spacing: 8.w,
                                          runSpacing: 8.h,
                                          children: List.generate(
                                            _servicesMap[index]!.length,
                                                (chipIndex) => Container(
                                              height: 29.h,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30.r),
                                                border: Border.all(
                                                  color: const Color(0xFF784DDD).withOpacity(0.4),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      _servicesMap[index]![chipIndex],
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        color: const Color(0xFF784DDD),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    InkWell(
                                                      onTap: () => _removeService(index, chipIndex),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: const Color(0xFF784DDD),
                                                        size: 18.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    CustomTextfield(
                                      showAddButton: true,
                                      controller: _controllersMap[index]!,
                                      hintText: 'Enter Services',
                                      isSuffixIcon: true,
                                      onAddTap: () => _addService(index),
                                    ),
                                  ],
                                ) : null,
                              ),
                            );
                          },
                        ),
                        if (_industriesList.isEmpty && !_isLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.h),
                            child: Text(
                              'No Industries Available',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.attachLinks);
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
                    title: _isSubmitting ? 'Submitting...' : 'Continue (03/5)',
                    onTap: _isButtonEnabled && !_isSubmitting ? _submitSelectedIndustries : null,
                    color: _isButtonEnabled && !_isSubmitting
                        ? AppColors.primaryColor
                        : AppColors.buttonDisableColor,
                    textColor: _isButtonEnabled && !_isSubmitting
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