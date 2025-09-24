import 'package:flutter/cupertino.dart';

bool isTablet(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth >= 600;
}