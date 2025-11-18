import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seogu119/page/data/dong_list.dart';
import 'package:seogu119/page/data/admin_service.dart';
import 'package:seogu119/page/admin/admin_login_page.dart';
import 'package:seogu119/page/admin/new_admin_dashboard_page.dart';
import 'package:seogu119/page/widget/merchant_list_dialog.dart';
import 'package:seogu119/page/widget/drawing_board_screen.dart';
import 'package:seogu119/services/analytics_service.dart';

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
        const SizedBox(height: 16),
        // 좌우 스왑 버튼 (현재 상태 표시)
        FloatingActionButton(
          heroTag: "swap_btn$suffix",
          onPressed: onSwap,
          child: Icon(Icons.swap_horiz),
        ),
        const SizedBox(height: 16),
        // 상인회 목록 버튼
        FloatingActionButton(
          heroTag: "merchant_btn$suffix",
          onPressed: () => _showMerchantListDialog(context),
          child: const Icon(Icons.store),
        ),
        const SizedBox(height: 16),
        // 그리기 버튼
        FloatingActionButton(
          heroTag: "drawing_btn$suffix",
          onPressed: () => _showDrawingBoard(context),
          child: const Icon(Icons.brush),
        ),
        const SizedBox(height: 80),
        // 관리자 페이지 버튼
        FloatingActionButton(
          heroTag: "admin_btn$suffix",
          onPressed: () => _navigateToAdminPage(context),
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.admin_panel_settings, color: Colors.white),
        ),
        const SizedBox(height: 16),
        // 로그아웃 버튼
        FloatingActionButton(
          heroTag: "logout_btn$suffix",
          onPressed: () => _handleLogout(context),
          backgroundColor: Colors.red[400],
          child: const Icon(Icons.logout, color: Colors.white),
        ),
      ],
    );
  }


  /// 관리자 페이지로 이동
  void _navigateToAdminPage(BuildContext context) {
    // Analytics: 관리자 페이지 이동 버튼 클릭
    AnalyticsService.trackClick(
      '/dashboard',
      'btn_admin_page',
      elementText: '관리자 페이지',
    );
    AnalyticsService.trackNavigation(
      fromRoute: '/dashboard',
      toRoute: '/admin/dashboard',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewAdminDashboardPage(),
      ),
    );
  }

  /// 로그아웃 처리
  void _handleLogout(BuildContext context) async {
    // Analytics: 로그아웃 버튼 클릭
    AnalyticsService.trackClick(
      '/dashboard',
      'btn_logout',
      elementText: '로그아웃',
    );
    // 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '로그아웃',
            style: TextStyle(fontFamily: 'NotoSans'),
          ),
          content: const Text(
            '정말 로그아웃 하시겠습니까?',
            style: TextStyle(fontFamily: 'NotoSans'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'NotoSans'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Analytics: 로그아웃 확인
      AnalyticsService.trackCustomEvent(
        eventType: 'logout',
        pageRoute: '/dashboard',
      );

      // 로그아웃 수행
      await AdminService.logout();

      // 로그인 페이지로 이동 (스택 초기화)
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AdminLoginPage(),
          ),
          (route) => false,
        );
      }
    }
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
