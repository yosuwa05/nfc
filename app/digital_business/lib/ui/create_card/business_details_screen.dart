import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/helper/app_routes.dart';
import '../../common/helper/pref.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_textfield.dart';
import '../../common/widgets/custom_styled_page.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/toast.dart';
import '../../entities/create_card_entity/create_card_entities.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../../repository/create_card_repository/create_card_repository.dart';

class BusinessDetailsScreen extends StatefulWidget {
  final String? userId;
  const BusinessDetailsScreen({
    super.key,
    this.userId,
  });

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final _phoneNumberController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _webSiteLinkController = TextEditingController();
  final CreateCardRepository _createCardRepository = CreateCardRepository();
  bool _isLoading = false;
  Country _selectedCountry = Country.parse('IN');
  bool _isButtonEnabled = false;
  final AuthRepository authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  String fcmToken = "";
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  final Map<String, int> _countryPhoneLengths = {
    'AF': 9,    // Afghanistan
    'AL': 9,    // Albania
    'DZ': 9,    // Algeria
    'AD': 6,    // Andorra
    'AO': 9,    // Angola
    'AG': 10,   // Antigua and Barbuda
    'AR': 10,   // Argentina
    'AM': 8,    // Armenia
    'AU': 9,    // Australia
    'AT': 10,   // Austria
    'AZ': 9,    // Azerbaijan
    'BS': 10,   // Bahamas
    'BH': 8,    // Bahrain
    'BD': 10,   // Bangladesh
    'BB': 10,   // Barbados
    'BY': 9,    // Belarus
    'BE': 9,    // Belgium
    'BZ': 7,    // Belize
    'BJ': 8,    // Benin
    'BT': 8,    // Bhutan
    'BO': 8,    // Bolivia
    'BA': 8,    // Bosnia and Herzegovina
    'BW': 8,    // Botswana
    'BR': 11,   // Brazil
    'BN': 7,    // Brunei
    'BG': 9,    // Bulgaria
    'BF': 8,    // Burkina Faso
    'BI': 8,    // Burundi
    'CV': 7,    // Cabo Verde
    'KH': 9,    // Cambodia
    'CM': 9,    // Cameroon
    'CA': 10,   // Canada
    'CF': 8,    // Central African Republic
    'TD': 8,    // Chad
    'CL': 9,    // Chile
    'CN': 11,   // China
    'CO': 10,   // Colombia
    'KM': 7,    // Comoros
    'CG': 9,    // Congo (Congo-Brazzaville)
    'CR': 8,    // Costa Rica
    'CI': 8,    // Côte d'Ivoire
    'HR': 9,    // Croatia
    'CU': 8,    // Cuba
    'CY': 8,    // Cyprus
    'CZ': 9,    // Czechia (Czech Republic)
    'CD': 9,    // Democratic Republic of the Congo
    'DK': 8,    // Denmark
    'DJ': 6,    // Djibouti
    'DM': 10,   // Dominica
    'DO': 10,   // Dominican Republic
    'EC': 9,    // Ecuador
    'EG': 10,   // Egypt
    'SV': 8,    // El Salvador
    'GQ': 9,    // Equatorial Guinea
    'ER': 7,    // Eritrea
    'EE': 8,    // Estonia
    'SZ': 8,    // Eswatini
    'ET': 9,    // Ethiopia
    'FJ': 7,    // Fiji
    'FI': 9,    // Finland
    'FR': 9,    // France
    'GA': 7,    // Gabon
    'GM': 7,    // Gambia
    'GE': 9,    // Georgia
    'DE': 10,   // Germany
    'GH': 9,    // Ghana
    'GR': 10,   // Greece
    'GD': 10,   // Grenada
    'GT': 8,    // Guatemala
    'GN': 8,    // Guinea
    'GW': 7,    // Guinea-Bissau
    'GY': 7,    // Guyana
    'HT': 8,    // Haiti
    'HN': 8,    // Honduras
    'HU': 9,    // Hungary
    'IS': 7,    // Iceland
    'IN': 10,   // India
    'ID': 10,   // Indonesia
    'IR': 10,   // Iran
    'IQ': 10,   // Iraq
    'IE': 9,    // Ireland
    'IL': 9,    // Israel
    'IT': 10,   // Italy
    'JM': 10,   // Jamaica
    'JP': 10,   // Japan
    'JO': 9,    // Jordan
    'KZ': 10,   // Kazakhstan
    'KE': 9,    // Kenya
    'KI': 5,    // Kiribati
    'KW': 8,    // Kuwait
    'KG': 9,    // Kyrgyzstan
    'LA': 9,    // Laos
    'LV': 8,    // Latvia
    'LB': 8,    // Lebanon
    'LS': 8,    // Lesotho
    'LR': 8,    // Liberia
    'LY': 9,    // Libya
    'LI': 9,    // Liechtenstein
    'LT': 8,    // Lithuania
    'LU': 9,    // Luxembourg
    'MG': 9,    // Madagascar
    'MW': 9,    // Malawi
    'MY': 9,    // Malaysia
    'MV': 7,    // Maldives
    'ML': 8,    // Mali
    'MT': 8,    // Malta
    'MH': 7,    // Marshall Islands
    'MR': 8,    // Mauritania
    'MU': 8,    // Mauritius
    'MX': 10,   // Mexico
    'FM': 7,    // Micronesia
    'MD': 8,    // Moldova
    'MC': 9,    // Monaco
    'MN': 8,    // Mongolia
    'ME': 8,    // Montenegro
    'MA': 9,    // Morocco
    'MZ': 9,    // Mozambique
    'MM': 9,    // Myanmar
    'NA': 9,    // Namibia
    'NR': 7,    // Nauru
    'NP': 10,   // Nepal
    'NL': 9,    // Netherlands
    'NZ': 9,    // New Zealand
    'NI': 8,    // Nicaragua
    'NE': 8,    // Niger
    'NG': 10,   // Nigeria
    'KP': 10,   // North Korea
    'MK': 8,    // North Macedonia
    'NO': 8,    // Norway
    'OM': 8,    // Oman
    'PK': 10,   // Pakistan
    'PW': 7,    // Palau
    'PA': 8,    // Panama
    'PG': 8,    // Papua New Guinea
    'PY': 9,    // Paraguay
    'PE': 9,    // Peru
    'PH': 10,   // Philippines
    'PL': 9,    // Poland
    'PT': 9,    // Portugal
    'QA': 8,    // Qatar
    'RO': 9,    // Romania
    'RU': 10,   // Russia
    'RW': 9,    // Rwanda
    'KN': 10,   // Saint Kitts and Nevis
    'LC': 10,   // Saint Lucia
    'VC': 10,   // Saint Vincent and the Grenadines
    'WS': 7,    // Samoa
    'SM': 10,   // San Marino
    'ST': 7,    // São Tomé and Príncipe
    'SA': 9,    // Saudi Arabia
    'SN': 9,    // Senegal
    'RS': 9,    // Serbia
    'SC': 7,    // Seychelles
    'SL': 8,    // Sierra Leone
    'SG': 8,    // Singapore
    'SK': 9,    // Slovakia
    'SI': 8,    // Slovenia
    'SB': 5,    // Solomon Islands
    'SO': 8,    // Somalia
    'ZA': 9,    // South Africa
    'KR': 10,   // South Korea
    'SS': 9,    // South Sudan
    'ES': 9,    // Spain
    'LK': 9,    // Sri Lanka
    'SD': 9,    // Sudan
    'SR': 7,    // Suriname
    'SE': 9,    // Sweden
    'CH': 9,    // Switzerland
    'SY': 9,    // Syria
    'TJ': 9,    // Tajikistan
    'TZ': 9,    // Tanzania
    'TH': 9,    // Thailand
    'TL': 8,    // Timor-Leste
    'TG': 8,    // Togo
    'TO': 7,    // Tonga
    'TT': 10,   // Trinidad and Tobago
    'TN': 8,    // Tunisia
    'TR': 10,   // Turkey
    'TM': 8,    // Turkmenistan
    'TV': 5,    // Tuvalu
    'UG': 9,    // Uganda
    'UA': 9,    // Ukraine
    'AE': 9,    // United Arab Emirates
    'GB': 10,   // United Kingdom
    'US': 10,   // United States
    'UY': 8,    // Uruguay
    'UZ': 9,    // Uzbekistan
    'VU': 7,    // Vanuatu
    'VE': 10,   // Venezuela
    'VN': 9,    // Vietnam
    'YE': 9,    // Yemen
    'ZM': 9,    // Zambia
    'ZW': 9,    // Zimbabwe
    'VA': 10,   // Holy See (Vatican City)
    'PS': 9,    // State of Palestine
  };

