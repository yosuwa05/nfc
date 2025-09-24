import 'package:country_picker/country_picker.dart';
import 'package:digital_business/common/widgets/custom_button.dart';
import 'package:digital_business/common/widgets/custom_container.dart';
import 'package:digital_business/common/widgets/custom_styled_page.dart';
import 'package:digital_business/common/widgets/custom_textfield.dart';
import 'package:digital_business/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../common/helper/app_routes.dart';
import '../../common/helper/pref.dart';
import '../../common/theme/app_colors.dart';
import '../../core/constants/toast.dart';
import '../../repository/auth_repository/auth_repository.dart';
import 'otp_verification_screen.dart';

class LoginAccountScreen extends StatefulWidget {
  const LoginAccountScreen({super.key});

  @override
  State<LoginAccountScreen> createState() => _LoginAccountScreenState();
}

class _LoginAccountScreenState extends State<LoginAccountScreen> with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  final AuthRepository authRepository = AuthRepository();
  final _phoneNumberController = TextEditingController();
  final _userNameController = TextEditingController();
  Country _selectedCountry = Country.parse('IN');
  String? _appSignature;
  late AnimationController _animationController;
  bool _isLoading = false;
  String? _otpId;


  // Define required phone number lengths for different countries
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
    _userNameController.addListener(_validateInputs);
    _phoneNumberController.addListener(_validateInputs);
    _initializeSmsAutofill();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _validateInputs() {
    // final userName = _userNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final requiredLength = _countryPhoneLengths[_selectedCountry.countryCode] ?? 10;
    final isValid = phoneNumber.length == requiredLength && RegExp(r'^\d+$').hasMatch(phoneNumber);
    print('Phone: $phoneNumber, Length: ${phoneNumber.length}, Required: $requiredLength, IsValid: $isValid');
    setState(() {
      _isButtonEnabled = isValid;
    });
  }

  Future<void> _initializeSmsAutofill() async {
    try {
      _appSignature = await SmsAutoFill().getAppSignature ?? '';
      print("App Signature: $_appSignature");
    } catch (e) {
      print("SMS autofill initialization error: $e");
    _appSignature = '';
      showToast(
        message: 'Failed to initialize SMS autofill',
        backgroundColor: AppColors.redColor,
      );
    }
  }

  void _onCountryChanged(Country country) {
    setState(() {
      _selectedCountry = country;
    });
    _validateInputs();
  }

  Future<void> _sendOtp() async {
    print('Button clicked: _isButtonEnabled: $_isButtonEnabled, _isLoading: $_isLoading');
    if (!_isButtonEnabled || _isLoading) {
      print('Button disabled or already loading');
      return;
    }
    // Additional validation
    final phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isEmpty) {
      showToast(
        message: 'Please enter phone number',
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    final requiredLength = _countryPhoneLengths[_selectedCountry.countryCode] ?? 10;
    if (phoneNumber.length != requiredLength) {
      showToast(
        message: 'Please enter a valid $requiredLength-digit phone number',
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _animationController.repeat(reverse: true);
    });

    try {
      final response = await authRepository.sendOtp(
        phoneNumber,
        _appSignature ?? '',
      );
      print('OTP Response: $response');

      if (response != null && response['status'] == true) {
        _otpId = response['otpId'];
        final userId = response['userId'];

        setState(() {
          _isLoading = false;
          _animationController.stop();
        });

        if (mounted) {
          showToast(
            message: response['message'] ?? 'OTP Sent Successfully',
            backgroundColor: AppColors.greenColor,
          );
          Navigator.pushNamed(
            context,
            Routes.otpVerification,
            arguments: OTPVerificationScreen(
              phoneNumber: phoneNumber,
              route: Routes.otpVerification,
              otpId: _otpId,
            ),
          );

          await SecureStorageHelper.setString("countryCode", _selectedCountry.phoneCode);
          await SecureStorageHelper.setString("countryFlag", _selectedCountry.flagEmoji);
          await SecureStorageHelper.setString("otpId", _otpId!);

          if (userId != null) {
            await SecureStorageHelper.setString("userId", userId.toString());
            print('Stored userId: $userId');
          } else {
            print('No userId found in response');
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _animationController.stop();
        });

        if (mounted) {
          showToast(
            message: response?['message'] ?? 'Failed to send OTP',
            backgroundColor: AppColors.redColor,
          );
        }
      }
    } catch (e) {
      print('Send OTP Error: $e');
      setState(() {
        _isLoading = false;
        _animationController.stop();
      });
      if (mounted) {
        showToast(
          message: 'Error: $e',
          backgroundColor: AppColors.redColor,
        );
      }
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    _phoneNumberController.removeListener(_validateInputs);
    _userNameController.removeListener(_validateInputs);
    _phoneNumberController.dispose();
    _userNameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return CustomStyledPage(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 120.h),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeaderColor,
                      ),
                    ),
                    SizedBox(height: 11.h),
                    Text(
                      "Let's get you signed in",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textHeaderColor,
                      ),
                    ),
                    SizedBox(height: 50.h),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         "User Name",
                    //         style: TextStyle(
                    //           fontSize: 16.sp,
                    //           fontWeight: FontWeight.w500,
                    //           color: AppColors.textColor,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 8.h),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                    //   child: CustomTextfield(
                    //     controller: _userNameController,
                    //     hintText: 'Enter user name',
                    //   ),
                    // ),
                    // SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: Row(
                        children: [
                          Text(
                            "Phone Number",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: CustomPhoneField(
                        controller: _phoneNumberController,
                        onCountryChanged: _onCountryChanged,
                        hintText: 'Enter ${_countryPhoneLengths[_selectedCountry.countryCode] ?? 10} digit phone number',
                        countryPhoneLengths: _countryPhoneLengths, // Pass the map
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: CustomButton(
                        title: _isLoading ? 'Sending OTP...' : 'Continue to Receive OTP',
                        onTap: _isButtonEnabled && !_isLoading ? _sendOtp : null,
                        height: 40.h,
                        width: 358.w,
                        radius: 10.r,
                        color: _isButtonEnabled
                            ? AppColors.primaryColor
                            : AppColors.buttonDisableColor,
                        textColor: _isButtonEnabled
                            ? AppColors.whiteColor
                            : AppColors.textFieldColor,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 41.w,
                          child: Divider(
                            height: 1,
                            color: AppColors.optionalColor,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: Text(
                            "Or Continue with",
                            style: TextStyle(
                              color: AppColors.optionalColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 41.w,
                          child: Divider(
                            height: 1,
                            color: AppColors.optionalColor,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: CustomContainer(
                        title: 'Continue with Google',
                        onTap: () {},
                        icon: SvgPicture.asset(
                          AppAssets.googleIcon,
                          width: 20.w,
                          height: 20.h,
                        ),
                        iconLeft: true,
                        height: 40.h,
                        width: double.infinity,
                        radius: 10.r,
                        containerColor: AppColors.containerColor,
                        textColor: AppColors.textColor,
                        containerBorderColor: AppColors.borderColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: CustomContainer(
                        title: 'Continue with apple',
                        onTap: () {},
                        icon: SvgPicture.asset(
                          AppAssets.appleIcon,
                          width: 22.w,
                          height: 22.h,
                        ),
                        iconLeft: true,
                        height: 40.h,
                        width: double.infinity,
                        radius: 10.r,
                        containerColor: AppColors.containerColor,
                        textColor: AppColors.textColor,
                        containerBorderColor: AppColors.borderColor,
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}