import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = kDebugMode 
      ? 'http://localhost:8000' 
      : 'https://api.seogu119.eyearth.net';
  
  static String? _authToken;
  static bool get isLoggedIn => _authToken != null;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// 관리자 로그인
  static Future<bool> login(String username, String password) async {
    try {
      final url = '$baseUrl/admin/login';
      print('🔗 로그인 요청 URL: $url');
      print('📤 요청 데이터: username=$username, password=${password.replaceAll(RegExp(r'.'), '*')}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📡 응답 상태코드: ${response.statusCode}');
      print('📡 응답 헤더: ${response.headers}');
      print('📡 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ JSON 파싱 성공: $data');
        
        // FastAPI는 직접 토큰을 반환 (BaseResponse 형식이 아님)
        if (data['access_token'] != null) {
          _authToken = data['access_token'];
          print('🎉 로그인 성공! 토큰 저장됨: ${_authToken?.substring(0, 20)}...');
          return true;
        } else {
          print('❌ 토큰이 응답에 없음: $data');
        }
      } else {
        print('❌ HTTP 오류: ${response.statusCode} - ${response.reasonPhrase}');
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            print('❌ 서버 에러 메시지: $errorData');
          } catch (e) {
            print('❌ 원시 에러 응답: ${response.body}');
          }
        }
      }
      return false;
    } catch (e) {
      print('💥 로그인 예외 발생: $e');
      print('💥 스택 트레이스: ${StackTrace.current}');
      return false;
    }
  }

  /// 로그아웃
  static Future<void> logout() async {
    try {
      if (_authToken != null) {
        await http.post(
          Uri.parse('$baseUrl/admin/logout'),
          headers: _headers,
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _authToken = null;
    }
  }

  /// 관리자 정보 조회
  static Future<Map<String, dynamic>?> getCurrentAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Get admin error: $e');
    }
    return null;
  }

  /// 가맹점 목록 조회 (관리자용)
  static Future<Map<String, dynamic>?> getMerchants({
    required String date,
    String? dongName,
    String? category,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        if (dongName != null) 'dong_name': dongName,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/merchant-details/$date')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Get merchants error: $e');
    }
    return null;
  }

  /// 가맹점 생성
  static Future<bool> createMerchant(String date, Map<String, dynamic> merchantData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/merchant-details/$date'),
        headers: _headers,
        body: jsonEncode(merchantData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Create merchant error: $e');
      return false;
    }
  }

  /// 가맹점 수정
  static Future<bool> updateMerchant(String date, int merchantId, Map<String, dynamic> merchantData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/merchant-details/$date/$merchantId'),
        headers: _headers,
        body: jsonEncode(merchantData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update merchant error: $e');
      return false;
    }
  }

  /// 가맹점 삭제
  static Future<bool> deleteMerchant(String date, int merchantId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/merchant-details/$date/$merchantId'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete merchant error: $e');
      return false;
    }
  }

  /// 통계 데이터 조회
  static Future<Map<String, dynamic>?> getStatistics(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/statistics/$date'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Get statistics error: $e');
    }
    return null;
  }

  /// 동별 가맹점 현황 조회
  static Future<Map<String, dynamic>?> getDongMerchantStatus(String date, String dongName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dong-status/$date/$dongName'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Get dong status error: $e');
    }
    return null;
  }

  /// 데이터 수집일 목록 조회
  static Future<List<Map<String, dynamic>>> getAvailableDates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dates'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('Get dates error: $e');
    }
    return [];
  }

  /// 비밀번호 변경
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/change-password'),
        headers: _headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}