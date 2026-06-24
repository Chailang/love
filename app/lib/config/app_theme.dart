import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 青藤之恋 — 浪漫玫瑰主题
class AppTheme {
  // ======== 主色调：浪漫玫瑰系 ========
  static const Color primary = Color(0xFFE11D48);       // 玫瑰红
  static const Color primaryLight = Color(0xFFFF5A7A);  // 浅玫瑰
  static const Color primaryDark = Color(0xFFAB0030);   // 深玫瑰

  // ======== 辅助色 ========
  static const Color accentGold = Color(0xFFD4AF37);    // 金色（SSR / VIP）
  static const Color accentPurple = Color(0xFF7C3AED);  // 紫色（八字/缘分）
  static const Color accentTeal = Color(0xFF06B6D4);    // 青色（同乡/地理）

  // ======== 灰度 ========
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color bgDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textHint = Color(0xFF9CA3AF);

  // ======== 稀有度颜色 ========
  static const Color rarityN = Color(0xFF9CA3AF);       // 灰色
  static const Color rarityR = Color(0xFF3B82F6);       // 蓝色
  static const Color raritySR = Color(0xFF7C3AED);      // 紫色
  static const Color raritySSR = Color(0xFFD4AF37);     // 金色

  static Color rarityColor(String rarity) => switch (rarity) {
        'SSR' => raritySSR,
        'SR' => raritySR,
        'R' => rarityR,
        _ => rarityN,
      };

  // ======== 间距 ========
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // ======== 圆角 ========
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // ======== 主题数据 ========
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primary,
        scaffoldBackgroundColor: bgLight,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: accentGold,
          surface: surfaceLight,
          error: primary,
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme().copyWith(
          headlineLarge: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          headlineMedium: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
          titleLarge: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: textPrimary),
          bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: textSecondary),
          bodySmall: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceLight,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
            textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
        ),
      );
}