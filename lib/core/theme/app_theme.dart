import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF070708);
  static const inputFill = Color(0xFFF5F7F6);
  static const inputText = Color(0xFF1A1A1A);
  static const primary = Color(0xFFF5F7F6);
  static const textMuted = Color(0xFFAAAAAA);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.dark(
      surface: AppColors.background,
      primary: AppColors.primary,
    ),
  );
}
