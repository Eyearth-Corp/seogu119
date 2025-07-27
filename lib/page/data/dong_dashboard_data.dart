/// 동별 대시보드 데이터 모델
class DongDashboardData {
  final DongInfo dongInfo;
  final List<DongMetric> dongMetrics;
  final List<MerchantInfo> merchants;
  final List<NoticeInfo> notices;
  final DongStatistics statistics;

  DongDashboardData({
    required this.dongInfo,
    required this.dongMetrics,
    required this.merchants,
    required this.notices,
    required this.statistics,
  });

  factory DongDashboardData.fromMap(Map<String, dynamic> map) {
    return DongDashboardData(
      dongInfo: DongInfo.fromMap(map['district'] ?? {}),
      dongMetrics: (map['dongMetrics'] as List<dynamic>?)
          ?.map((e) => DongMetric.fromMap(e))
          .toList() ?? [],
      merchants: (map['merchants'] as List<dynamic>?)
          ?.map((e) => MerchantInfo.fromMap(e))
          .toList() ?? [],
      notices: (map['notices'] as List<dynamic>?)
          ?.map((e) => NoticeInfo.fromMap(e))
          .toList() ?? [],
      statistics: DongStatistics.fromMap(map['statistics'] ?? {}),
    );
  }
}

/// 동 기본 정보
class DongInfo {
  final int id;
  final String dongName;
  final int merchantCount;
  final int totalStores;
  final int totalMemberStores;
  final double overallMembershipRate;

  DongInfo({
    required this.id,
    required this.dongName,
    required this.merchantCount,
    required this.totalStores,
    required this.totalMemberStores,
    required this.overallMembershipRate,
  });

  factory DongInfo.fromMap(Map<String, dynamic> map) {
    return DongInfo(
      id: _parseToInt(map['id']) ?? 0,
      dongName: map['dong_name']?.toString() ?? '',
      merchantCount: _parseToInt(map['merchant_count']) ?? 0,
      totalStores: _parseToInt(map['total_stores']) ?? 0,
      totalMemberStores: _parseToInt(map['total_member_stores']) ?? 0,
      overallMembershipRate: _parseToDouble(map['overall_membership_rate']) ?? 0.0,
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt();
    }
    return null;
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

/// 동별 메트릭 정보
class DongMetric {
  final String title;
  final String value;
  final String unit;

  DongMetric({
    required this.title,
    required this.value,
    required this.unit,
  });

  factory DongMetric.fromMap(Map<String, dynamic> map) {
    return DongMetric(
      title: map['title'] ?? '',
      value: map['value'] ?? '',
      unit: map['unit'] ?? '',
    );
  }
}

/// 상인회 정보
class MerchantInfo {
  final int id;
  final String merchantName;
  final String president;
  final int storeCount;
  final int memberStoreCount;
  final double membershipRate;
  final String createdAt;
  final String updatedAt;

  MerchantInfo({
    required this.id,
    required this.merchantName,
    required this.president,
    required this.storeCount,
    required this.memberStoreCount,
    required this.membershipRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantInfo.fromMap(Map<String, dynamic> map) {
    return MerchantInfo(
      id: DongInfo._parseToInt(map['id']) ?? 0,
      merchantName: map['merchant_name']?.toString() ?? '',
      president: map['president']?.toString() ?? '',
      storeCount: DongInfo._parseToInt(map['store_count']) ?? 0,
      memberStoreCount: DongInfo._parseToInt(map['member_store_count']) ?? 0,
      membershipRate: DongInfo._parseToDouble(map['membership_rate']) ?? 0.0,
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  double get membershipPercentage => membershipRate * 100;
}

/// 공지사항 정보
class NoticeInfo {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  NoticeInfo({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoticeInfo.fromMap(Map<String, dynamic> map) {
    return NoticeInfo(
      id: DongInfo._parseToInt(map['id']) ?? 0,
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }
}

/// 동별 통계 정보
class DongStatistics {
  final int totalMerchants;
  final int totalStores;
  final int totalMemberStores;
  final double averageMembershipRate;
  final List<BusinessTypeInfo> businessTypes;

  DongStatistics({
    required this.totalMerchants,
    required this.totalStores,
    required this.totalMemberStores,
    required this.averageMembershipRate,
    required this.businessTypes,
  });

  factory DongStatistics.fromMap(Map<String, dynamic> map) {
    return DongStatistics(
      totalMerchants: DongInfo._parseToInt(map['total_merchants']) ?? 0,
      totalStores: DongInfo._parseToInt(map['total_stores']) ?? 0,
      totalMemberStores: DongInfo._parseToInt(map['total_member_stores']) ?? 0,
      averageMembershipRate: DongInfo._parseToDouble(map['average_membership_rate']) ?? 0.0,
      businessTypes: (map['business_types'] as List<dynamic>?)
          ?.map((e) => BusinessTypeInfo.fromMap(e))
          .toList() ?? [],
    );
  }
}

/// 업종별 정보
class BusinessTypeInfo {
  final String type;
  final int count;
  final double percentage;

  BusinessTypeInfo({
    required this.type,
    required this.count,
    required this.percentage,
  });

  factory BusinessTypeInfo.fromMap(Map<String, dynamic> map) {
    return BusinessTypeInfo(
      type: map['type']?.toString() ?? '',
      count: DongInfo._parseToInt(map['count']) ?? 0,
      percentage: DongInfo._parseToDouble(map['percentage']) ?? 0.0,
    );
  }
}