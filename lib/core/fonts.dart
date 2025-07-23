import 'package:flutter/material.dart';

/// 서구 골목경제 119 앱의 폰트 설정
/// 한글 문자 지원을 위한 폰트 폴백 체인 관리
class SeoguFonts {
  // 기본 폰트 패밀리
  static const String primaryFont = 'NotoSans';
  
  // 한글 및 다국어 지원을 위한 폰트 폴백 체인
  static const List<String> fontFallbacks = [
    'Noto Sans KR',        // Google Fonts 한글 폰트
    'Malgun Gothic',       // Windows 한글 폰트
    'Apple SD Gothic Neo', // macOS/iOS 한글 폰트
    'Helvetica Neue',      // macOS 라틴 폰트
    'Segoe UI',            // Windows 라틴 폰트
    'Roboto',              // Android 라틴 폰트
    'Arial',               // 범용 라틴 폰트
    'sans-serif',          // 시스템 기본 폰트
  ];
  
  // 텍스트 스타일 헬퍼 메서드들
  static TextStyle heading({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: fontFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
  
  static TextStyle body({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: fontFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
  
  static TextStyle caption({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: fontFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
  
  // 한글 특화 스타일
  static TextStyle korean({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: const [
        'Noto Sans KR',
        'Malgun Gothic',
        'Apple SD Gothic Neo',
        ...fontFallbacks,
      ],
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

/// TextStyle Extension for easy font fallback usage
extension TextStyleExtension on TextStyle {
  TextStyle withFontFallback() {
    return copyWith(
      fontFamily: SeoguFonts.primaryFont,
      fontFamilyFallback: SeoguFonts.fontFallbacks,
    );
  }
}