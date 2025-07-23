
import 'package:flutter/material.dart';
import 'package:seogu119/page/data/dong_list.dart';

/// 상인회 목록을 동별 그룹화된 그리드로 보여주는 다이얼로그 위젯
class MerchantListDialog extends StatelessWidget {
  const MerchantListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical:  60.0,
      ),
      child: Container(
        width: _getDialogWidth(screenWidth),
        height: _getDialogHeight(screenHeight),
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Expanded(
                  child: Text(
                    '상인회 목록',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: 24.0,
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 16.0),
            // 콘텐츠
            Expanded(
              child: ListView.builder(
                itemCount: DongList.all.length,
                itemBuilder: (BuildContext context, int index) {
                  final dong = DongList.all[index];
                  if (dong.merchantList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: 48.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 동 이름 헤더
                        Text(
                          dong.name,
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: dong.color,
                          ),
                        ),
                        SizedBox(height:  8.0),
                        // 상인회 그리드
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _calculateCrossAxisCount(screenWidth),
                            childAspectRatio: _getChildAspectRatio(screenWidth),
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                          ),
                          itemCount: dong.merchantList.length,
                          itemBuilder: (context, merchantIndex) {
                            final merchant = dong.merchantList[merchantIndex];
                            return _buildMerchantButton(
                              context, 
                              merchant
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 하단 버튼
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantButton(
    BuildContext context, 
    Merchant merchant,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(merchant),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 16.0,
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            '${merchant.id}. ${merchant.name}',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  double _getDialogWidth(double screenWidth) {
    return screenWidth * 0.7;
  }

  double _getDialogHeight(double screenHeight) {
    return screenHeight * 0.85;
  }

  int _calculateCrossAxisCount(double screenWidth) {
    return 5;
  }

  double _getChildAspectRatio(double screenWidth) {
    return 3.5;
  }
}
