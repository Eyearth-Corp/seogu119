import 'package:flutter/material.dart';

import '../../../core/api_service.dart';
import '../../../core/colors.dart';
import '../../../services/analytics_service.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_widget.dart';

class DashBoardBbs2Widget extends StatefulWidget {
  const DashBoardBbs2Widget({super.key, required this.dashboardId});
  final int dashboardId;

  @override
  State<DashBoardBbs2Widget> createState() => _DashBoardBbs2WidgetState();
}

class _DashBoardBbs2WidgetState extends State<DashBoardBbs2Widget> {
  Bbs2Response? _response;
  bool _isLoading = true;
  String? _error;
  Color backgroundColor = Colors.white;

  /// 색상을 밝게 만드는 헬퍼 함수
  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }

  /// 색상을 어둡게 만드는 헬퍼 함수
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  /// 색상이 어두운지 판단하는 헬퍼 함수
  bool _isDarkColor(Color color) {
    // 상대적 휘도(relative luminance) 계산
    final red = (color.r * 255.0).round();
    final green = (color.g * 255.0).round();
    final blue = (color.b * 255.0).round();
    final luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance < 0.5;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiService.getDashBoardBbs2(widget.dashboardId);
      if (mounted) {
        setState(() {
          _response = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 로딩 상태에서도 기본 그라데이션 적용
      final topColor = _lightenColor(SeoguColors.surface, 0.1);
      final bottomColor = _darkenColor(SeoguColors.surface, 0.1);

      return Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      // 에러 상태에서도 기본 그라데이션 적용
      final topColor = _lightenColor(SeoguColors.surface, 0.1);
      final bottomColor = _darkenColor(SeoguColors.surface, 0.1);

      return Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text('데이터 로드 실패', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 4),
              Text(_error!, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_response == null || _response!.bbs2Data.isEmpty) {
      return emptyDataMessage();
    }

    //double height = 88.0 + (42 * _response!.bbs2Data.length);

    // 배경색 결정
    final baseColor = _response!.backgroundColor != null
        ? Color(int.parse('FF${_response!.backgroundColor}', radix: 16))
        : SeoguColors.surface;

    backgroundColor = baseColor;

    // 그라데이션용 색상 생성 (위: 밝게, 아래: 어둡게)
    var topColor = _lightenColor(baseColor, 0.1); // 10% 밝게
    var bottomColor = _darkenColor(baseColor, 0.1); // 10% 어둡게

    // 흰색이면
    // 그라데이션도 흰색
    if (baseColor == Colors.white) {
      topColor = Colors.white;
      bottomColor = Colors.white;
    }

    return Container(
      //height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_response!.title.isNotEmpty)
            Row(
              children: [
                Text(
                  _response!.title,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: _response!.titleColor != null
                        ? Color(
                            int.parse('FF${_response!.titleColor}', radix: 16),
                          )
                        : SeoguColors.textPrimary,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: _showExpandedView,
                  tooltip: '전체화면으로 보기',
                  icon: const Icon(
                    Icons.zoom_out_map,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _response!.bbs2Data.map((trendData) {
                  return SizedBox(
                    height: 42,
                    child: _buildBbs2Item(
                      context,
                      trendData.title,
                      trendData.detail,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBbs2Item(BuildContext context, String title, String detail) {
    return InkWell(
      onTap: () => _showBbs2DetailDialog(context, title, detail),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 21,
                color: _isDarkColor(backgroundColor)
                    ? Colors.white
                    : SeoguColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showExpandedView() {
    if (_response == null) return;

    // Analytics: 전체화면 보기 클릭 추적
    AnalyticsService.trackWidgetInteraction(
      '/dashboard',
      widgetType: 'dashboard_bbs2',
      widgetId: widget.dashboardId,
      action: 'open_fullscreen',
      metadata: {
        'title': _response!.title,
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _ExpandedBbs2View(
          response: _response!,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _showBbs2DetailDialog(
    BuildContext context,
    String title,
    String detail,
  ) {
    // Analytics: BBS2 상세 다이얼로그 열기 추적
    AnalyticsService.trackWidgetInteraction(
      '/dashboard',
      widgetType: 'dashboard_bbs2',
      widgetId: widget.dashboardId,
      action: 'open_detail',
      metadata: {
        'item_title': title,
        'has_detail': detail.isNotEmpty,
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 1200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SeoguColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: SeoguColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: SeoguColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.5,
                    color: SeoguColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedBbs2View extends StatelessWidget {
  final Bbs2Response response;
  final VoidCallback onClose;

  const _ExpandedBbs2View({required this.response, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: Stack(
        children: [
          // Background tap to close
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.transparent,
            ),
          ),
          // Expanded widget positioned on the right side
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on the content
              child: Container(
                width: screenSize.width * 0.6, // 60% of screen width
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with title and close button
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SeoguColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              color: SeoguColors.info,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              response.title,
                              style: const TextStyle(
                                fontSize: 53,
                                fontWeight: FontWeight.bold,
                                color: SeoguColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onClose,
                            tooltip: '닫기',
                            icon: const Icon(
                              Icons.zoom_in_map,
                              color: Color(0xFF64748B),
                              size: 24,
                            ),
                          ),
                          IconButton(
                            onPressed: onClose,
                            tooltip: '닫기',
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF64748B),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: response.bbs2Data.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = response.bbs2Data[index];
                          return _buildExpandedBbs2Item(
                            context,
                            item.title,
                            item.detail,
                            index + 1,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedBbs2Item(
    BuildContext context,
    String title,
    String detail,
    int index,
  ) {
    // 배경이 어두우면 흰색 텍스트, 밝으면 검은색 텍스트
    final primaryTextColor = SeoguColors.textPrimary;
    final secondaryTextColor = SeoguColors.textSecondary;
    final dividerColor = const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SeoguColors.info,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 43,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: dividerColor),
          const SizedBox(height: 16),
          Text(
            detail,
            style: TextStyle(
              fontSize: 35,
              height: 1.6,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
