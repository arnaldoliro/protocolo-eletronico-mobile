import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color primary;
  final Color inputFill;
  final Color inputBorder;
  final Color inputText;
  final Color textMuted;
  final Color surface;

  const AppColors._({
    required this.background,
    required this.primary,
    required this.inputFill,
    required this.inputBorder,
    required this.inputText,
    required this.textMuted,
    required this.surface,
  });

  static const light = AppColors._(
    background: Color(0xFFF5F6FF),
    primary: Color(0xFF1565C0),
    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFFdfe1eb),
    inputText: Color(0xFF1A1A1A),
    textMuted: Color(0xFF6B7280),
    surface: Color(0xFFFFFFFF),
  );

  static const dark = AppColors._(
    background: Color(0xFF030733),
    primary: Color(0xFF1565C0),
    inputFill: Color(0xFF0D1757),
    inputBorder: Color(0xFF0D1757),
    inputText: Color(0xFFFFFFFF),
    textMuted: Color(0xFF8899AA),
    surface: Color(0xFF0D1757),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }
}

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    colorScheme: ColorScheme.light(
      surface: AppColors.light.background,
      primary: AppColors.light.primary,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.background,
    colorScheme: ColorScheme.dark(
      surface: AppColors.dark.background,
      primary: AppColors.dark.primary,
    ),
  );
}
