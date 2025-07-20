import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'widget/dashboard_widget.dart';
import 'widget/floating_action_buttons.dart';
import 'widget/map_widget.dart';
import 'widget/admin_access_button.dart';
import 'data/dong_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMapLeft = false;
  bool _isFullscreen = false;
  
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text('광주광역시 서구 골목경제 119 상황판', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold))
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final dashboardFlex = 6;
              final mapFlex = 6;

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
                  Expanded(flex: dashboardFlex, child: const DashboardWidget()),
                  Expanded(
                    flex: mapFlex, 
                    child: RepaintBoundary(
                      child: MapWidget(
                        controller: _mapController,
                        onMerchantSelected: (merchant) {
                          print('Selected merchant: ${merchant.id} - ${merchant.name}');
                        },
                      ),
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