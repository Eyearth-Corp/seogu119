import 'dart:convert';
import 'package:flutter/services.dart';

/// 대시보드 데이터 모델
class DashboardData {
  final String collectionDate;
  final String phase;
  final String title;
  final int totalAreas;
  final int totalStores;
  final DashboardSummary summary;
  final Map<String, int> storesByCategory;
  final double onNuriCardRate;
  final List<AreaDetail> areaDetails;
  final List<PhaseData>? phaseData;
  final List<OnNuriTrendPoint>? onNuriTrendData;
  final Map<String, DongInfo>? areasByDong;

  const DashboardData({
    required this.collectionDate,
    required this.phase,
    required this.title,
    required this.totalAreas,
    required this.totalStores,
    required this.summary,
    required this.storesByCategory,
    required this.onNuriCardRate,
    required this.areaDetails,
    this.phaseData,
    this.onNuriTrendData,
    this.areasByDong,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      collectionDate: json['collectionDate'] ?? '',
      phase: json['phase'] ?? '',
      title: json['title'] ?? '',
      totalAreas: json['totalAreas'] ?? 0,
      totalStores: json['totalStores'] ?? 0,
      summary: DashboardSummary.fromJson(json['summary'] ?? {}),
      storesByCategory: Map<String, int>.from(json['storesByCategory'] ?? {}),
      onNuriCardRate: (json['onNuriCardRate'] ?? 0.0).toDouble(),
      areaDetails: (json['areaDetails'] as List<dynamic>? ?? [])
          .map((item) => AreaDetail.fromJson(item))
          .toList(),
      phaseData: json['phaseData'] != null
          ? (json['phaseData'] as List<dynamic>)
              .map((item) => PhaseData.fromJson(item))
              .toList()
          : null,
      onNuriTrendData: json['onNuriTrendData'] != null
          ? (json['onNuriTrendData'] as List<dynamic>)
              .map((item) => OnNuriTrendPoint.fromJson(item))
              .toList()
          : null,
      areasByDong: json['areasByDong'] != null
          ? (json['areasByDong'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, DongInfo.fromJson(value)))
          : null,
    );
  }
}

/// 대시보드 요약 정보
class DashboardSummary {
  final int areas;
  final int stores;
  final double completionRate;

  const DashboardSummary({
    required this.areas,
    required this.stores,
    required this.completionRate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      areas: json['areas'] ?? 0,
      stores: json['stores'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
    );
  }
}

/// 지역 상세 정보
class AreaDetail {
  final String name;
  final int stores;
  final String category;

  const AreaDetail({
    required this.name,
    required this.stores,
    required this.category,
  });

  factory AreaDetail.fromJson(Map<String, dynamic> json) {
    return AreaDetail(
      name: json['name'] ?? '',
      stores: json['stores'] ?? 0,
      category: json['category'] ?? '',
    );
  }
}

/// 차수별 데이터
class PhaseData {
  final String phase;
  final String date;
  final int areas;
  final int stores;

  const PhaseData({
    required this.phase,
    required this.date,
    required this.areas,
    required this.stores,
  });

  factory PhaseData.fromJson(Map<String, dynamic> json) {
    return PhaseData(
      phase: json['phase'] ?? '',
      date: json['date'] ?? '',
      areas: json['areas'] ?? 0,
      stores: json['stores'] ?? 0,
    );
  }
}

/// 온누리상품권 추이 데이터 포인트
class OnNuriTrendPoint {
  final String date;
  final double rate;

  const OnNuriTrendPoint({
    required this.date,
    required this.rate,
  });

  factory OnNuriTrendPoint.fromJson(Map<String, dynamic> json) {
    return OnNuriTrendPoint(
      date: json['date'] ?? '',
      rate: (json['rate'] ?? 0.0).toDouble(),
    );
  }
}

/// 동별 정보
class DongInfo {
  final int areas;
  final int stores;

  const DongInfo({
    required this.areas,
    required this.stores,
  });

  factory DongInfo.fromJson(Map<String, dynamic> json) {
    return DongInfo(
      areas: json['areas'] ?? 0,
      stores: json['stores'] ?? 0,
    );
  }
}

/// 데이터 날짜 선택지
class DataDate {
  final String date;
  final String phase;
  final String displayName;
  final String fileName;

  const DataDate({
    required this.date,
    required this.phase,
    required this.displayName,
    required this.fileName,
  });
}

/// 대시보드 데이터 관리자
class DashboardDataManager {
  static const List<DataDate> availableDates = [
    DataDate(
      date: 'all',
      phase: '전체',
      displayName: '전체 데이터',
      fileName: 'data_total.json',
    ),
    DataDate(
      date: '2025-06-20',
      phase: '6차',
      displayName: '6차 (25.6.20)',
      fileName: 'data_20250620.json',
    ),
    DataDate(
      date: '2025-05-16',
      phase: '4차',
      displayName: '4차 (25.5.16)',
      fileName: 'data_20250516.json',
    ),
    DataDate(
      date: '2025-05-01',
      phase: '3차',
      displayName: '3차 (25.5.1)',
      fileName: 'data_20250501.json',
    ),
    DataDate(
      date: '2025-03-31',
      phase: '2차',
      displayName: '2차 (25.3.31)',
      fileName: 'data_20250331.json',
    ),
    DataDate(
      date: '2024-12-05',
      phase: '1차',
      displayName: '1차 (24.12.5)',
      fileName: 'data_20241205.json',
    ),
  ];

  /// 특정 날짜의 데이터 로드
  static Future<DashboardData?> loadDataForDate(String date) async {
    try {
      final dataDate = availableDates.firstWhere(
        (d) => d.date == date,
        orElse: () => availableDates.first, // 기본값으로 전체 데이터
      );

      final jsonString = await rootBundle.loadString('assets/excel/${dataDate.fileName}');
      final jsonData = json.decode(jsonString);
      return DashboardData.fromJson(jsonData);
    } catch (e) {
      print('Error loading data for date $date: $e');
      return null;
    }
  }

  /// 전체 데이터 로드
  static Future<DashboardData?> loadTotalData() async {
    return loadDataForDate('all');
  }

  /// 사용 가능한 날짜 목록 반환
  static List<DataDate> getAvailableDates() {
    return availableDates;
  }
}