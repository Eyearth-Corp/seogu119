import 'dart:math';
import 'package:flutter/material.dart';

/// 가맹점 상태
enum MerchantStatus {
  operating,    // 영업중
  closed,       // 휴업
  relocated,    // 이전
  newOpen,      // 신규개점
}

/// 가맹점 규모
enum MerchantScale {
  small,        // 소형 (1-3명)
  medium,       // 중형 (4-10명)
  large,        // 대형 (11명 이상)
}

/// 개별 가맹점 정보
class MerchantInfo {
  final String id;
  final String name;
  final String category;
  final MerchantStatus status;
  final MerchantScale scale;
  final int employeeCount;
  final double monthlyRevenue; // 월 매출 (만원)
  final bool hasOnNuriCard;
  final DateTime registeredDate;
  final String address;
  final String ownerName;
  final String phoneNumber;

  const MerchantInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.scale,
    required this.employeeCount,
    required this.monthlyRevenue,
    required this.hasOnNuriCard,
    required this.registeredDate,
    required this.address,
    required this.ownerName,
    required this.phoneNumber,
  });
}

/// 동별 가맹점 현황
class DongMerchantStatus {
  final String dongName;
  final List<MerchantInfo> merchants;
  final int totalMerchants;
  final int operatingMerchants;
  final int onNuriCardMerchants;
  final double averageRevenue;
  final Map<String, int> categoryDistribution;
  final Map<MerchantStatus, int> statusDistribution;
  final Map<MerchantScale, int> scaleDistribution;

  const DongMerchantStatus({
    required this.dongName,
    required this.merchants,
    required this.totalMerchants,
    required this.operatingMerchants,
    required this.onNuriCardMerchants,
    required this.averageRevenue,
    required this.categoryDistribution,
    required this.statusDistribution,
    required this.scaleDistribution,
  });

  double get operatingRate => totalMerchants > 0 ? (operatingMerchants / totalMerchants * 100) : 0.0;
  double get onNuriCardRate => totalMerchants > 0 ? (onNuriCardMerchants / totalMerchants * 100) : 0.0;
}

/// 가상 데이터 생성기
class MockDongMerchantDataGenerator {
  static final Random _random = Random();
  
  static const List<String> _categories = [
    '일반음식점', '수퍼마켓', '편의점', '학원', '병원의원', '이용뷰티',
    '일반주점', '여가시설', '부동산업', '가구인테리어', '생활서비스', '기타도소매'
  ];

  static const List<String> _merchantNamePrefixes = [
    '맛있는', '신선한', '편리한', '건강한', '아름다운', '깔끔한', 
    '친절한', '전문', '명품', '프리미엄', '골목', '동네'
  ];

  static const List<String> _merchantNameSuffixes = [
    '식당', '마트', '편의점', '학원', '병원', '미용실',
    '주점', '카페', '부동산', '가구점', '서비스', '상점'
  ];

  static const List<String> _ownerNames = [
    '김철수', '이영희', '박민수', '최서연', '정도현', '강미영',
    '윤준호', '임수진', '조현우', '한예진', '오성민', '신지원'
  ];

  /// 동별 가맹점 현황 데이터 생성
  static DongMerchantStatus generateMerchantStatus(String dongName, int merchantCount) {
    final merchants = <MerchantInfo>[];
    
    for (int i = 0; i < merchantCount; i++) {
      merchants.add(_generateMerchantInfo(dongName, i + 1));
    }

    // 통계 계산
    final operatingCount = merchants.where((m) => m.status == MerchantStatus.operating).length;
    final onNuriCount = merchants.where((m) => m.hasOnNuriCard).length;
    final avgRevenue = merchants.isNotEmpty 
        ? merchants.map((m) => m.monthlyRevenue).reduce((a, b) => a + b) / merchants.length
        : 0.0;

    // 카테고리별 분포
    final categoryDist = <String, int>{};
    for (final merchant in merchants) {
      categoryDist[merchant.category] = (categoryDist[merchant.category] ?? 0) + 1;
    }

    // 상태별 분포
    final statusDist = <MerchantStatus, int>{};
    for (final status in MerchantStatus.values) {
      statusDist[status] = merchants.where((m) => m.status == status).length;
    }

    // 규모별 분포
    final scaleDist = <MerchantScale, int>{};
    for (final scale in MerchantScale.values) {
      scaleDist[scale] = merchants.where((m) => m.scale == scale).length;
    }

    return DongMerchantStatus(
      dongName: dongName,
      merchants: merchants,
      totalMerchants: merchantCount,
      operatingMerchants: operatingCount,
      onNuriCardMerchants: onNuriCount,
      averageRevenue: avgRevenue,
      categoryDistribution: categoryDist,
      statusDistribution: statusDist,
      scaleDistribution: scaleDist,
    );
  }

