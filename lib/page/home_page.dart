import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../services/analytics_service.dart';
import 'data/dong_list.dart';
import 'widget/dashboard/main_dashboard.dart';
import 'widget/dong_dashboard.dart';
import 'widget/floating_action_buttons.dart';
import 'widget/map_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMapLeft = false;
  bool _isFullscreen = false;
  Dong? _selectedDong; // 선택된 동

  // MapWidget을 제어하기 위한 컨트롤러
  final MapWidgetController _mapController = MapWidgetController();

  // 스크린샷 캡처를 위한 GlobalKey
  final GlobalKey _mapRepaintBoundaryKey = GlobalKey();

  // MapWidget 인스턴스를 유지하기 위한 키
  final GlobalKey _mapWidgetKey = GlobalKey();

  // 메인 콘텐츠 캡처를 위한 키
  final GlobalKey _mainContentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 페이지 뷰 추적
    AnalyticsService.trackPageView(
      route: '/dashboard',
      name: '메인 대시보드',
    );
  }

  /// MapWidget을 일관된 키로 생성하여 상태 유지
  Widget _buildMapWidget() {
    return RepaintBoundary(
      key: _mapRepaintBoundaryKey,
      child: MapWidget(
        key: _mapWidgetKey,
        controller: _mapController,
        onMerchantSelected: (merchant) {
          print('Selected merchant: ${merchant.id} - ${merchant.name}');
          // Analytics: 상인회 마커 클릭 추적
          AnalyticsService.trackMapClick(
            '/dashboard',
            merchantId: merchant.id,
            merchantName: merchant.name,
          );
        },
        onDongSelected: _onDongSelected,
        isMapLeft: _isMapLeft,
      ),
    );
  }

  /// 선택된 상인회로 지도 이동
  void _navigateToMerchant(Merchant merchant) {
    _mapController.navigateToMerchant(merchant);
    // Analytics: 상인회 목록에서 상인회 선택
    AnalyticsService.trackClick(
      '/dashboard',
      'merchant_list_item',
      elementText: merchant.name,
      metadata: {
        'merchant_id': merchant.id,
      },
    );
  }

  void _toggleMapPosition() {
    // Analytics: 지도 위치 전환 버튼 클릭
    AnalyticsService.trackClick(
      '/dashboard',
      'btn_toggle_map',
      elementText: '지도 전환',
      metadata: {'new_position': _isMapLeft ? 'right' : 'left'},
    );
    setState(() {
      _isMapLeft = !_isMapLeft;
    });
  }

  void _toggleFullscreen() {
    // Analytics: 전체화면 토글 버튼 클릭
    AnalyticsService.trackClick(
      '/dashboard',
      'btn_toggle_fullscreen',
      elementText: '전체화면',
      metadata: {'is_fullscreen': !_isFullscreen},
    );
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (kIsWeb) {
        if (_isFullscreen) {
          html.document.documentElement?.requestFullscreen();
        } else {
          html.document.exitFullscreen();
        }
      } else {
        if (_isFullscreen) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      }
    });
  }

  /// 선택된 동 변경 콜백
  void _onDongSelected(Dong? dong) {
    if (dong != null) {
      // Analytics: 지도에서 동 클릭
      AnalyticsService.trackMapClick(
        '/dashboard',
        dongName: dong.name,
      );
    }
    setState(() {
      _selectedDong = dong;
    });
  }

  /// 메인 대시보드로 돌아가기
  void _goToMainDashboard() {
    // Analytics: 메인 대시보드로 돌아가기 버튼 클릭
    AnalyticsService.trackClick(
      '/dashboard',
      'btn_back_to_main',
      elementText: '메인 대시보드로 돌아가기',
    );
    setState(() {
      _selectedDong = null;
    });
  }

  /// 대시보드 공간 - 선택된 동에 따라 메인 또는 동별 대시보드 표시
  Widget _buildDashboardSpace() {
    return Column(
      children: [
        // 대시보드 상단 헤더 (동 선택시만 표시)
        if (_selectedDong != null) _buildDashboardHeader(),

        // 대시보드 내용
        Expanded(
          child: _selectedDong != null
              ? DongDashboard(
                  key: ValueKey('dong_dashboard_${_selectedDong!.name}'),
                  dongName: _selectedDong!.name,
                )
              : const MainDashboard(key: ValueKey('main_dashboard')),
        ),
      ],
    );
  }

  /// 대시보드 헤더 (동 선택시 표시)
  Widget _buildDashboardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: _goToMainDashboard,
            icon: const Icon(
              Icons.dashboard,
              size: 16,
              color: SeoguColors.primary,
            ),
            label: const Text(
              '메인 대시보드',
              style: TextStyle(
                fontSize: 14,
                color: SeoguColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: SeoguColors.primary, width: 1),
              ),
              backgroundColor: SeoguColors.primary.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        foregroundColor: SeoguColors.primary,
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 128),
            Image.asset(
              'assets/images/logo_seogu.png',
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 20),
            Image.asset(
              'assets/images/logo_slogan.png',
              height: 48,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            const Text(
              '* 광주광역시 서구 골목경제 119 상황판',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: SeoguColors.primary,
              ),
            ),
            const SizedBox(width: 128),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: FloatingActionButtons(
                        key: const ValueKey('floating_buttons_left'),
                        isFullscreen: _isFullscreen,
                        isMapLeft: _isMapLeft,
                        onSwap: _toggleMapPosition,
                        onFullscreen: _toggleFullscreen,
                        onMerchant: _navigateToMerchant,
                        heroTagSuffix: '_left',
                      ),
                    ),
                    // 동적 레이아웃: _isMapLeft에 따라 지도와 대시보드 위치 변경
                    Expanded(
                      child: RepaintBoundary(
                        key: _mainContentKey,
                        child: _isMapLeft
                            ? Row(
                                children: [
                                  // 지도가 왼쪽일 때
                                  Expanded(flex: 7, child: _buildMapWidget()),
                                  Expanded(
                                    flex: 5,
                                    child: _buildDashboardSpace(),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  // 대시보드가 왼쪽일 때 (기본)
                                  Expanded(
                                    flex: 5,
                                    child: _buildDashboardSpace(),
                                  ),
                                  Expanded(flex: 7, child: _buildMapWidget()),
                                ],
                              ),
                      ),
                    ),
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: FloatingActionButtons(
                        key: const ValueKey('floating_buttons_right'),
                        isFullscreen: _isFullscreen,
                        isMapLeft: _isMapLeft,
                        onSwap: _toggleMapPosition,
                        onFullscreen: _toggleFullscreen,
                        onMerchant: _navigateToMerchant,
                        heroTagSuffix: '_right',
                        mainContentKey: _mainContentKey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
