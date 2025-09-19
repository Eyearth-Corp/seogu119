import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/colors.dart';
import '../data/dong_dashboard_data.dart';
import '../../services/dong_api_service.dart';

class DongDashboard extends StatefulWidget {
  final String dongName;
  
  const DongDashboard({
    super.key,
    required this.dongName,
  });

  @override
  State<DongDashboard> createState() => _DongDashboardState();
}

class _DongDashboardState extends State<DongDashboard> {
  DongDashboardData? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void didUpdateWidget(DongDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dongName != widget.dongName) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DongApiService.getCompleteDongDashboard(widget.dongName);
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dong dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.teal.shade100,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dashboardData == null) {
      return Container(
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.teal.shade100,
            ],
          ),
        ),
        child: const Center(
          child: Text('데이터를 불러올 수 없습니다.'),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.teal.shade100,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 동 제목
              _buildDongHeader(),
              const SizedBox(height: 20),
              // 상단 메트릭 카드들
              _buildTopMetrics(),
              const SizedBox(height: 20),
              // 최근 공지사항
              _buildRecentNotices(),
              const SizedBox(height: 20),
              // 상인회 목록
              _buildMerchantsList(),
            ],
          ),
        ),
      ),
    );
  }

  /// 동 제목 헤더
  Widget _buildDongHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SeoguColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_city,
              color: SeoguColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.dongName} 대시보드',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: SeoguColors.textPrimary,
                  ),
                ),
                Text(
                  '상인회 ${_dashboardData!.dongInfo.merchantCount}개 · 점포 ${_dashboardData!.dongInfo.totalStores}개',
                  style: const TextStyle(
                    fontSize: 16,
                    color: SeoguColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 상단 메트릭 카드들
  Widget _buildTopMetrics() {
    final metrics = _dashboardData?.dongMetrics ?? [];
    
    if (metrics.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    final colors = [SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent, SeoguColors.info];

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: metrics.asMap().entries.map((entry) {
            final index = entry.key;
            final metric = entry.value;
            final color = index < colors.length ? colors[index] : SeoguColors.primary;
            return _buildMetricCard(metric.title, metric.value, metric.unit, color);
          }).toList(),
      ),
    );

    // return Wrap(
    //   spacing: 16,
    //   runSpacing: 16,
    //   children: metrics.asMap().entries.map((entry) {
    //     final index = entry.key;
    //     final metric = entry.value;
    //     final color = index < colors.length ? colors[index] : SeoguColors.primary;
    //
    //     return SizedBox(
    //       width: (MediaQuery.of(context).size.width - 80) / 2, // 2열 배치
    //       child: _buildMetricCard(metric.title, metric.value, metric.unit, color),
    //     );
    //   }).toList(),
    // );
  }

  /// 개별 메트릭 카드
  Widget _buildMetricCard(String title, String value, String unit, Color color) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SeoguColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                color: SeoguColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 16,
                      color: SeoguColors.textSecondary,
                      fontWeight: FontWeight.w500,
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

  /// 상인회 목록
  Widget _buildMerchantsList() {
    final merchants = _dashboardData?.merchants ?? [];
    
    if (merchants.isEmpty) {
      return _buildEmptyDataMessage();
    }



    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏪 상인회 현황',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: merchants.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {


              final merchant = merchants[index];
              return _buildMerchantItem(merchant, index);
            },
          ),
        ],
      ),
    );
  }

  /// 개별 상인회 아이템
  Widget _buildMerchantItem(MerchantInfo merchant, seoguId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${seoguId}. ${merchant.merchantName}",
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: SeoguColors.textPrimary,
                  ),
                ),
                if (merchant.president.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '회장: ${merchant.president}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: SeoguColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${merchant.storeCount}개',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                color: SeoguColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${merchant.memberStoreCount}개',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                color: SeoguColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${merchant.membershipPercentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: _getMembershipRateColor(merchant.membershipPercentage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 분석 아이템
  Widget _buildAnalysisItem(String label, String count, String range, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            range,
            style: const TextStyle(
              fontSize: 13,
              color: SeoguColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 최근 공지사항
  Widget _buildRecentNotices() {
    final notices = _dashboardData?.notices ?? [];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📢 최근 공지사항',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (notices.isEmpty)
            const Text(
              '등록된 공지사항이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                color: SeoguColors.textSecondary,
              ),
            )
          else
            ...notices.take(3).map((notice) => _buildNoticeItem(notice)).toList(),
        ],
      ),
    );
  }

  /// 공지사항 아이템
  Widget _buildNoticeItem(NoticeInfo notice) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showNoticeDetailDialog(notice),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: SeoguColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 19,
                    color: SeoguColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: SeoguColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(notice.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: SeoguColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빈 데이터 메시지
  Widget _buildEmptyDataMessage() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '데이터가 없습니다.',
          style: TextStyle(
            fontSize: 19,
            color: SeoguColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 가맹률에 따른 색상 반환
  Color _getMembershipRateColor(double rate) {
    if (rate >= 80) return SeoguColors.success;
    if (rate >= 60) return SeoguColors.warning;
    return SeoguColors.error;
  }

  /// 날짜 포맷팅
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}';
    } catch (e) {
      return '';
    }
  }

  /// 공지사항 상세보기 다이얼로그
  void _showNoticeDetailDialog(NoticeInfo notice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SeoguColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SeoguColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.campaign,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '공지사항 상세보기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: SeoguColors.primary,
                              ),
                            ),
                            Text(
                              _formatDetailDate(notice.createdAt),
                              style: const TextStyle(
                                fontSize: 14,
                                color: SeoguColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: SeoguColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 내용
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          notice.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: SeoguColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        // 내용
                        Text(
                          notice.content.isNotEmpty ? notice.content : '내용이 없습니다.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: SeoguColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 하단 버튼
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: SeoguColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 상세 날짜 포맷팅
  String _formatDetailDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return dateString;
    }
  }
}