  static MerchantInfo _generateMerchantInfo(String dongName, int index) {
    final category = _categories[_random.nextInt(_categories.length)];
    final prefix = _merchantNamePrefixes[_random.nextInt(_merchantNamePrefixes.length)];
    final suffix = _merchantNameSuffixes[_random.nextInt(_merchantNameSuffixes.length)];
    final name = '$prefix $suffix';
    
    final status = MerchantStatus.values[_random.nextInt(MerchantStatus.values.length)];
    
    // 영업중인 가게가 80% 정도가 되도록 조정
    final adjustedStatus = _random.nextDouble() < 0.8 ? MerchantStatus.operating : status;
    
    final scale = MerchantScale.values[_random.nextInt(MerchantScale.values.length)];
    
    int employeeCount;
    switch (scale) {
      case MerchantScale.small:
        employeeCount = 1 + _random.nextInt(3);
        break;
      case MerchantScale.medium:
        employeeCount = 4 + _random.nextInt(7);
        break;
      case MerchantScale.large:
        employeeCount = 11 + _random.nextInt(15);
        break;
    }

    final monthlyRevenue = 50 + _random.nextDouble() * 450; // 50-500만원
    final hasOnNuriCard = _random.nextDouble() < 0.6; // 60% 확률로 온누리상품권 가맹점
    
    final registeredDate = DateTime.now().subtract(
      Duration(days: _random.nextInt(365 * 3)), // 최근 3년 내 등록
    );

    return MerchantInfo(
      id: '${dongName}_${index.toString().padLeft(3, '0')}',
      name: name,
      category: category,
      status: adjustedStatus,
      scale: scale,
      employeeCount: employeeCount,
      monthlyRevenue: monthlyRevenue,
      hasOnNuriCard: hasOnNuriCard,
      registeredDate: registeredDate,
      address: '$dongName ${_random.nextInt(200) + 1}번지',
      ownerName: _ownerNames[_random.nextInt(_ownerNames.length)],
      phoneNumber: '062-${200 + _random.nextInt(800)}-${1000 + _random.nextInt(9000)}',
    );
  }

  /// 모든 동의 가맹점 데이터 생성
  static Map<String, DongMerchantStatus> generateAllDongData() {
    final dongData = <String, DongMerchantStatus>{};
    
    // dong_list.dart의 동 이름들과 대략적인 가맹점 수
    final dongMerchantCounts = {
      '동천동': 45,
      '유촌동': 38,
      '광천동': 42,
      '치평동': 51,
      '상무1동': 67,
      '화정1동': 58,
      '농성1동': 54,
      '양동': 32,
      '마륵동': 46,
      '상무2동': 61,
      '금고1동': 41,
      '화정4동': 39,
      '화정3동': 48,
      '화정2동': 44,
      '농성2동': 37,
      '금고2동': 49,
      '풍암동': 59,
      '매월동': 35,
      '서창동': 43,
    };

    for (final entry in dongMerchantCounts.entries) {
      dongData[entry.key] = generateMerchantStatus(entry.key, entry.value);
    }

    return dongData;
  }
}

/// 동별 가맹점 데이터 관리자
class DongMerchantDataManager {
  static Map<String, DongMerchantStatus>? _cachedData;

  /// 동별 가맹점 데이터 가져오기
  static Map<String, DongMerchantStatus> getAllDongData() {
    _cachedData ??= MockDongMerchantDataGenerator.generateAllDongData();
    return _cachedData!;
  }

  /// 특정 동의 가맹점 데이터 가져오기
  static DongMerchantStatus? getDongData(String dongName) {
    final allData = getAllDongData();
    return allData[dongName];
  }

  /// 가맹점 상태 한글 변환
  static String getStatusText(MerchantStatus status) {
    switch (status) {
      case MerchantStatus.operating:
        return '영업중';
      case MerchantStatus.closed:
        return '휴업';
      case MerchantStatus.relocated:
        return '이전';
      case MerchantStatus.newOpen:
        return '신규개점';
    }
  }

  /// 가맹점 규모 한글 변환
  static String getScaleText(MerchantScale scale) {
    switch (scale) {
      case MerchantScale.small:
        return '소형';
      case MerchantScale.medium:
        return '중형';
      case MerchantScale.large:
        return '대형';
    }
  }

  /// 상태별 색상 가져오기
  static Color getStatusColor(MerchantStatus status) {
    switch (status) {
      case MerchantStatus.operating:
        return const Color(0xFF10B981); // 초록색
      case MerchantStatus.closed:
        return const Color(0xFFEF4444); // 빨간색
      case MerchantStatus.relocated:
        return const Color(0xFFF59E0B); // 주황색
      case MerchantStatus.newOpen:
        return const Color(0xFF3B82F6); // 파란색
    }
  }
}