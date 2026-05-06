import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF4378DB);
  static const Color background = Color(0xFFEDF3FF);
  static const Color white = Colors.white;
  static const Color textMain = Color(0xFF2D2D2D);
}

// Глобальная тема для MaterialApp
ThemeData appTheme = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme(),
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primaryBlue,
);