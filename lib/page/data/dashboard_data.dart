/// Minimal dashboard data structure for admin pages
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
    );
  }
}

/// Dashboard summary info
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

/// Area details
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

/// Data date selector
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

/// Dashboard data manager
class DashboardDataManager {
  static const List<DataDate> availableDates = [
    DataDate(
      date: 'all',
      phase: '전체',
      displayName: '전체 데이터',
      fileName: 'data_total.json',
    ),
  ];

  /// Load data for specific date (returns null for now)
  static Future<DashboardData?> loadDataForDate(String date) async {
    // Return null for now since we removed the dashboard
    return null;
  }

  /// Get available dates
  static List<DataDate> getAvailableDates() {
    return availableDates;
  }
}