import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _prodBaseUrl = 'https://api.seogu119.co.kr';
  static const String _devBaseUrl = 'https://api.seogu119.co.kr';
  
  static String get baseUrl => kDebugMode ? '$_devBaseUrl/api' : _prodBaseUrl;
  
  static Future<Map<String, dynamic>> getMainDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/main-dashboard'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['data'];
        } else {
          throw Exception('API 응답 오류: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  // 새로운 Districts API 메소드들 추가
  static Future<List<dynamic>> getAllDistricts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/districts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data']['districts'];
        }
      }
      throw Exception('Failed to load districts');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getMerchantsByDistrict(String dongName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/districts/$dongName/merchants'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data'];
        }
      }
      throw Exception('Failed to load merchants for $dongName');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getStatisticsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data'];
        }
      }
      throw Exception('Failed to load statistics summary');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}