  @override
  void initState() {
    super.initState();
    print('DEBUG: Received widget.userId: ${widget.userId}');
    _phoneNumberController.addListener(_validateForm);
    _companyNameController.addListener(_validateForm);
    _companyAddressController.addListener(_validateForm);
    _companyEmailController.addListener(_validateForm);
    _webSiteLinkController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Clean up the controllers
    _phoneNumberController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyEmailController.dispose();
    _webSiteLinkController.dispose();
    super.dispose();
  }

  void _onCountryChanged(Country country) {
    setState(() {
      _selectedCountry = country;
    });
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



  Future<void> _launchURL(String url) async {
    // Add 'https://' if no scheme is provided
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  void _validateForm() {
    final phoneNumber = _phoneNumberController.text.trim();
    final companyName = _companyNameController.text.trim();
    final companyAddress = _companyAddressController.text.trim();
    final companyEmail = _companyEmailController.text.trim();
    final websiteLink = _webSiteLinkController.text.trim();

    final isPhoneValid = phoneNumber.isNotEmpty && phoneNumber.length == 10 && RegExp(r'^\d+$').hasMatch(phoneNumber);
    final isEmailValid = companyEmail.isNotEmpty && _validateEmailFormat(companyEmail);

    setState(() {
      _isButtonEnabled = isPhoneValid &&
          companyName.isNotEmpty &&
          companyAddress.isNotEmpty &&
          isEmailValid &&
          websiteLink.isNotEmpty;
    });
  }

  bool _validateEmailFormat(String email) {
    // Basic email format validation
    if (email.isEmpty) return false;

    // Enhanced regex for common domain extensions
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );

    // Check basic format first
    if (!emailRegex.hasMatch(email)) return false;

    // List of common domain extensions
    const commonDomains = [
      'com', 'org', 'net', 'io', 'in', 'co', 'edu', 'gov', 'mil',
      'biz', 'info', 'me', 'us', 'uk', 'ca', 'au', 'nz', 'jp',
      'fr', 'de', 'it', 'es', 'ru', 'cn', 'br', 'mx',
      'yahoo', 'gmail', 'hotmail', 'outlook', 'protonmail', 'icloud'
    ];

    // Extract domain part after @
    final domainParts = email.split('@').last.split('.');
    if (domainParts.length < 2) return false;

    // Check if the domain extension is valid
    for (var part in domainParts) {
      if (commonDomains.contains(part.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  Future<String?> login() async {
    try {
      final userId = await SecureStorageHelper.getString('userId');
      print('Debug: Retrieved user ID from storage: $userId');
      return userId;
    } catch (e) {
      print('Debug: Error retrieving user ID: $e');
      return null;
    }
  }

  Future<void> _saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('companyName', _companyNameController.text.trim());
    await prefs.setString('companyAddress', _companyAddressController.text.trim());
    await prefs.setString('companyEmail', _companyEmailController.text.trim());
    await prefs.setString('companyMobile', '+${_selectedCountry.phoneCode}${_phoneNumberController.text.trim()}');
    await prefs.setString('companyWebsite', _webSiteLinkController.text.trim());
  }

  Future<void> _submitBusinessDetails() async {
    if (!_formKey.currentState!.validate()) {
      print('Debug: Form validation failed');
      showToast(
        message: 'Please fill in all required fields.',
        backgroundColor: AppColors.redColor,
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _saveLocally();

    try {
      print('DEBUG: Retrieving user ID...');
      String? userId = await SecureStorageHelper.getString('userId');
      print('DEBUG: Retrieved user ID from storage: $userId');

      // Fallback to widget.userId if storage userId is null or empty
      if (userId == null || userId.isEmpty) {
        userId = widget.userId;
        print('DEBUG: Using widget.userId as fallback: $userId');
      }

      if (userId == null || userId.isEmpty) {
        showToast(
          message: 'Error: User ID not found. Please log in again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.redColor,
          textColor: Colors.white,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final businessDetailsEntity = BusinessDetailsEntity(
        companyName: _companyNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        companyMobile: '+${_selectedCountry.phoneCode}${_phoneNumberController.text.trim()}',
        companyEmail: _companyEmailController.text.trim(),
        companyWebsite: _webSiteLinkController.text.trim(),
      );

      // Convert XFile to File if image is selected
      File? companyLogoFile;
      if (_selectedImage != null) {
        companyLogoFile = File(_selectedImage!.path);
      }

      final response = await _createCardRepository.getBusinessDetail(
        businessDetailsEntity: businessDetailsEntity,
        companyLogo: companyLogoFile,
        userId: userId,
      );

      // Fix the type casting issue - handle both bool and int status
      bool isSuccess = false;
      if (response.status is bool) {
        isSuccess = response.status!;
      } else if (response.status is int) {
        isSuccess = response.status == 1;
      }

      if (isSuccess) {
        await SecureStorageHelper.setString("businessDetailsCompleted", "true");

        showToast(
          message: response.message ?? 'Business details saved successfully!',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: AppColors.greenColor,
          textColor: Colors.white,
          gravity: ToastGravity.TOP,
        );

        Navigator.pushNamed(context, Routes.addProfilePicture);
      } else {
        showToast(
          message: response.message ?? 'Failed to save business details',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: AppColors.redColor,
          textColor: Colors.white,
          gravity: ToastGravity.TOP,
        );
      }
    } catch (e) {
      print('DEBUG: Error in _submitBusinessDetails: $e');
      showToast(
        message: 'Error: Failed to submit business details. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: AppColors.redColor,
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
            showBackButton: false,
            title: "Business Details",
            subtitle: 'Add business info to build trusted business profile',
            child: Column(
              children: [
                SizedBox(height: 180.h),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 72.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Company Name
                          Padding(
                            padding: EdgeInsets.only(left: 16.0.w),
                            child: CustomTextHeader(
                              textHeader: 'Company Name',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0,right: 16),
                            child: CustomTextfield(
                              controller: _companyNameController,
                              hintText: 'Your business name (e.g., Technologies)',
                              inputFormatters: [CapitalizeFirstLetterFormatter()],
                              onChanged: (_) => _validateForm(),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Company Address
                          Padding(
                            padding: EdgeInsets.only(left: 16.0.w),
                            child: CustomTextHeader(
                              textHeader: 'Company Address',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0,right: 16),
                            child: CustomTextfield(
                              controller: _companyAddressController,
                              inputFormatters: [CapitalizeFirstLetterFormatter()],
                              hintText: 'Business location (e.g., Indira Nagar, Bengaluru)',
                              onChanged: (_) => _validateForm(),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Company Email
                          Padding(
                            padding: EdgeInsets.only(left: 16.0.w),
                            child: CustomTextHeader(
                              textHeader: 'Company Email',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0,right: 16),
                            child: CustomTextfield(
                              controller: _companyEmailController,
                              hintText: 'Work email (e.g., contact@nexora.tech)',
                              keyboardType: TextInputType.emailAddress,
                              forceLowerCase: true,
                              onChanged: (_) => _validateForm(),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Company Phone Number
                          Padding(
                            padding: EdgeInsets.only(left: 16.0.w),
                            child: CustomTextHeader(
                              textHeader: 'Company Phone Number',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                            child: CustomPhoneField(
                              controller: _phoneNumberController,
                              onCountryChanged: _onCountryChanged,
                              hintText: 'Enter 10 digit phone number',
                              countryPhoneLengths: _countryPhoneLengths, // Pass the map
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Website Link
                          Padding(
                            padding: EdgeInsets.only(left: 16.0.w),
                            child: CustomTextHeader(
                              textHeader: 'Website Link',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                            child:
                            CustomTextfield(
                            controller: _webSiteLinkController,
                            isSuffixIcon: true,
                            hintText: 'Website URL (e.g., www.example.com)',
                            onChanged: (_) => _validateForm(),
                            inputFormatters: [
                              LowerCaseTextFormatter(), // Ensure lowercase input
                              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9./:]')), // Allow URL characters
                            ]
                          ),
                          ),
                          SizedBox(height: 10.h),
                          // // Company Logo
                          Padding(
                            padding: EdgeInsets.only(left: 16.0.w),
                            child: CustomTextHeader(
                              textHeader: 'Company Logo',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (_selectedImage == null)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 2.h),
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(16.r),
                                  padding: EdgeInsets.zero,
                                  color: const Color(0xFFA9B0BC),
                                  strokeWidth: 1,
                                  dashPattern: [5, 3],
                                  child: Container(
                                    width: 100.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F6F9),
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 35.w,
                                            height: 35.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.uploadColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.r),
                                              child: SvgPicture.asset(
                                                AppAssets.uploadIcon,
                                                width: 20.w,
                                                height: 20.h,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              'Upload Company Logo',
                                              style: TextStyle(
                                                color: AppColors.textHeaderColor,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
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
                              padding: EdgeInsets.all(12.r),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Image.file(
                                      File(_selectedImage!.path),
                                      width: 100.w,
                                      height: 100.h,
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
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed bottom buttons
          // Positioned(
          //   bottom: 0.h,
          //   left: 0,
          //   right: 0,
          //   child: SafeArea(
          //     top: false,
          //     child: Container(
          //       // decoration: BoxDecoration(
          //       //   border: Border.all(color: AppColors.borderColor),
          //       //     color: Colors.white,
          //       //   borderRadius: BorderRadius.only(
          //       //     topLeft: Radius.circular(12.r),
          //       //     topRight: Radius.circular(12.r),
          //       //   )
          //       // ),
          //       padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 4.h),
          //       child: Row(
          //         children: [
          //           GestureDetector(
          //             onTap: () {
          //               Navigator.pushNamed(
          //                 context,
          //                 Routes.addProfilePicture,
          //               );
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
          //             child: Padding(
          //               padding: EdgeInsets.symmetric(vertical: 8.h),
          //               child: CustomButton(
          //                 title: _isLoading ? 'Submitting...' : 'Continue (01/5)',
          //                 onTap: _isButtonEnabled && !_isLoading ? _submitBusinessDetails : null,
          //                 color: _isButtonEnabled
          //                     ? AppColors.primaryColor
          //                     : AppColors.buttonDisableColor,
          //                 textColor: _isButtonEnabled
          //                     ? AppColors.whiteColor
          //                     : AppColors.textFieldColor,
          //                 fontSize: 16.sp,
          //                 fontWeight: FontWeight.w600,
          //                 expanded: true,
          //               ),
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
        child:  SafeArea(
        top: false,
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.addProfilePicture,
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
                  title: _isLoading ? 'Submitting...' : 'Continue (01/5)',
                  onTap: _isButtonEnabled && !_isLoading ? _submitBusinessDetails : null,
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