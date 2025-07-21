import 'package:flutter/material.dart';

/// 광주광역시 서구 공식 색상 팔레트
/// 로고에서 추출한 브랜드 컬러를 기반으로 한 통일된 디자인 시스템
class SeoguColors {
  // Primary Brand Colors - 로고에서 추출한 메인 컬러들
  static const Color primary = Color(0xFF1E3A8A);        // 서구 로고 메인 블루
  static const Color secondary = Color(0xFF16A34A);      // 서구 로고 그린
  static const Color accent = Color(0xFF0891B2);         // 서구 로고 틸/시안
  static const Color highlight = Color(0xFFEF4444);      // 서구 로고 레드 액센트
  
  // Extended Brand Palette
  static const Color primaryLight = Color(0xFF3B82F6);   // 라이트 블루
  static const Color primaryDark = Color(0xFF1E40AF);    // 다크 블루
  static const Color secondaryLight = Color(0xFF22C55E); // 라이트 그린
  static const Color secondaryDark = Color(0xFF15803D);  // 다크 그린
  static const Color accentLight = Color(0xFF06B6D4);    // 라이트 틸
  static const Color accentDark = Color(0xFF0E7490);     // 다크 틸
  
  // UI Colors
  static const Color background = Color(0xFFF8FAFC);     // 배경색
  static const Color surface = Color(0xFFFFFFFF);        // 카드/서피스 색상
  static const Color textPrimary = Color(0xFF1E293B);    // 메인 텍스트
  static const Color textSecondary = Color(0xFF64748B);  // 서브 텍스트
  static const Color textLight = Color(0xFF94A3B8);      // 연한 텍스트
  static const Color border = Color(0xFFE2E8F0);         // 테두리
  static const Color divider = Color(0xFFE2E8F0);        // 구분선
  
  // Status Colors - 서구 브랜드 컬러와 조화
  static const Color success = Color(0xFF16A34A);        // 성공 (서구 그린 사용)
  static const Color warning = Color(0xFFF59E0B);        // 경고
  static const Color error = Color(0xFFEF4444);          // 에러 (서구 레드 사용)
  static const Color info = Color(0xFF0891B2);           // 정보 (서구 틸 사용)
  
  // Chart Colors - 서구 브랜드 컬러 기반
  static const Color chart1 = Color(0xFF1E3A8A);         // 메인 블루
  static const Color chart2 = Color(0xFF16A34A);         // 그린
  static const Color chart3 = Color(0xFF0891B2);         // 틸
  static const Color chart4 = Color(0xFFF59E0B);         // 오렌지
  static const Color chart5 = Color(0xFFEF4444);         // 레드
  static const Color chart6 = Color(0xFF8B5CF6);         // 퍼플
  
  // Merchant Area Colors - 지역별 구분 색상
  static const Color area1 = Color(0xFF1E3A8A);          // 동천동 등 - 메인 블루
  static const Color area2 = Color(0xFF16A34A);          // 유촌동 등 - 그린
  static const Color area3 = Color(0xFF0891B2);          // 청아동 등 - 틸
  static const Color area4 = Color(0xFFF59E0B);          // 화정동 등 - 오렌지
  static const Color area5 = Color(0xFFEF4444);          // 기타 지역 - 레드
}

/// 서구 브랜드 그라디언트
class SeoguGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [SeoguColors.primary, SeoguColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [SeoguColors.secondary, SeoguColors.secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [SeoguColors.accent, SeoguColors.accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 서구 테마 확장
extension SeoguTheme on ThemeData {
  static ThemeData get seoguTheme => ThemeData(
    primarySwatch: MaterialColor(0xFF1E3A8A, {
      50: Color(0xFFF0F4FF),
      100: Color(0xFFE0E7FF),
      200: Color(0xFFC7D2FE),
      300: Color(0xFFA5B4FC),
      400: Color(0xFF818CF8),
      500: Color(0xFF6366F1),
      600: Color(0xFF4F46E5),
      700: Color(0xFF4338CA),
      800: Color(0xFF3730A3),
      900: Color(0xFF1E3A8A),
    }),
    primaryColor: SeoguColors.primary,
    scaffoldBackgroundColor: SeoguColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: SeoguColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: SeoguColors.primary,
      secondary: SeoguColors.secondary,
      surface: SeoguColors.surface,
      background: SeoguColors.background,
      error: SeoguColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: SeoguColors.textPrimary,
      onBackground: SeoguColors.textPrimary,
      onError: Colors.white,
    ),
  );
}