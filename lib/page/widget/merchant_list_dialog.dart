
import 'package:flutter/material.dart';
import 'package:seogu119/page/data/dong_list.dart';

/// 상인회 목록을 동별 그룹화된 그리드로 보여주는 다이얼로그 위젯
class MerchantListDialog extends StatelessWidget {
  const MerchantListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      title: const Text('상인회 목록'),
      content: SizedBox(
        width: screenWidth * 0.9,
        // 각 동별 그룹을 표시하기 위해 ListView 사용
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: DongList.all.length,
          itemBuilder: (BuildContext context, int index) {
            final dong = DongList.all[index];
            // 상인회 목록이 없으면 해당 동은 표시하지 않음
            if (dong.merchantList.isEmpty) {
              return const SizedBox.shrink();
            }
            // 동 그룹 (헤더 + 그리드)
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 동 이름 헤더
                  Text(
                    dong.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: dong.color,
                    ),
                  ),
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 8),
                  // 상인회 그리드
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateCrossAxisCount(screenWidth),
                      childAspectRatio: 3.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: dong.merchantList.length,
                    itemBuilder: (context, merchantIndex) {
                      final merchant = dong.merchantList[merchantIndex];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () {
                          // 선택된 상인회 정보를 반환하며 다이얼로그를 닫습니다.
                          Navigator.of(context).pop(merchant);
                        },
                        child: Text(
                          '${merchant.id}. ${merchant.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  /// 화면 너비에 따라 그리드의 컬럼 수를 계산하는 헬퍼 함수
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth > 1800) return 5;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    return 2;
  }
}
