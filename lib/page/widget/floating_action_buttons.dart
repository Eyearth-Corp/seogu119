import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seogu119/page/data/dong_list.dart';
import 'package:seogu119/page/widget/merchant_list_dialog.dart';
import 'package:seogu119/page/widget/drawing_board_screen.dart';

class FloatingActionButtons extends StatelessWidget {
  final bool isFullscreen;
  final bool isMapLeft; // 지도 위치 상태 추가
  final VoidCallback onSwap;
  final VoidCallback onFullscreen;
  final ValueChanged<Merchant>? onMerchant; // 상인회 선택 시 호출될 콜백
  final String? heroTagSuffix; // Hero 태그 구분을 위한 suffix
  final GlobalKey? mainContentKey; // 스크린샷을 위한 RepaintBoundary 키

  const FloatingActionButtons({
    super.key,
    required this.isFullscreen,
    required this.isMapLeft, // 새 매개변수 추가
    required this.onSwap,
    required this.onFullscreen,
    this.onMerchant, // 생성자에 콜백 추가
    this.heroTagSuffix, // Hero 태그 suffix 추가
    this.mainContentKey, // RepaintBoundary 키 추가
  });

  @override
  Widget build(BuildContext context) {
    return toolButtons(context);
  }

  Widget toolButtons(BuildContext context) {
    final suffix = heroTagSuffix ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 전체화면 버튼
        FloatingActionButton(
          heroTag: "fullscreen_btn$suffix",
          onPressed: onFullscreen,
          child: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
        ),
        const SizedBox(height: 24),
        // 좌우 스왑 버튼 (현재 상태 표시)
        Tooltip(
          message: isMapLeft ? '지도가 왼쪽에 있습니다\n클릭하면 대시보드가 왼쪽으로 이동' : '대시보드가 왼쪽에 있습니다\n클릭하면 지도가 왼쪽으로 이동',
          child: FloatingActionButton(
            heroTag: "swap_btn$suffix",
            onPressed: onSwap,
            backgroundColor: isMapLeft ? Colors.blue[600] : Colors.grey[600],
            child: Icon(
              isMapLeft ? Icons.map : Icons.dashboard,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 상인회 목록 버튼
        FloatingActionButton(
          heroTag: "merchant_btn$suffix",
          onPressed: () => _showMerchantListDialog(context),
          child: const Icon(Icons.store),
        ),
        const SizedBox(height: 24),
        // 그리기 버튼
        FloatingActionButton(
          heroTag: "drawing_btn$suffix",
          onPressed: () => _showDrawingBoard(context),
          backgroundColor: Colors.green[600],
          child: const Icon(Icons.brush, color: Colors.white),
        ),
      ],
    );
  }


  void _showMerchantList(BuildContext context) {


  }



  /// 상인회 목록을 보여주는 다이얼로그를 표시하고, 선택된 상인회 정보를 부모 위젯으로 전달합니다.
  void _showMerchantListDialog(BuildContext context) async {
    // 다이얼로그를 호출하고 반환값을 받습니다.
    final selectedMerchant = await showDialog<Merchant>(
      context: context,
      builder: (BuildContext context) {
        return const MerchantListDialog();
      },
    );

    // 사용자가 상인회를 선택했다면, onMerchant 콜백을 호출합니다.
    if (selectedMerchant != null) {
      onMerchant?.call(selectedMerchant);
    }
  }

  /// 전체 화면 그리기 보드를 표시합니다.
  void _showDrawingBoard(BuildContext context) async {
    // RepaintBoundary 키가 있으면 실제 화면을 캡처
    if (mainContentKey != null) {
      try {
        // RepaintBoundary에서 직접 스크린샷 캡처
        final RenderRepaintBoundary? boundary = 
            mainContentKey!.currentContext?.findRenderObject() as RenderRepaintBoundary?;
            
        if (boundary != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DrawingBoardScreen(
                captureKey: mainContentKey,
              ),
              fullscreenDialog: true,
            ),
          );
          return;
        }
      } catch (e) {
        print('RepaintBoundary 캡처 실패: $e');
      }
    }
    
    // RepaintBoundary가 없거나 캡처 실패 시 기본 화면으로 표시
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrawingBoardScreen(
          backgroundWidget: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: Colors.white,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text(
                        '지도 화면을 캡처하여 배경으로 사용합니다',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
