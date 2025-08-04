import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../page/data/dong_dashboard_data.dart';

class DongApiService {
  static const String _baseUrl = kDebugMode 
      ? 'http://seogu119-api.eyearth.net/api'
      : 'http://seogu119-api.eyearth.net/api';

  /// 모든 동 목록을 조회합니다.
  static Future<Map<String, dynamic>> getAllDistricts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/districts'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? '동 목록 조회에 실패했습니다.');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('getAllDistricts error: $e');
      throw Exception('동 목록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 동의 상인회 목록을 조회합니다.
  static Future<DongDashboardData> getDongDashboard(String dongName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/districts/${Uri.encodeComponent(dongName)}/merchants'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return DongDashboardData.fromMap(data['data']);
        } else {
          throw Exception(data['message'] ?? '동별 대시보드 조회에 실패했습니다.');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('getDongDashboard error: $e');
      throw Exception('동별 대시보드를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 동의 공지사항을 조회합니다.
  static Future<List<NoticeInfo>> getDongNotices(String dongName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/districts/${Uri.encodeComponent(dongName)}/notices'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> noticesData = data['data']['notices'] ?? [];
          return noticesData.map((notice) => NoticeInfo.fromMap(notice)).toList();
        } else {
          throw Exception(data['message'] ?? '공지사항 조회에 실패했습니다.');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('getDongNotices error: $e');
      throw Exception('공지사항을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 전체 통계 요약 정보를 조회합니다.
  static Future<Map<String, dynamic>> getStatisticsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/statistics/summary'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? '통계 조회에 실패했습니다.');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('getStatisticsSummary error: $e');
      throw Exception('통계를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 상인회 상세 정보를 조회합니다.
  static Future<MerchantInfo> getMerchantDetail(int merchantId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/merchants/$merchantId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return MerchantInfo.fromMap(data['data']);
        } else {
          throw Exception(data['message'] ?? '상인회 정보 조회에 실패했습니다.');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('getMerchantDetail error: $e');
      throw Exception('상인회 정보를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 동별 대시보드 데이터를 가공하여 메트릭 정보를 생성합니다.
  static List<DongMetric> _generateDongMetrics(DongInfo dongInfo) {
    return [
      DongMetric(
        title: '🏪 총 상인회',
        value: dongInfo.merchantCount.toString(),
        unit: '개',
      ),
      DongMetric(
        title: '🏬 전체 점포',
        value: dongInfo.totalStores.toString(),
        unit: '개',
      ),
      DongMetric(
        title: '✨ 가맹점포',
        value: dongInfo.totalMemberStores.toString(),
        unit: '개',
      ),
      DongMetric(
        title: '📊 가맹률',
        value: dongInfo.overallMembershipRate.toStringAsFixed(1),
        unit: '%',
      ),
    ];
  }

  /// 동별 통계 정보를 생성합니다.
  static DongStatistics _generateDongStatistics(DongInfo dongInfo, List<MerchantInfo> merchants) {
    // 업종별 분류 (예시 데이터 - 실제로는 API에서 제공되어야 함)
    final businessTypes = [
      BusinessTypeInfo(type: '음식점', count: (merchants.length * 0.4).round(), percentage: 40.0),
      BusinessTypeInfo(type: '소매점', count: (merchants.length * 0.3).round(), percentage: 30.0),
      BusinessTypeInfo(type: '서비스업', count: (merchants.length * 0.2).round(), percentage: 20.0),
      BusinessTypeInfo(type: '기타', count: (merchants.length * 0.1).round(), percentage: 10.0),
    ];

    return DongStatistics(
      totalMerchants: dongInfo.merchantCount,
      totalStores: dongInfo.totalStores,
      totalMemberStores: dongInfo.totalMemberStores,
      averageMembershipRate: dongInfo.overallMembershipRate,
      businessTypes: businessTypes,
    );
  }

  /// 동별 대시보드 데이터를 완전히 구성하여 반환합니다.
  static Future<DongDashboardData> getCompleteDongDashboard(String dongName) async {
    try {
      // 기본 동 정보와 상인회 목록 조회
      final dongData = await getDongDashboard(dongName);
      
      // 공지사항 조회
      final notices = await getDongNotices(dongName);
      
      // 메트릭 정보 생성
      final metrics = _generateDongMetrics(dongData.dongInfo);
      
      // 통계 정보 생성
      final statistics = _generateDongStatistics(dongData.dongInfo, dongData.merchants);

      return DongDashboardData(
        dongInfo: dongData.dongInfo,
        dongMetrics: metrics,
        merchants: dongData.merchants,
        notices: notices,
        statistics: statistics,
      );
    } catch (e) {
      print('getCompleteDongDashboard error: $e');
      throw Exception('동별 대시보드 데이터를 구성하는 중 오류가 발생했습니다: $e');
    }
  }
}