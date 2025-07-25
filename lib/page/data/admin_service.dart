import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AdminService {
  static const String baseUrl = kDebugMode 
      ? 'http://localhost:8000' 
      : 'https://seogu119-api.eyearth.net';
  
  static const String _tokenKey = 'admin_auth_token';
  static String? _authToken;
  static bool get isLoggedIn => _authToken != null;

  /// 저장된 토큰을 로드하고 유효성을 검증합니다
  static Future<void> loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null) {
        print('📱 저장된 토큰 발견: ${token.substring(0, 20)}...');
        
        // JWT 토큰 만료 여부 확인
        if (!JwtDecoder.isExpired(token)) {
          _authToken = token;
          print('✅ 토큰이 유효합니다. 자동 로그인 성공');
        } else {
          print('⏰ 토큰이 만료되었습니다. 토큰 제거');
          await prefs.remove(_tokenKey);
        }
      } else {
        print('📱 저장된 토큰이 없습니다');
      }
    } catch (e) {
      print('💥 토큰 로드 중 오류: $e');
      // JWT 디코딩 실패 시 토큰 제거
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    }
  }

  /// 토큰을 저장합니다
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('💾 토큰 저장 완료');
    } catch (e) {
      print('💥 토큰 저장 중 오류: $e');
    }
  }

  /// 저장된 토큰을 제거합니다
  static Future<void> _removeStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('🗑️ 저장된 토큰 제거 완료');
    } catch (e) {
      print('💥 토큰 제거 중 오류: $e');
    }
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// 관리자 로그인
  static Future<bool> login(String username, String password) async {
    try {
      final url = '$baseUrl/api/admin/login';
      print('🔗 로그인 요청 URL: $url');
      print('📤 요청 데이터: username=$username, password=${password.replaceAll(RegExp(r'.'), '*')}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
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
        
        // API 응답 구조에 따라 토큰 추출
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];
          if (responseData['access_token'] != null) {
            _authToken = responseData['access_token'];
            await _saveToken(_authToken!);
            print('🎉 로그인 성공! 토큰 저장됨: ${_authToken?.substring(0, 20)}...');
            return true;
          } else if (responseData['token'] != null) {
            _authToken = responseData['token'];
            await _saveToken(_authToken!);
            print('🎉 로그인 성공! 토큰 저장됨: ${_authToken?.substring(0, 20)}...');
            return true;
          } else {
            print('❌ 토큰이 data 객체에 없음: $responseData');
          }
        } else if (data['access_token'] != null) {
          // 기존 호환성을 위한 fallback
          _authToken = data['access_token'];
          await _saveToken(_authToken!);
          print('🎉 로그인 성공! 토큰 저장됨: ${_authToken?.substring(0, 20)}...');
          return true;
        } else if (data['token'] != null) {
          // 기존 호환성을 위한 fallback
          _authToken = data['token'];
          await _saveToken(_authToken!);
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
          Uri.parse('$baseUrl/api/admin/logout'),
          headers: _headers,
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _authToken = null;
      await _removeStoredToken();
    }
  }

  /// 관리자 정보 조회
  static Future<Map<String, dynamic>?> getCurrentAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
        return data; // API 응답 구조가 다를 수 있으므로 전체 데이터 반환
      }
    } catch (e) {
      print('Get admin error: $e');
    }
    return null;
  }

  /// 특정 URL에서 데이터를 가져오는 범용 메서드
  static Future<dynamic> fetchFromURL(String url) async {
    try {
      print('🌐 API 호출: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 API 응답 상태: ${response.statusCode}');
      print('📡 API 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ HTTP 오류: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('💥 API 호출 예외: $e');
      rethrow;
    }
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
        Uri.parse('$baseUrl/api/admin/change-password'),
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

  /// 토큰 유효성 검증
  static Future<bool> validateToken() async {
    if (_authToken == null) return false;
    
    try {
      // JWT 만료 여부 먼저 확인
      if (JwtDecoder.isExpired(_authToken!)) {
        print('⏰ JWT 토큰이 만료되었습니다');
        _authToken = null;
        await _removeStoredToken();
        return false;
      }
      
      // 서버에서 유효성 검증
      final admin = await getCurrentAdmin();
      if (admin != null) {
        return true;
      } else {
        print('❌ 서버에서 토큰 유효성 검증 실패');
        _authToken = null;
        await _removeStoredToken();
        return false;
      }
    } catch (e) {
      print('Token validation error: $e');
      _authToken = null;
      await _removeStoredToken();
      return false;
    }
  }

  /// 메인 대시보드 데이터 조회 (GET)
  static Future<Map<String, dynamic>?> getMainDashboard() async {
    try {
      final url = 'https://seogu119-api.eyearth.net/api/main-dashboard';
      
      print('🔗 메인 대시보드 요청 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 응답 상태코드: ${response.statusCode}');
      print('📡 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ 메인 대시보드 데이터 수신 성공');
        return data;
      }
    } catch (e) {
      print('💥 메인 대시보드 조회 예외 발생: $e');
    }
    return null;
  }

  /// 특정 날짜의 메인 대시보드 데이터 조회 (GET)
  static Future<Map<String, dynamic>?> getMainDashboardByDate(String date) async {
    try {
      final url = 'https://seogu119-api.eyearth.net/api/main-dashboard/$date';
      
      print('🔗 특정 날짜 메인 대시보드 요청 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 응답 상태코드: ${response.statusCode}');
      print('📡 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ $date 메인 대시보드 데이터 수신 성공');
        return data;
      }
    } catch (e) {
      print('💥 $date 메인 대시보드 조회 예외 발생: $e');
    }
    return null;
  }

  /// 메인 대시보드 데이터 생성 (POST)
  static Future<bool> createMainDashboard(String date, Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl/api/main-dashboard';
      print('🔗 메인 대시보드 생성 요청 URL: $url');
      print('📤 요청 데이터: $data');
      
      // API 요구사항에 맞는 형식으로 데이터 구조화
      final requestBody = {
        'data_date': date,
        'data_json': _formatDashboardData(data),
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      print('📡 응답 상태코드: ${response.statusCode}');
      print('📡 응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 메인 대시보드 생성 성공');
        return true;
      } else {
        print('❌ 메인 대시보드 생성 실패: ${response.statusCode}');
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
      print('💥 메인 대시보드 생성 예외 발생: $e');
      return false;
    }
  }

  /// 메인 대시보드 데이터 업데이트 (PUT)
  static Future<bool> updateMainDashboard(String date, Map<String, dynamic> data) async {
    try {
      final url = 'https://seogu119-api.eyearth.net/api/main-dashboard/$date';
      print('🔗 메인 대시보드 업데이트 요청 URL: $url');
      print('📤 요청 데이터: $data');
      
      // API 요구사항에 맞는 형식으로 데이터 구조화
      final formattedData = _formatDashboardData(data);
      final requestBody = {
        'data_date': date,
        'data_json': formattedData,
      };
      
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      print('📡 응답 상태코드: ${response.statusCode}');
      print('📡 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ 메인 대시보드 업데이트 성공');
        return true;
      } else {
        print('❌ 메인 대시보드 업데이트 실패: ${response.statusCode}');
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
      print('💥 메인 대시보드 업데이트 예외 발생: $e');
      return false;
    }
  }

  /// 2025-07-23 일자 임시 메인 대시보드 데이터 생성
  static Future<bool> create20250723DashboardData() async {
    final sampleData = {
      'total_merchants': 11426,
      'new_merchants_this_week': 47,
      'membership_rate': 85.2,
      'onnuri_trend_data': [
        {'period': 'Week 1', 'percentage': 75.0},
        {'period': 'Week 2', 'percentage': 78.0},
        {'period': 'Week 3', 'percentage': 82.0},
        {'period': 'Week 4', 'percentage': 80.0},
        {'period': 'Week 5', 'percentage': 85.0},
        {'period': 'Week 6', 'percentage': 87.0},
      ],
      'dong_membership_status': [
        {'dong_name': '동천동', 'percentage': 92.1},
        {'dong_name': '유촌동', 'percentage': 88.3},
        {'dong_name': '치평동', 'percentage': 85.7},
        {'dong_name': '화정2동', 'percentage': 82.4},
        {'dong_name': '화정4동', 'percentage': 81.4},
      ],
      'complaint_keywords': [
        {'rank': 1, 'keyword': '주차 문제', 'count': 34},
        {'rank': 2, 'keyword': '소음 방해', 'count': 28},
        {'rank': 3, 'keyword': '청소 문제', 'count': 19},
      ],
      'complaint_performance': {
        'processed': 187,
        'process_rate': 94.2,
      },
      'complaint_cases': [
        {
          'title': '동천동 주차장 확장',
          'status': '해결',
          'detail': '주차 공간 부족으로 인한 민원이 지속적으로 제기되어, 기존 주차장을 확장하고 새로운 주차구역을 확보했습니다.',
        },
        {
          'title': '유촌동 소음방해 개선',
          'status': '진행중',
          'detail': '야간 시간대 상가 운영으로 인한 소음 문제를 해결하기 위해 방음시설 설치 및 운영시간 조정을 진행 중입니다.',
        },
        {
          'title': '청아동 청소 개선',
          'status': '해결',
          'detail': '쓰레기 무단투기 및 청소 상태 불량 문제를 해결하기 위해 청소 주기를 단축하고 CCTV를 설치했습니다.',
        },
      ],
      'other_organization_trends': [
        {
          'title': '부산 동구 골목상권 활성화 사업',
          'detail': '부산 동구에서 추진 중인 골목상권 활성화 사업으로, 상인회 조직 강화와 디지털 마케팅 지원을 통해 매출 증대를 도모하고 있습니다.',
        },
        {
          'title': '대구 중구 전통시장 디지털화',
          'detail': '대구 중구 전통시장의 디지털 전환 사업으로, QR코드 결제 시스템 도입과 온라인 쇼핑몰 구축을 통해 젊은 고객층 유입을 늘리고 있습니다.',
        },
      ],
      'weekly_achievements': {
        'new_merchants': 47,
        'resolved_complaints': 23,
        'support_budget': 230000000, // 2.3억 원
      },
    };

    return await createMainDashboard('2025-07-23', sampleData);
  }

  /// 대시보드 데이터를 API 요구사항에 맞는 형식으로 변환
  static Map<String, dynamic> _formatDashboardData(Map<String, dynamic> data) {
    return {
      'topMetrics': data['topMetrics'] ?? [
        {'title': '🏪 전체 가맹점', 'value': data['total_merchants']?.toString() ?? '11426', 'unit': '개'},
        {'title': '✨ 이번주 신규', 'value': data['new_merchants_this_week']?.toString() ?? '47', 'unit': '개'},
        {'title': '📊 가맹률', 'value': data['membership_rate']?.toString() ?? '85.2', 'unit': '%'},
      ],
      'trendChart': data['trendChart'] ?? {
        'title': '📈 온누리 가맹점 추이',
        'data': data['onnuri_trend_data'] ?? [
          {'x': 0, 'y': 75},
          {'x': 1, 'y': 78},
          {'x': 2, 'y': 82},
          {'x': 3, 'y': 80},
          {'x': 4, 'y': 85},
          {'x': 5, 'y': 87}
        ]
      },
      'dongMembership': data['dongMembership'] ?? {
        'title': '🗺️ 동별 가맹률 현황',
        'data': data['dong_membership_status'] ?? [
          {'name': '동천동', 'percentage': 92.1},
          {'name': '유촌동', 'percentage': 88.3},
          {'name': '치평동', 'percentage': 85.7}
        ]
      },
      'complaintKeywords': data['complaintKeywords'] ?? {
        'title': '🔥 민원 TOP 3 키워드',
        'data': data['complaint_keywords'] ?? [
          {'rank': '1', 'keyword': '주차 문제', 'count': 34},
          {'rank': '2', 'keyword': '소음 방해', 'count': 28},
          {'rank': '3', 'keyword': '청소 문제', 'count': 19}
        ]
      },
      'complaintCases': data['complaintCases'] ?? {
        'title': '✅ 민원 해결 사례',
        'data': data['complaint_cases'] ?? [
          {
            'title': '동천동 주차장 확장',
            'status': '해결',
            'detail': '주차 공간 부족으로 인한 민원이 지속적으로 제기되어, 기존 주차장을 확장하고 새로운 주차구역을 확보했습니다.'
          }
        ]
      },
      'complaintPerformance': data['complaintPerformance'] ?? {
        'title': '📋 민원처리 실적',
        'processed': data['complaint_performance']?['processed']?.toString() ?? '187건',
        'rate': data['complaint_performance']?['process_rate']?.toString() ?? '94.2%'
      },
      'organizationTrends': data['organizationTrends'] ?? {
        'title': '🌐 타 기관·지자체 주요 동향',
        'data': data['other_organization_trends'] ?? [
          {
            'title': '부산 동구 골목상권 활성화 사업',
            'detail': '부산 동구에서 추진 중인 골목상권 활성화 사업으로, 상인회 조직 강화와 디지털 마케팅 지원을 통해 매출 증대를 도모하고 있습니다.'
          }
        ]
      },
      'weeklyAchievements': data['weeklyAchievements'] ?? [
        {'title': '신규 가맹점', 'value': data['weekly_achievements']?['new_merchants']?.toString() ?? '47개'},
        {'title': '민원 해결', 'value': data['weekly_achievements']?['resolved_complaints']?.toString() ?? '23건'},
        {'title': '지원 예산', 'value': _formatBudget(data['weekly_achievements']?['support_budget']) ?? '2.3억'}
      ]
    };
  }

  /// 예산 숫자를 한국어 단위로 변환 (예: 230000000 -> "2.3억")
  static String _formatBudget(dynamic budget) {
    if (budget == null) return '2.3억';
    final num = budget is String ? double.tryParse(budget) ?? 0 : budget;
    if (num >= 100000000) {
      return '${(num / 100000000).toStringAsFixed(1)}억';
    } else if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}만원';
    }
    return num.toString();
  }

  /// 에러 메시지 추출
  static String getErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['detail'] ?? error['message'] ?? '알 수 없는 오류가 발생했습니다.';
    }
    return error.toString();
  }
}