import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF7B2ED3);
  static const Color textColor = Color(0xFF252525);
  static const Color textHeaderColor = Color(0xFF3E1F67);
  static const Color textFieldInputColor = Color(0xFF5F5F5F);
  static const Color appBarCenterColor = Color(0xFF8112FF);
  static const Color bottomLeftColor = Color(0xFF7B2ED3);
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Color(0xFFE21D1D);
  static const Color borderColor = Color(0xFFDADADA);
  static const Color containerColor = Color(0xFFFBFBFB);
  static const Color textFieldColor = Color(0xFF758195);
  static const Color whiteColor = Colors.white;
  static const Color optionalColor = Color(0xFF7B7A7A);
  static const Color buttonDisableColor = Color(0xFFDDDDDD);
  static const Color textLightColor = Color(0xFF758195);
  static const Color searchBorderColor = Color(0xFF4B4B4B);
  static const Color uploadColor = Color(0xFFEFE8FF);
  static const Color countColor = Color(0xFF4B1F85);
  static const Color statsColor = Color(0xFF5A23DB);
  static const Color boxShadowColor = Color(0xFF7D7D7D);
  static const Color businessNameColor = Color(0xFFC36D22);
  static const Color dateFormatColor = Color(0xFF696969);
  static const Color followersDetailGradientColor1 = Color(0xFF7FD7FD);
  static const Color followersDetailGradientColor2 = Color(0xFF8AECDF);
  static const Color redColor = Colors.red;
  static const Color greenColor = Colors.green;




  static Widget blurredBackground({double blur = 200.0, Widget? child}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}