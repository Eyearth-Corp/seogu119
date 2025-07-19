
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
    final isSmallScreen = screenWidth < 600;
    final isMobileScreen = screenWidth < 480;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobileScreen ? 16.0 : isSmallScreen ? 24.0 : 40.0,
        vertical: isMobileScreen ? 40.0 : 60.0,
      ),
      child: Container(
        width: _getDialogWidth(screenWidth),
        height: _getDialogHeight(screenHeight),
        padding: EdgeInsets.all(isMobileScreen ? 16.0 : 24.0),
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
                      fontSize: isMobileScreen ? 18.0 : 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: isMobileScreen ? 20.0 : 24.0,
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: isMobileScreen ? 8.0 : 16.0),
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
                      bottom: isMobileScreen ? 16.0 : 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 동 이름 헤더
                        Text(
                          dong.name,
                          style: TextStyle(
                            fontSize: isMobileScreen ? 16.0 : 18.0,
                            fontWeight: FontWeight.bold,
                            color: dong.color,
                          ),
                        ),
                        SizedBox(height: isMobileScreen ? 6.0 : 8.0),
                        Divider(
                          thickness: 1.5,
                          color: dong.color.withOpacity(0.3),
                        ),
                        SizedBox(height: isMobileScreen ? 6.0 : 8.0),
                        // 상인회 그리드
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _calculateCrossAxisCount(screenWidth),
                            childAspectRatio: _getChildAspectRatio(screenWidth),
                            mainAxisSpacing: isMobileScreen ? 6.0 : 8.0,
                            crossAxisSpacing: isMobileScreen ? 6.0 : 8.0,
                          ),
                          itemCount: dong.merchantList.length,
                          itemBuilder: (context, merchantIndex) {
                            final merchant = dong.merchantList[merchantIndex];
                            return _buildMerchantButton(
                              context, 
                              merchant, 
                              isMobileScreen,
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
            SizedBox(height: isMobileScreen ? 12.0 : 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      fontSize: isMobileScreen ? 14.0 : 16.0,
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
    bool isMobileScreen,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(merchant),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobileScreen ? 8.0 : 12.0,
            vertical: isMobileScreen ? 6.0 : 8.0,
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            '${merchant.id}. ${merchant.name}',
            style: TextStyle(
              fontSize: isMobileScreen ? 12.0 : 13.0,
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
    if (screenWidth < 480) return screenWidth * 0.95;
    if (screenWidth < 600) return screenWidth * 0.9;
    if (screenWidth < 900) return screenWidth * 0.8;
    if (screenWidth < 1200) return screenWidth * 0.7;
    return screenWidth * 0.6;
  }

  double _getDialogHeight(double screenHeight) {
    if (screenHeight < 600) return screenHeight * 0.9;
    if (screenHeight < 800) return screenHeight * 0.8;
    return screenHeight * 0.75;
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 480) return 1;
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 2;
    if (screenWidth < 1200) return 3;
    if (screenWidth < 1600) return 4;
    return 5;
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 480) return 4.5;
    if (screenWidth < 600) return 4.0;
    if (screenWidth < 900) return 3.8;
    return 3.5;
  }
}
