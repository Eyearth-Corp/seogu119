import 'package:flutter/material.dart';
import 'package:seogu119/page/data/dong_list.dart';
import 'package:seogu119/page/widget/merchant_list_dialog.dart';

class FloatingActionButtons extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback onSwap;
  final VoidCallback onFullscreen;
  final ValueChanged<Merchant>? onMerchant; // 상인회 선택 시 호출될 콜백

  const FloatingActionButtons({
    super.key,
    required this.isFullscreen,
    required this.onSwap,
    required this.onFullscreen,
    this.onMerchant, // 생성자에 콜백 추가
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        // 버튼들을 화면 양쪽에 배치
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 버튼 그룹
            toolButtons(context),
            // 오른쪽 버튼 그룹
            toolButtons(context),
          ],
        ),
      ),
    );
  }

  Widget toolButtons(BuildContext context) {
    return Column(
      children: [
        // 전체화면 버튼
        FloatingActionButton(
          onPressed: onFullscreen,
          child: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
        ),
        const SizedBox(height: 8),
        // 좌우 스왑 버튼
        FloatingActionButton(
          onPressed: onSwap,
          child: const Icon(Icons.swap_horiz),
        ),
        const SizedBox(height: 8),
        // 상인회 목록 버튼
        FloatingActionButton(
          onPressed: () => _showMerchantList(context),
          child: const Icon(Icons.store),
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
}
