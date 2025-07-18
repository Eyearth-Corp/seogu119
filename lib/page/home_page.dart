import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'widget/dashboard_widget.dart';
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
        title: const Text('서구 골목경제 119 상황판'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final dashboardFlex = 6;
          final mapFlex = 6;

          final children = [
            Expanded(flex: dashboardFlex, child: const DashboardWidget()),
            Expanded(flex: mapFlex, child: const MapWidget()),
          ];

          return Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Row(
                    children: _isMapLeft ? children.reversed.toList() : children,
                  ),
                  FloatingActionButtons(
                    isFullscreen: _isFullscreen,
                    onSwap: _toggleMapPosition,
                    onFullscreen: _toggleFullscreen,
                    onMerchant: (merchant) {
                      print('${merchant.id}  ${merchant.name}');
                    }
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}