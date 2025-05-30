import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const purpleIndicator = Color(0xFFA16985);
  static const purpleIndicatorLight = Color.fromRGBO(161, 105, 133, 0.16);
  static const gradientStart = Color(0xFFF1CAD1);
  static const gradientMiddle = Color(0xFFF2CBD3); // Interpolated middle color
  static const gradientEnd = Color(0xFFF4CDD6);
  static const textPrimary = Color(0xFF6A515E);
  static const white = Colors.white;
  static const solidPinkBackground = Color(0xFFF1CBD1);
}

class AppTextStyles {
  static final headlineStyle = GoogleFonts.merriweather(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final subtitleStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static final buttonTextStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

class AppSizes {
  static const double pagePadding = 40.0;
  static const double borderRadius = 60.0;
  static const double indicatorSize = 6.64;
  static const double indicatorSpacing = 12.0;
}
