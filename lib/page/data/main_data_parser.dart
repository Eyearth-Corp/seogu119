import 'dart:convert';
import 'package:flutter/services.dart';

class Type1Data {
  final String title;
  final String value;
  final String unit;

  Type1Data({
    required this.title,
    required this.value,
    required this.unit,
  });

  factory Type1Data.fromJson(Map<String, dynamic> json) {
    return Type1Data(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}

class Type2Data {
  final String title;
  final String value;

  Type2Data({
    required this.title,
    required this.value,
  });

  factory Type2Data.fromJson(Map<String, dynamic> json) {
    return Type2Data(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
    );
  }
}


class Type3ItemData {
  final String rank;
  final String keyword;
  final int count;

  Type3ItemData({
    required this.rank,
    required this.keyword,
    required this.count,
  });

  factory Type3ItemData.fromJson(Map<String, dynamic> json) {
    return Type3ItemData(
      rank: json['rank'] ?? '',
      keyword: json['keyword'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class Type4Data {
  final String title;
  final String processed;
  final String rate;

  Type4Data({
    required this.title,
    required this.processed,
    required this.rate,
  });

  factory Type4Data.fromJson(Map<String, dynamic> json) {
    return Type4Data(
      title: json['title'] ?? '',
      processed: json['processed'] ?? '',
      rate: json['rate'] ?? '',
    );
  }
}


class Bbs1ItemData {
  final String title;
  final String status;
  final String detail;

  Bbs1ItemData({
    required this.title,
    required this.status,
    required this.detail,
  });

  factory Bbs1ItemData.fromJson(Map<String, dynamic> json) {
    return Bbs1ItemData(
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

class Bbs2ItemData {
  final String title;
  final String detail;

  Bbs2ItemData({
    required this.title,
    required this.detail,
  });

  factory Bbs2ItemData.fromJson(Map<String, dynamic> json) {
    return Bbs2ItemData(
      title: json['title'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

class ChartDataPoint {
  final double x;
  final double y;

  ChartDataPoint({
    required this.x,
    required this.y,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
    );
  }
}

class PercentItemData {
  final String name;
  final double percentage;

  PercentItemData({
    required this.name,
    required this.percentage,
  });

  factory PercentItemData.fromJson(Map<String, dynamic> json) {
    return PercentItemData(
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

// Chart Widget Response Model
class ChartResponse {
  final String title;
  final List<ChartDataPoint> chartData;

  ChartResponse({
    required this.title,
    required this.chartData,
  });

  factory ChartResponse.fromJson(Map<String, dynamic> json) {
    return ChartResponse(
      title: json['title'] ?? '',
      chartData: (json['chart_data'] as List<dynamic>?)
          ?.map((item) => ChartDataPoint.fromJson(item))
          .toList() ?? [],
    );
  }
}

// Percent Widget Response Model
class PercentResponse {
  final String title;
  final List<PercentItemData> percentData;

  PercentResponse({
    required this.title,
    required this.percentData,
  });

  factory PercentResponse.fromJson(Map<String, dynamic> json) {
    return PercentResponse(
      title: json['title'] ?? '',
      percentData: (json['percent_data'] as List<dynamic>?)
          ?.map((item) => PercentItemData.fromJson(item))
          .toList() ?? [],
    );
  }
}

// Type2 Widget Response Model
class Type2Response {
  final String title;
  final List<Type2Data> type2Data;

  Type2Response({
    required this.title,
    required this.type2Data,
  });

  factory Type2Response.fromJson(Map<String, dynamic> json) {
    return Type2Response(
      title: json['title'] ?? '',
      type2Data: (json['type2_data'] as List<dynamic>?)
          ?.map((item) => Type2Data.fromJson(item))
          .toList() ?? [],
    );
  }
}

// Type3 Widget Response Model
class Type3Response {
  final String title;
  final List<Type3ItemData> type3Data;

  Type3Response({
    required this.title,
    required this.type3Data,
  });

  factory Type3Response.fromJson(Map<String, dynamic> json) {
    return Type3Response(
      title: json['title'] ?? '',
      type3Data: (json['type3_data'] as List<dynamic>?)
          ?.map((item) => Type3ItemData.fromJson(item))
          .toList() ?? [],
    );
  }
}

// Type4 Widget Response Model
class Type4Response {
  final String title;
  final List<Type4Data> type4Data;

  Type4Response({
    required this.title,
    required this.type4Data,
  });

  factory Type4Response.fromJson(Map<String, dynamic> json) {
    return Type4Response(
      title: json['title'] ?? '',
      type4Data: (json['type4_data'] as List<dynamic>?)
          ?.map((item) => Type4Data.fromJson(item))
          .toList() ?? [],
    );
  }
}

class Type5Data {
  final String emoji;
  final String title;
  final String content1;
  final String content2;

  Type5Data({
    required this.emoji,
    required this.title,
    required this.content1,
    required this.content2,
  });

  factory Type5Data.fromJson(Map<String, dynamic> json) {
    return Type5Data(
      emoji: json['emoji'] ?? '',
      title: json['title'] ?? '',
      content1: json['content1'] ?? '',
      content2: json['content2'] ?? '',
    );
  }
}

class Type5Response {
  final String title;
  final List<Type5Data> type5Data;

  Type5Response({
    required this.title,
    required this.type5Data,
  });

  factory Type5Response.fromJson(Map<String, dynamic> json) {
    return Type5Response(
      title: json['title'] ?? '',
      type5Data: (json['type5_data'] as List<dynamic>?)
          ?.map((item) => Type5Data.fromJson(item))
          .toList() ?? [],
    );
  }
}

// Type1 Widget Response Model
class Type1Response {
  final String title;
  final List<Type1Data> type1Data;

  Type1Response({
    required this.title,
    required this.type1Data,
  });

  factory Type1Response.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return Type1Response(
      title: data['title'] ?? '',
      type1Data: (data['type1_data'] as List<dynamic>?)
          ?.map((item) => Type1Data.fromJson(item))
          .toList() ?? [],
    );
  }
}

// BBS1 Widget Response Model
class Bbs1Response {
  final String title;
  final List<Bbs1ItemData> bbs1Data;

  Bbs1Response({
    required this.title,
    required this.bbs1Data,
  });

  factory Bbs1Response.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return Bbs1Response(
      title: data['title'] ?? '',
      bbs1Data: (data['bbs1_data'] as List<dynamic>?)
          ?.map((item) => Bbs1ItemData.fromJson(item))
          .toList() ?? [],
    );
  }
}

// BBS2 Widget Response Model
class Bbs2Response {
  final String title;
  final List<Bbs2ItemData> bbs2Data;

  Bbs2Response({
    required this.title,
    required this.bbs2Data,
  });

  factory Bbs2Response.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return Bbs2Response(
      title: data['title'] ?? '',
      bbs2Data: (data['bbs2_data'] as List<dynamic>?)
          ?.map((item) => Bbs2ItemData.fromJson(item))
          .toList() ?? [],
    );
  }
}