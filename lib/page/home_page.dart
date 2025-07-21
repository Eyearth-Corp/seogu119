import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        dong: _selectedDong!,
        onBackPressed: () => _onDongSelected(null),
        onMerchantSelected: _navigateToMerchant,
      );
    }
    
    return const MainDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: SeoguColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            const Text(
              '광주광역시 서구 골목경제 119 상황판',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: FloatingActionButtons(
                        isFullscreen: _isFullscreen,
                        onSwap: _toggleMapPosition,
                        onFullscreen: _toggleFullscreen,
                        onMerchant: _navigateToMerchant
                    ),
                  ),
                  // Left Dashboard Space (50%)
                  Expanded(
                    flex: 5,
                    child: _buildDashboardSpace(),
                  ),
                  Expanded(
                    flex: 7,
                    child: MapWidget(
                      controller: _mapController,
                      onMerchantSelected: (merchant) {
                        print('Selected merchant: ${merchant.id} - ${merchant.name}');
                      },
                      onDongSelected: _onDongSelected,
                    ),
                  ),
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: FloatingActionButtons(
                        isFullscreen: _isFullscreen,
                        onSwap: _toggleMapPosition,
                        onFullscreen: _toggleFullscreen,
                        onMerchant: _navigateToMerchant
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}