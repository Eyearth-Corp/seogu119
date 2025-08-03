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