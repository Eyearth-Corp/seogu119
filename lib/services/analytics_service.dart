import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Analytics Service
/// 사용자 행동 분석을 위한 이벤트 추적 서비스
class AnalyticsService {
  // Debug 모드에서는 localhost, 프로덕션에서는 실제 서버 사용
  static String get baseUrl => kDebugMode
      ? 'https://api.seogu119.co.kr/api/analytics'
      : 'https://api.seogu119.co.kr/api/analytics';

  static String? _sessionId;
  static bool _isEnabled = true;
  static bool _isInitializing = false;

  /// 세션 ID 가져오기
  static String? get sessionId => _sessionId;

  /// Analytics 활성화 여부
  static bool get isEnabled => _isEnabled;

  /// Analytics 활성화/비활성화
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      print('Analytics: Disabled');
    } else {
      print('Analytics: Enabled');
    }
  }

  /// 세션 시작
  /// 앱 시작 시 호출하여 세션 UUID를 발급받습니다.
  static Future<void> startSession() async {
    if (!_isEnabled || _sessionId != null || _isInitializing) return;

    _isInitializing = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ip_address': 'unknown',
          'user_agent': 'Flutter Web/Seogu119',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _sessionId = data['data']['session_id'];
          print('✅ Analytics Session Started: $_sessionId');
        } else {
          print('❌ Analytics Error: Invalid response format');
        }
      } else {
        print('❌ Analytics Error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Analytics Error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// 이벤트 기록 (내부 메서드)
  static Future<void> _trackEvent({
    required String eventType,
    required String pageRoute,
    Map<String, dynamic>? eventData,
  }) async {
    if (!_isEnabled) return;

    // 세션이 없으면 자동으로 시작 시도
    if (_sessionId == null && !_isInitializing) {
      if (kDebugMode) {
        print('⚠️  Analytics: Session not started. Auto-starting session...');
      }
      await startSession();

      // 세션 시작 실패 시 이벤트 추적 중단
      if (_sessionId == null) {
        if (kDebugMode) {
          print('⚠️  Analytics: Failed to start session. Event not tracked.');
        }
        return;
      }
    }

    // 세션이 초기화 중이면 대기
    while (_isInitializing) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (_sessionId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/event'),
        headers: {
          'Content-Type': 'application/json',
          'X-Session-ID': _sessionId!,
        },
        body: jsonEncode({
          'event_type': eventType,
          'page_route': pageRoute,
          'event_data': eventData ?? {},
        }),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('❌ Analytics Error: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error: $e');
      }
    }
  }

  /// 페이지 뷰 추적
  /// 페이지 진입 시 호출합니다.
  ///
  /// 예제:
  /// ```dart
  /// AnalyticsService.trackPageView(
  ///   route: '/dashboard',
  ///   name: '메인 대시보드',
  /// );
  /// ```
  static Future<void> trackPageView({
    required String route,
    required String name,
    String? referrer,
  }) async {
    await _trackEvent(
      eventType: 'page_view',
      pageRoute: route,
      eventData: {
        'page_name': name,
        if (referrer != null) 'referrer': referrer,
      },
    );
  }

  /// 클릭 이벤트 추적
  /// 버튼, 링크 등의 클릭 시 호출합니다.
  ///
  /// 예제:
  /// ```dart
  /// AnalyticsService.trackClick(
  ///   pageRoute: '/dashboard',
  ///   elementId: 'btn_toggle_map',
  ///   elementText: '지도 전환',
  /// );
  /// ```
  static Future<void> trackClick(
    String pageRoute,
    String elementId, {
    String? elementType,
    String? elementText,
    Map<String, dynamic>? metadata,
  }) async {
    await _trackEvent(
      eventType: 'click',
      pageRoute: pageRoute,
      eventData: {
        'element_id': elementId,
        if (elementType != null) 'element_type': elementType,
        if (elementText != null) 'element_text': elementText,
        if (metadata != null) ...metadata,
      },
    );
  }

  /// 지도 클릭 추적
  /// 지도에서 동이나 상인회 마커를 클릭할 때 호출합니다.
  ///
  /// 예제:
  /// ```dart
  /// // 동 클릭
  /// AnalyticsService.trackMapClick(
  ///   pageRoute: '/dashboard',
  ///   dongName: '동천동',
  /// );
  ///
  /// // 상인회 마커 클릭
  /// AnalyticsService.trackMapClick(
  ///   pageRoute: '/dashboard',
  ///   dongName: '동천동',
  ///   merchantId: 5,
  ///   merchantName: '동천상가번영회',
  /// );
  /// ```
  static Future<void> trackMapClick(
    String pageRoute, {
    String? dongName,
    int? merchantId,
    String? merchantName,
    Map<String, dynamic>? additionalData,
  }) async {
    await _trackEvent(
      eventType: 'map_click',
      pageRoute: pageRoute,
      eventData: {
        if (dongName != null) 'dong_name': dongName,
        if (merchantId != null) 'merchant_id': merchantId,
        if (merchantName != null) 'merchant_name': merchantName,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  /// 네비게이션 이벤트 추적
  /// 페이지 이동 시 호출합니다.
  ///
  /// 예제:
  /// ```dart
  /// AnalyticsService.trackNavigation(
  ///   fromRoute: '/dashboard',
  ///   toRoute: '/admin/dong/동천동',
  /// );
  /// ```
  static Future<void> trackNavigation({
    String? fromRoute,
    required String toRoute,
    Map<String, dynamic>? metadata,
  }) async {
    await _trackEvent(
      eventType: 'navigation',
      pageRoute: toRoute,
      eventData: {
        if (fromRoute != null) 'from_route': fromRoute,
        'to_route': toRoute,
        if (metadata != null) ...metadata,
      },
    );
  }

  /// 위젯 인터랙션 추적
  /// 대시보드 위젯과의 상호작용을 추적합니다.
  ///
  /// 예제:
  /// ```dart
  /// AnalyticsService.trackWidgetInteraction(
  ///   pageRoute: '/dashboard',
  ///   widgetType: 'dashboard_type1',
  ///   widgetId: 1,
  ///   action: 'click',
  /// );
  /// ```
  static Future<void> trackWidgetInteraction(
    String pageRoute, {
    required String widgetType,
    int? widgetId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    await _trackEvent(
      eventType: 'click',
      pageRoute: pageRoute,
      eventData: {
        'element_type': 'widget',
        'widget_type': widgetType,
        if (widgetId != null) 'widget_id': widgetId,
        'action': action,
        if (metadata != null) ...metadata,
      },
    );
  }

  /// 커스텀 이벤트 추적
  /// 사전 정의되지 않은 이벤트를 추적할 때 사용합니다.
  ///
  /// 예제:
  /// ```dart
  /// AnalyticsService.trackCustomEvent(
  ///   eventType: 'search',
  ///   pageRoute: '/dashboard',
  ///   eventData: {
  ///     'query': '동천동',
  ///     'results_count': 5,
  ///   },
  /// );
  /// ```
  static Future<void> trackCustomEvent({
    required String eventType,
    required String pageRoute,
    Map<String, dynamic>? eventData,
  }) async {
    await _trackEvent(
      eventType: eventType,
      pageRoute: pageRoute,
      eventData: eventData,
    );
  }

  /// 세션 종료 (선택사항)
  /// 앱 종료 시 명시적으로 세션을 종료하고 싶을 때 호출합니다.
  /// 호출하지 않아도 서버에서 30분 비활성 시 자동 종료됩니다.
  static void endSession() {
    _sessionId = null;
    print('Analytics Session Ended');
  }
}
