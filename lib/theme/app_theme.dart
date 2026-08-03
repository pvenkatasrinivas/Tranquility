import 'package:flutter/material.dart';

class AppColors {
  // Background layers
  static const Color background     = Color(0xFF0B1120);
  static const Color surface        = Color(0xFF111827);
  static const Color surfaceHigh    = Color(0xFF141F35);
  static const Color card           = Color(0xFF1A2840);

  // Text
  static const Color textPrimary    = Color(0xFFD0E4F8);
  static const Color textSecondary  = Color(0xFF6B84A8);
  static const Color textMuted      = Color(0xFF4A6280);

  // Accent / brand
  static const Color blue           = Color(0xFF4A7CC7);
  static const Color blueLight      = Color(0xFF6B9FDB);
  static const Color blueMuted      = Color(0xFF2D4E7A);

  // Semantic
  static const Color green          = Color(0xFF4CAF83);
  static const Color purple         = Color(0xFFA888E8);
  static const Color gold           = Color(0xFFE8A843);
  static const Color danger         = Color(0xFFE85858);

  // Border
  static const Color border         = Color(0xFF1E304F);
  static const Color borderFaint    = Color(0x26789BCC);
}

class AppTextStyles {
  static const String _font = 'Roboto';

  static const TextStyle h1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: 0.2,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textMuted, letterSpacing: 0.5,
  );
  static const TextStyle label = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600,
    color: AppColors.textMuted, letterSpacing: 1.5,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.blue,
      secondary: AppColors.blueLight,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTextStyles.h3,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0D1828),
      selectedItemColor: AppColors.blueLight,
      unselectedItemColor: AppColors.blueMuted,
      selectedLabelStyle: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
      showUnselectedLabels: true,
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.blue;
        return AppColors.border;
      }),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.blue,
      inactiveTrackColor: Color(0xFF1E304F),
      thumbColor: AppColors.blueLight,
      overlayColor: Color(0x264A7CC7),
    ),
  );
}
