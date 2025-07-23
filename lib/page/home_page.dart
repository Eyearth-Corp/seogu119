import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:html' as html;
import 'widget/floating_action_buttons.dart';
import 'widget/map_widget.dart';
import 'widget/dashboard/main_dashboard.dart';
import 'widget/dashboard/dong_dashboard.dart';
import 'data/dong_list.dart';
import '../core/colors.dart';

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
  
  /// MapWidget을 일관된 키로 생성하여 상태 유지
  Widget _buildMapWidget() {
    return RepaintBoundary(
      key: _mapRepaintBoundaryKey,
      child: MapWidget(
        key: _mapWidgetKey,
        controller: _mapController,
        onMerchantSelected: (merchant) {
          print('Selected merchant: ${merchant.id} - ${merchant.name}');
        },
        onDongSelected: _onDongSelected,
        isMapLeft: _isMapLeft,
      ),
    );
  }

  /// 선택된 상인회로 지도 이동
  void _navigateToMerchant(Merchant merchant) {


    _mapController.navigateToMerchant(merchant);
  }
  


  void _toggleMapPosition() {
    setState(() {
      _isMapLeft = !_isMapLeft;
    });
  }

  void _toggleFullscreen() {
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
    setState(() {
      _selectedDong = dong;
    });
  }

  /// 대시보드 공간 - 8개 섹션으로 구성
  Widget _buildDashboardSpace() {
    if (_selectedDong != null) {
      return DongDashboard(
        key: ValueKey('dong_dashboard_${_selectedDong!.name}'),
        dong: _selectedDong!,
        onBackPressed: () => _onDongSelected(null),
        onMerchantSelected: _navigateToMerchant,
      );
    }
    
    return const MainDashboard(key: ValueKey('main_dashboard'));
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
              '광주광역시 서구 골목경제 119 상황판',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: SeoguColors.primary,
              ),
            ),
            const SizedBox(width: 128)
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
                                Expanded(
                                  flex: 7,
                                  child: _buildMapWidget(),
                                ),
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
                                Expanded(
                                  flex: 7,
                                  child: _buildMapWidget(),
                                ),
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