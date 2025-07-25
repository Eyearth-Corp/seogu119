import 'dart:convert';
import 'package:flutter/services.dart';

/// 대시보드 최상위 메트릭 카드 데이터
class TopMetric {
  final String title;
  final String value;
  final String unit;

  TopMetric({
    required this.title,
    required this.value,
    required this.unit,
  });

  factory TopMetric.fromJson(Map<String, dynamic> json) {
    return TopMetric(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}

/// 주간 성과 데이터
class WeeklyAchievement {
  final String title;
  final String value;

  WeeklyAchievement({
    required this.title,
    required this.value,
  });

  factory WeeklyAchievement.fromJson(Map<String, dynamic> json) {
    return WeeklyAchievement(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

/// 트렌드 차트 데이터 포인트
class TrendDataPoint {
  final double x;
  final double y;

  TrendDataPoint({
    required this.x,
    required this.y,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
    );
  }
}

/// 트렌드 차트 데이터
class TrendChart {
  final String title;
  final List<TrendDataPoint> data;

  TrendChart({
    required this.title,
    required this.data,
  });

  factory TrendChart.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    return TrendChart(
      title: json['title'] ?? '',
      data: dataList.map((item) => TrendDataPoint.fromJson(item)).toList(),
    );
  }
}

/// 동별 가맹률 데이터
class DongMembershipData {
  final String name;
  final double percentage;

  DongMembershipData({
    required this.name,
    required this.percentage,
  });

  factory DongMembershipData.fromJson(Map<String, dynamic> json) {
    return DongMembershipData(
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

/// 동별 가맹률 현황
class DongMembership {
  final String title;
  final List<DongMembershipData> data;

  DongMembership({
    required this.title,
    required this.data,
  });

  factory DongMembership.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    return DongMembership(
      title: json['title'] ?? '',
      data: dataList.map((item) => DongMembershipData.fromJson(item)).toList(),
    );
  }
}

/// 민원 키워드 데이터
class ComplaintKeywordData {
  final String rank;
  final String keyword;
  final int count;

  ComplaintKeywordData({
    required this.rank,
    required this.keyword,
    required this.count,
  });

  factory ComplaintKeywordData.fromJson(Map<String, dynamic> json) {
    return ComplaintKeywordData(
      rank: json['rank'] ?? '',
      keyword: json['keyword'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

/// 민원 키워드
class ComplaintKeywords {
  final String title;
  final List<ComplaintKeywordData> data;

  ComplaintKeywords({
    required this.title,
    required this.data,
  });

  factory ComplaintKeywords.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    return ComplaintKeywords(
      title: json['title'] ?? '',
      data: dataList.map((item) => ComplaintKeywordData.fromJson(item)).toList(),
    );
  }
}

/// 민원 해결 사례 데이터
class ComplaintCaseData {
  final String title;
  final String status;
  final String detail;

  ComplaintCaseData({
    required this.title,
    required this.status,
    required this.detail,
  });

  factory ComplaintCaseData.fromJson(Map<String, dynamic> json) {
    return ComplaintCaseData(
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

/// 민원 해결 사례
class ComplaintCases {
  final String title;
  final List<ComplaintCaseData> data;

  ComplaintCases({
    required this.title,
    required this.data,
  });

  factory ComplaintCases.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    return ComplaintCases(
      title: json['title'] ?? '',
      data: dataList.map((item) => ComplaintCaseData.fromJson(item)).toList(),
    );
  }
}

/// 민원 처리 실적
class ComplaintPerformance {
  final String title;
  final String processed;
  final String rate;

  ComplaintPerformance({
    required this.title,
    required this.processed,
    required this.rate,
  });

  factory ComplaintPerformance.fromJson(Map<String, dynamic> json) {
    return ComplaintPerformance(
      title: json['title'] ?? '',
      processed: json['processed'] ?? '',
      rate: json['rate'] ?? '',
    );
  }
}

/// 타 기관 동향 데이터
class OrganizationTrendData {
  final String title;
  final String detail;

  OrganizationTrendData({
    required this.title,
    required this.detail,
  });

  factory OrganizationTrendData.fromJson(Map<String, dynamic> json) {
    return OrganizationTrendData(
      title: json['title'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

/// 타 기관 동향
class OrganizationTrends {
  final String title;
  final List<OrganizationTrendData> data;

  OrganizationTrends({
    required this.title,
    required this.data,
  });

  factory OrganizationTrends.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    return OrganizationTrends(
      title: json['title'] ?? '',
      data: dataList.map((item) => OrganizationTrendData.fromJson(item)).toList(),
    );
  }
}

/// 전체 메인 대시보드 데이터
class MainDashboardData {
  final List<TopMetric> topMetrics;
  final List<WeeklyAchievement> weeklyAchievements;
  final TrendChart trendChart;
  final DongMembership dongMembership;
  final ComplaintKeywords complaintKeywords;
  final ComplaintCases complaintCases;
  final ComplaintPerformance complaintPerformance;
  final OrganizationTrends organizationTrends;

  MainDashboardData({
    required this.topMetrics,
    required this.weeklyAchievements,
    required this.trendChart,
    required this.dongMembership,
    required this.complaintKeywords,
    required this.complaintCases,
    required this.complaintPerformance,
    required this.organizationTrends,
  });

  factory MainDashboardData.fromJson(Map<String, dynamic> json) {
    var topMetricsJson = json['topMetrics'] as List? ?? [];
    var weeklyAchievementsJson = json['weeklyAchievements'] as List? ?? [];

    return MainDashboardData(
      topMetrics: topMetricsJson.map((item) => TopMetric.fromJson(item)).toList(),
      weeklyAchievements: weeklyAchievementsJson.map((item) => WeeklyAchievement.fromJson(item)).toList(),
      trendChart: TrendChart.fromJson(json['trendChart'] ?? {}),
      dongMembership: DongMembership.fromJson(json['dongMembership'] ?? {}),
      complaintKeywords: ComplaintKeywords.fromJson(json['complaintKeywords'] ?? {}),
      complaintCases: ComplaintCases.fromJson(json['complaintCases'] ?? {}),
      complaintPerformance: ComplaintPerformance.fromJson(json['complaintPerformance'] ?? {}),
      organizationTrends: OrganizationTrends.fromJson(json['organizationTrends'] ?? {}),
    );
  }

  /// API 응답 데이터에서 메인 대시보드 데이터를 생성합니다.
  factory MainDashboardData.fromMap(Map<String, dynamic> data) {
    return MainDashboardData.fromJson(data);
  }

  /// JSON 파일에서 메인 대시보드 데이터를 로드합니다.
  static Future<MainDashboardData> loadFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/main_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return MainDashboardData.fromJson(jsonData);
    } catch (e) {
      print('Error loading main dashboard data: $e');
      // 기본값 반환
      return MainDashboardData(
        topMetrics: [],
        weeklyAchievements: [],
        trendChart: TrendChart(title: '', data: []),
        dongMembership: DongMembership(title: '', data: []),
        complaintKeywords: ComplaintKeywords(title: '', data: []),
        complaintCases: ComplaintCases(title: '', data: []),
        complaintPerformance: ComplaintPerformance(title: '', processed: '', rate: ''),
        organizationTrends: OrganizationTrends(title: '', data: []),
      );
    }
  }
}