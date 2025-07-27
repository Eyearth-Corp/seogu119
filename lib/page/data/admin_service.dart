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

  /// JSON을 읽기 쉽게 포맷팅하는 헬퍼 메서드
  static String _formatJson(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  /// 저장된 토큰을 로드하고 유효성을 검증합니다
  static Future<void> loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null) {
        
        // JWT 토큰 만료 여부 확인
        if (!JwtDecoder.isExpired(token)) {
          _authToken = token;
        } else {
          await prefs.remove(_tokenKey);
        }
      } else {
      }
    } catch (e) {
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
    } catch (e) {
    }
  }

  /// 저장된 토큰을 제거합니다
  static Future<void> _removeStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
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


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // API 응답 구조에 따라 토큰 추출
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];
          if (responseData['access_token'] != null) {
            _authToken = responseData['access_token'];
            await _saveToken(_authToken!);
            return true;
          } else if (responseData['token'] != null) {
            _authToken = responseData['token'];
            await _saveToken(_authToken!);
            return true;
          } else {
          }
        } else if (data['access_token'] != null) {
          // 기존 호환성을 위한 fallback
          _authToken = data['access_token'];
          await _saveToken(_authToken!);
          return true;
        } else if (data['token'] != null) {
          // 기존 호환성을 위한 fallback
          _authToken = data['token'];
          await _saveToken(_authToken!);
          return true;
        } else {
        }
      } else {
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
          } catch (e) {
          }
        }
      }
      return false;
    } catch (e) {
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
    }
    return null;
  }

  /// 특정 URL에서 데이터를 가져오는 범용 메서드
  static Future<dynamic> fetchFromURL(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 전체 동 목록 조회
  static Future<List<dynamic>?> getAllDistricts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/districts'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['districts'];
        }
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
    return null;
  }

  /// 특정 동의 상인회 목록 조회
  static Future<Map<String, dynamic>?> getMerchantsByDistrict(String dongName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/districts/$dongName/merchants'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Error fetching merchants for $dongName: $e');
    }
    return null;
  }

  /// 특정 상인회 정보 조회
  static Future<Map<String, dynamic>?> getMerchantDetail(int merchantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/merchants/$merchantId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Error fetching merchant $merchantId: $e');
    }
    return null;
  }

  /// 상인회 정보 수정
  static Future<bool> updateMerchant(int merchantId, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/merchants/$merchantId'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating merchant $merchantId: $e');
      return false;
    }
  }

  /// 전체 통계 요약 조회
  static Future<Map<String, dynamic>?> getStatisticsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/statistics/summary'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Error fetching statistics summary: $e');
    }
    return null;
  }

  /// 동별 공지사항 목록 조회
  static Future<Map<String, dynamic>?> getDistrictNotices(String dongName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/districts/$dongName/notices'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Error fetching notices for $dongName: $e');
    }
    return null;
  }

  /// 공지사항 생성
  static Future<bool> createNotice(String dongName, String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/districts/$dongName/notices'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error creating notice: $e');
      return false;
    }
  }

  /// 공지사항 수정
  static Future<bool> updateNotice(int noticeId, {String? title, String? content}) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;

      final response = await http.put(
        Uri.parse('$baseUrl/api/notices/$noticeId'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating notice $noticeId: $e');
      return false;
    }
  }

  /// 공지사항 삭제
  static Future<bool> deleteNotice(int noticeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notices/$noticeId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting notice $noticeId: $e');
      return false;
    }
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
      return false;
    }
  }

  /// 토큰 유효성 검증
  static Future<bool> validateToken() async {
    if (_authToken == null) return false;
    
    try {
      // JWT 만료 여부 먼저 확인
      if (JwtDecoder.isExpired(_authToken!)) {
        _authToken = null;
        await _removeStoredToken();
        return false;
      }
      
      // 서버에서 유효성 검증
      final admin = await getCurrentAdmin();
      if (admin != null) {
        return true;
      } else {
        _authToken = null;
        await _removeStoredToken();
        return false;
      }
    } catch (e) {
      _authToken = null;
      await _removeStoredToken();
      return false;
    }
  }

  /// 메인 대시보드 데이터 조회 (GET)
  static Future<Map<String, dynamic>?> getMainDashboard() async {
    try {
      final url = '$baseUrl/api/main-dashboard';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
        return data;
      }
    } catch (e) {
      print('Error fetching main dashboard: $e');
    }
    return null;
  }

  /// 메인 대시보드 데이터 생성/업데이트 (POST/PUT)
  static Future<bool> createOrUpdateMainDashboard(Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl/api/main-dashboard';
      
      // API 요구사항에 맞는 형식으로 데이터 구조화
      final requestBody = {
        'data_json': _formatDashboardData(data),
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            print('Error response: $errorData');
          } catch (e) {
            print('Error parsing response: $e');
          }
        }
      }
      return false;
    } catch (e) {
      print('Error updating main dashboard: $e');
      return false;
    }
  }

  /// 대시보드 데이터를 API 요구사항에 맞는 형식으로 변환
  static Map<String, dynamic> _formatDashboardData(Map<String, dynamic> data) {
    // topMetrics 데이터의 모든 value를 문자열로 변환
    List<Map<String, dynamic>> topMetrics = [];
    if (data['topMetrics'] != null && data['topMetrics'] is List) {
      topMetrics = (data['topMetrics'] as List).map((metric) {
        return {
          'title': metric['title']?.toString() ?? '',
          'value': metric['value']?.toString() ?? '0',
          'unit': metric['unit']?.toString() ?? '',
        };
      }).toList();
    } else {
      topMetrics = [
        {'title': '🏪 전체 가맹점', 'value': (data['total_merchants'] ?? 11426).toString(), 'unit': '개'},
        {'title': '✨ 이번주 신규', 'value': (data['new_merchants_this_week'] ?? 47).toString(), 'unit': '개'},
        {'title': '📊 가맹률', 'value': (data['membership_rate'] ?? 85.2).toString(), 'unit': '%'},
      ];
    }
    
    return {
      'topMetrics': topMetrics,
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




  /// 다양한 타입을 List로 안전하게 변환
  static List<dynamic> _convertToList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is Map) {
      // Map을 List로 변환 (values 또는 entries 사용)
      return value.values.toList();
    }
    return [value]; // 단일 값을 리스트로 감싸기
  }







  /// 값을 int로 안전하게 변환
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }


  /// 에러 메시지 추출
  static String getErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['detail'] ?? error['message'] ?? '알 수 없는 오류가 발생했습니다.';
    }
    return error.toString();
  }
}