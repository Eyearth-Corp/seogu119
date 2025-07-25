import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://seogu119-api.eyearth.net/api';
  
  static Future<MainDashboardResponse> getMainDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/main-dashboard'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return MainDashboardResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load main dashboard: ${response.statusCode}');
    }
  }

  static Future<bool> updateMainDashboard(String date, MainDashboardData data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/main-dashboard/$date'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_formatDashboardDataForAPI(data)),
    );

    return response.statusCode == 200;
  }

  /// API 요구사항에 맞는 형식으로 대시보드 데이터 변환
  static Map<String, dynamic> _formatDashboardDataForAPI(MainDashboardData data) {
    return {
      'topMetrics': data.topMetrics.map((metric) => metric.toJson()).toList(),
      'trendChart': {
        'title': '📈 온누리 가맹점 추이',
        'data': [
          {'x': 0, 'y': 75},
          {'x': 1, 'y': 78},
          {'x': 2, 'y': 82},
          {'x': 3, 'y': 80},
          {'x': 4, 'y': 85},
          {'x': 5, 'y': 87}
        ]
      },
      'dongMembership': {
        'title': '🗺️ 동별 가맹률 현황',
        'data': [
          {'name': '동천동', 'percentage': 92.1},
          {'name': '유촌동', 'percentage': 88.3},
          {'name': '치평동', 'percentage': 85.7}
        ]
      },
      'complaintKeywords': {
        'title': '🔥 민원 TOP 3 키워드',
        'data': data.complaintKeywords.map((item) => {
          'rank': item.rank,
          'keyword': item.keyword,
          'count': item.count
        }).toList()
      },
      'complaintCases': {
        'title': '✅ 민원 해결 사례',
        'data': data.complaintCases.map((item) => {
          'title': item.title,
          'status': item.status,
          'detail': item.detail
        }).toList()
      },
      'complaintPerformance': {
        'title': '📋 민원처리 실적',
        'processed': data.processedComplaints,
        'rate': '${data.processingRate}%'
      },
      'organizationTrends': {
        'title': '🌐 타 기관·지자체 주요 동향',
        'data': data.otherOrganizationTrends.map((item) => {
          'title': item.title,
          'detail': item.detail
        }).toList()
      },
      'weeklyAchievements': [
        {'title': '신규 가맹점', 'value': '${data.newMerchants}개'},
        {'title': '민원 해결', 'value': '${data.resolvedComplaints}건'},
        {'title': '지원 예산', 'value': '${data.supportBudget}억'}
      ]
    };
  }
}

class MainDashboardResponse {
  final List<String> availableDates;
  final MainDashboardData data;

  MainDashboardResponse({
    required this.availableDates,
    required this.data,
  });

  factory MainDashboardResponse.fromJson(Map<String, dynamic> json) {
    return MainDashboardResponse(
      availableDates: List<String>.from(json['availableDates'] ?? []),
      data: MainDashboardData.fromJson(json['data'] ?? {}),
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