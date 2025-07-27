import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://seogu119-api.eyearth.net/api';
  
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
}