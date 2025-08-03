import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../page/data/main_data_parser.dart';

class ApiService {
  static const String _prodBaseUrl = 'https://seogu119-api.eyearth.net/api';
  static const String _devBaseUrl = 'http://localhost:8000';
  
  static String get baseUrl => kDebugMode ? '$_devBaseUrl/api' : _prodBaseUrl;
  
  static Future<MainDashboardResponse> getMainDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/main-dashboard'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // API 응답이 BaseResponse 형식인지 확인
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return MainDashboardResponse.fromJson(jsonData['data']);
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load main dashboard: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Network error: $e');
    }
  }


  // 새로운 Districts API 메소드들
  static Future<List<District>> getAllDistricts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/districts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final districts = jsonData['data']['districts'] as List;
          return districts.map((d) => District.fromJson(d)).toList();
        }
      }
      throw Exception('Failed to load districts');
    } catch (e) {
      print('Districts API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<DistrictMerchants> getMerchantsByDistrict(String dongName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/districts/$dongName/merchants'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return DistrictMerchants.fromJson(jsonData['data']);
        }
      }
      throw Exception('Failed to load merchants for $dongName');
    } catch (e) {
      print('Merchants API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<Merchant> getMerchantDetail(int merchantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants/$merchantId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Merchant.fromJson(jsonData['data']);
        }
      }
      throw Exception('Failed to load merchant $merchantId');
    } catch (e) {
      print('Merchant Detail API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<StatisticsSummary> getStatisticsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return StatisticsSummary.fromJson(jsonData['data']);
        }
      }
      throw Exception('Failed to load statistics summary');
    } catch (e) {
      print('Statistics API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Dashboard API methods
  static Future<List<Type1Data>> getDashBoardType1(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardType1?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          return items.map((item) => Type1Data.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load DashBoardType1');
    } catch (e) {
      print('DashBoardType1 API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Type2Data>> getDashBoardType2(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardType2?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          return items.map((item) => Type2Data.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load DashBoardType2');
    } catch (e) {
      print('DashBoardType2 API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Type3ItemData>> getDashBoardType3(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardType3?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          return items.map((item) => Type3ItemData.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load DashBoardType3');
    } catch (e) {
      print('DashBoardType3 API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<Type4Data> getDashBoardType4(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardType4?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          if (items.isNotEmpty) {
            return Type4Data.fromJson(items.first);
          }
        }
      }
      throw Exception('Failed to load DashBoardType4');
    } catch (e) {
      print('DashBoardType4 API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Bbs1ItemData>> getDashBoardBbs1(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardBbs1?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          return items.map((item) => Bbs1ItemData.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load DashBoardBbs1');
    } catch (e) {
      print('DashBoardBbs1 API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Bbs2ItemData>> getDashBoardBbs2(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardBbs2?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          return items.map((item) => Bbs2ItemData.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load DashBoardBbs2');
    } catch (e) {
      print('DashBoardBbs2 API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<ChartDataPoint>> getDashBoardChart(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardChart?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          return items.map((item) => ChartDataPoint.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load DashBoardChart');
    } catch (e) {
      print('DashBoardChart API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<PercentItemData>> getDashBoardPercent(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DashBoardPercent?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> items = jsonData['data'];
          return items.map((item) => PercentItemData.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load DashBoardPercent');
    } catch (e) {
      print('DashBoardPercent API Error: $e');
      throw Exception('Network error: $e');
    }
  }
}

class MainDashboardResponse {
  final MainDashboardData data;

  MainDashboardResponse({
    required this.data,
  });

  factory MainDashboardResponse.fromJson(Map<String, dynamic> json) {
    return MainDashboardResponse(
      data: MainDashboardData.fromJson(json),
    );
  }
}

class MainDashboardData {
  List<TopMetric> topMetrics;
  String newMerchants;
  String resolvedComplaints;
  String supportBudget;
  List<ComplaintKeyword> complaintKeywords;
  List<ComplaintCase> complaintCases;
  String processedComplaints;
  String processingRate;
  List<TrendItem> otherOrganizationTrends;

  MainDashboardData({
    this.topMetrics = const [],
    this.newMerchants = '47',
    this.resolvedComplaints = '23',
    this.supportBudget = '2.3',
    this.complaintKeywords = const [],
    this.complaintCases = const [],
    this.processedComplaints = '187',
    this.processingRate = '94.2',
    this.otherOrganizationTrends = const [],
  });

  factory MainDashboardData.fromJson(Map<String, dynamic> json) {
    return MainDashboardData(
      topMetrics: (json['topMetrics'] as List<dynamic>?)
          ?.map((item) => TopMetric.fromJson(item))
          .toList() ?? 
          [
            TopMetric(icon: '🏪', title: '전체 가맹점', value: '11,426', unit: '개', color: '#6366F1'),
            TopMetric(icon: '✨', title: '이번주 신규', value: '47', unit: '개', color: '#8B5CF6'),
            TopMetric(icon: '📊', title: '가맹률', value: '85.2', unit: '%', color: '#EC4899'),
          ],
      newMerchants: json['newMerchants']?.toString() ?? '47',
      resolvedComplaints: json['resolvedComplaints']?.toString() ?? '23',
      supportBudget: json['supportBudget']?.toString() ?? '2.3',
      complaintKeywords: (json['complaintKeywords'] as List<dynamic>?)
          ?.map((item) => ComplaintKeyword.fromJson(item))
          .toList() ?? 
          [
            ComplaintKeyword(rank: '1', keyword: '주차 문제', count: 34),
            ComplaintKeyword(rank: '2', keyword: '소음 방해', count: 28),
            ComplaintKeyword(rank: '3', keyword: '청소 문제', count: 19),
          ],
      complaintCases: (json['complaintCases'] as List<dynamic>?)
          ?.map((item) => ComplaintCase.fromJson(item))
          .toList() ??
          [
            ComplaintCase(
              title: '동천동 주차장 확장',
              status: '해결',
              detail: '주차 공간 부족으로 인한 민원이 지속적으로 제기되어, 기존 주차장을 확장하고 새로운 주차구역을 확보했습니다.',
            ),
            ComplaintCase(
              title: '유촌동 소음방해 개선',
              status: '진행중',
              detail: '야간 시간대 상가 운영으로 인한 소음 문제를 해결하기 위해 방음시설 설치 및 운영시간 조정을 진행 중입니다.',
            ),
            ComplaintCase(
              title: '청아동 청소 개선',
              status: '해결',
              detail: '쓰레기 무단투기 및 청소 상태 불량 문제를 해결하기 위해 청소 주기를 단축하고 CCTV를 설치했습니다.',
            ),
          ],
      processedComplaints: json['processedComplaints']?.toString() ?? '187',
      processingRate: json['processingRate']?.toString() ?? '94.2',
      otherOrganizationTrends: (json['otherOrganizationTrends'] as List<dynamic>?)
          ?.map((item) => TrendItem.fromJson(item))
          .toList() ??
          [
            TrendItem(
              title: '부산 동구 골목상권 활성화 사업',
              detail: '부산 동구에서 추진 중인 골목상권 활성화 사업으로, 상인회 조직 강화와 디지털 마케팅 지원을 통해 매출 증대를 도모하고 있습니다.',
            ),
            TrendItem(
              title: '대구 중구 전통시장 디지털화',
              detail: '대구 중구 전통시장의 디지털 전환 사업으로, QR코드 결제 시스템 도입과 온라인 쇼핑몰 구축을 통해 젊은 고객층 유입을 늘리고 있습니다.',
            ),
          ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topMetrics': topMetrics.map((item) => item.toJson()).toList(),
      'newMerchants': newMerchants,
      'resolvedComplaints': resolvedComplaints,
      'supportBudget': supportBudget,
      'complaintKeywords': complaintKeywords.map((item) => item.toJson()).toList(),
      'complaintCases': complaintCases.map((item) => item.toJson()).toList(),
      'processedComplaints': processedComplaints,
      'processingRate': processingRate,
      'otherOrganizationTrends': otherOrganizationTrends.map((item) => item.toJson()).toList(),
    };
  }
}

class ComplaintKeyword {
  String rank;
  String keyword;
  int count;

  ComplaintKeyword({
    required this.rank,
    required this.keyword,
    required this.count,
  });

  factory ComplaintKeyword.fromJson(Map<String, dynamic> json) {
    return ComplaintKeyword(
      rank: json['rank']?.toString() ?? '',
      keyword: json['keyword']?.toString() ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'keyword': keyword,
      'count': count,
    };
  }
}

class ComplaintCase {
  String title;
  String status;
  String detail;

  ComplaintCase({
    required this.title,
    required this.status,
    required this.detail,
  });

  factory ComplaintCase.fromJson(Map<String, dynamic> json) {
    return ComplaintCase(
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'detail': detail,
    };
  }
}

class TrendItem {
  String title;
  String detail;

  TrendItem({
    required this.title,
    required this.detail,
  });

  factory TrendItem.fromJson(Map<String, dynamic> json) {
    return TrendItem(
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'detail': detail,
    };
  }
}

class TopMetric {
  String icon;
  String title;
  String value;
  String unit;
  String color;

  TopMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  factory TopMetric.fromJson(Map<String, dynamic> json) {
    return TopMetric(
      icon: json['icon']?.toString() ?? '📊',
      title: json['title']?.toString() ?? '',
      value: json['value']?.toString() ?? '0',
      unit: json['unit']?.toString() ?? '',
      color: json['color']?.toString() ?? '#6366F1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'value': value,
      'unit': unit,
      'color': color,
    };
  }
}

// 새로운 API 모델들
class District {
  final int id;
  final String dongName;
  final int merchantCount;
  final int totalStores;
  final int totalMemberStores;
  final double avgMembershipRate;
  final String createdAt;
  final String updatedAt;

  District({
    required this.id,
    required this.dongName,
    required this.merchantCount,
    required this.totalStores,
    required this.totalMemberStores,
    required this.avgMembershipRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? 0,
      dongName: json['dong_name'] ?? '',
      merchantCount: json['merchant_count'] ?? 0,
      totalStores: json['total_stores'] ?? 0,
      totalMemberStores: json['total_member_stores'] ?? 0,
      avgMembershipRate: (json['avg_membership_rate'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class DistrictMerchants {
  final DistrictInfo district;
  final List<MerchantInfo> merchants;

  DistrictMerchants({
    required this.district,
    required this.merchants,
  });

  factory DistrictMerchants.fromJson(Map<String, dynamic> json) {
    return DistrictMerchants(
      district: DistrictInfo.fromJson(json['district'] ?? {}),
      merchants: (json['merchants'] as List?)
          ?.map((m) => MerchantInfo.fromJson(m))
          .toList() ?? [],
    );
  }
}

class DistrictInfo {
  final int id;
  final String dongName;
  final int merchantCount;
  final int totalStores;
  final int totalMemberStores;
  final double overallMembershipRate;

  DistrictInfo({
    required this.id,
    required this.dongName,
    required this.merchantCount,
    required this.totalStores,
    required this.totalMemberStores,
    required this.overallMembershipRate,
  });

  factory DistrictInfo.fromJson(Map<String, dynamic> json) {
    return DistrictInfo(
      id: json['id'] ?? 0,
      dongName: json['dong_name'] ?? '',
      merchantCount: json['merchant_count'] ?? 0,
      totalStores: json['total_stores'] ?? 0,
      totalMemberStores: json['total_member_stores'] ?? 0,
      overallMembershipRate: (json['overall_membership_rate'] ?? 0).toDouble(),
    );
  }
}

class MerchantInfo {
  final int id;
  final String merchantName;
  final String? president;
  final int storeCount;
  final int? memberStoreCount;
  final double membershipRate;
  final String createdAt;
  final String updatedAt;

  MerchantInfo({
    required this.id,
    required this.merchantName,
    this.president,
    required this.storeCount,
    this.memberStoreCount,
    required this.membershipRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      id: json['id'] ?? 0,
      merchantName: json['merchant_name'] ?? '',
      president: json['president'],
      storeCount: json['store_count'] ?? 0,
      memberStoreCount: json['member_store_count'],
      membershipRate: (json['membership_rate'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Merchant {
  final int id;
  final DistrictInfo district;
  final String merchantName;
  final String? president;
  final int storeCount;
  final int? memberStoreCount;
  final double membershipRate;
  final double membershipPercentage;
  final String createdAt;
  final String updatedAt;

  Merchant({
    required this.id,
    required this.district,
    required this.merchantName,
    this.president,
    required this.storeCount,
    this.memberStoreCount,
    required this.membershipRate,
    required this.membershipPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] ?? 0,
      district: DistrictInfo.fromJson(json['district'] ?? {}),
      merchantName: json['merchant_name'] ?? '',
      president: json['president'],
      storeCount: json['store_count'] ?? 0,
      memberStoreCount: json['member_store_count'],
      membershipRate: (json['membership_rate'] ?? 0).toDouble(),
      membershipPercentage: (json['membership_percentage'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class StatisticsSummary {
  final SummaryData summary;
  final List<TopDistrict> topDistricts;

  StatisticsSummary({
    required this.summary,
    required this.topDistricts,
  });

  factory StatisticsSummary.fromJson(Map<String, dynamic> json) {
    return StatisticsSummary(
      summary: SummaryData.fromJson(json['summary'] ?? {}),
      topDistricts: (json['top_districts'] as List?)
          ?.map((d) => TopDistrict.fromJson(d))
          .toList() ?? [],
    );
  }
}

class SummaryData {
  final int totalDistricts;
  final int totalMerchants;
  final int totalStores;
  final int totalMemberStores;
  final double overallMembershipRate;

  SummaryData({
    required this.totalDistricts,
    required this.totalMerchants,
    required this.totalStores,
    required this.totalMemberStores,
    required this.overallMembershipRate,
  });

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      totalDistricts: json['total_districts'] ?? 0,
      totalMerchants: json['total_merchants'] ?? 0,
      totalStores: json['total_stores'] ?? 0,
      totalMemberStores: json['total_member_stores'] ?? 0,
      overallMembershipRate: (json['overall_membership_rate'] ?? 0).toDouble(),
    );
  }
}

class TopDistrict {
  final String dongName;
  final int merchantCount;

  TopDistrict({
    required this.dongName,
    required this.merchantCount,
  });

  factory TopDistrict.fromJson(Map<String, dynamic> json) {
    return TopDistrict(
      dongName: json['dong_name'] ?? '',
      merchantCount: json['merchant_count'] ?? 0,
    );
  }
}