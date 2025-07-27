import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import '../../../services/api_service.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  MainDashboardData? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final apiData = await ApiService.getMainDashboard();
      final data = MainDashboardData.fromMap(apiData);
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
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
              Colors.blue.shade50,
              Colors.indigo.shade100,
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
              Colors.blue.shade50,
              Colors.indigo.shade100,
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
            Colors.blue.shade50,
            Colors.indigo.shade100,
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
              // 상단 메트릭 카드들
              _buildTopMetrics(),
              const SizedBox(height: 20),
              // // 하단 주요 성과
              // _buildWeeklyAchievements(),
              // const SizedBox(height: 20),
              // 온누리 가맹점 추이
              _buildOnNuriTrendChart(),
              const SizedBox(height: 20),
              //동별 가맹률 현황
              _buildDongMembershipStatus(),
              const SizedBox(height: 20),
              // 민원 TOP 3 키워드
              _buildComplaintKeywords(),
              const SizedBox(height: 20),
              // 민원 처리 실적
              // 안보이게 처리
              // _buildComplaintPerformance(),
              // const SizedBox(height: 20),
              _buildComplaintCases(context),
              const SizedBox(height: 20),
              _buildOtherOrganizationTrends(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 빈 데이터 메시지를 표시하는 공통 위젯
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

  /// 상단 메트릭 카드들을 생성합니다.
  /// JSON 데이터에서 로드된 메트릭 정보를 표시합니다.
  Widget _buildTopMetrics() {
    final metrics = _dashboardData?.topMetrics ?? [];
    
    if (metrics.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    final colors = [SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent];

    List<Widget> list = [];
    for (int i = 0; i < metrics.length; i++) {
      list.add(
        Expanded(
          child: _buildMetricCard(
            metrics[i].title,
            metrics[i].value,
            metrics[i].unit,
            i < colors.length ? colors[i] : SeoguColors.primary,
          ),
        )
      );
      if(i < metrics.length - 1) list.add(const SizedBox(width: 16));
    }

    return Row(
      children: [
        ...list
      ],
    );
  }

  /// 개별 메트릭 카드를 생성합니다.
  /// [title]: 카드 제목 (예: '전체 가맹점')  
  /// [value]: 수치 값 (예: '11,426')
  /// [unit]: 단위 (예: '개', '%')
  /// [color]: 강조색 (주로 서구 브랜드 컬러)
  Widget _buildMetricCard(String title, String value, String unit, Color color) {
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
          const SizedBox(height: 10),
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
    );
  }

  // 2. 온누리 가맹점 추이
  Widget _buildOnNuriTrendChart() {
    final trendChart = _dashboardData?.trendChart;
    final chartData = trendChart?.data ?? [];
    
    if (chartData.isEmpty) {
      return Container(
        height: 200,
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
        child: const Center(
          child: Text(
            '차트 데이터가 없습니다.',
            style: TextStyle(
              fontSize: 16,
              color: SeoguColors.textSecondary,
            ),
          ),
        ),
      );
    }
    return Container(
      height: 320,
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
          Text(
            trendChart?.title ?? '📈 온누리 가맹점 추이',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFE2E8F0),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      getTitlesWidget: (value, meta) {
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.map((point) => FlSpot(point.x, point.y)).toList(),
                    isCurved: true,
                    color: SeoguColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: SeoguColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. 동별 가맹률 현황
  Widget _buildDongMembershipStatus() {
    final dongMembership = _dashboardData?.dongMembership;
    final membershipData = dongMembership?.data ?? [];
    
    if (membershipData.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    final colors = [SeoguColors.secondary, SeoguColors.primary, SeoguColors.accent, SeoguColors.warning, SeoguColors.info];
    
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
          Text(
            dongMembership?.title ?? '🗺️ 동별 가맹률 현황',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...membershipData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final color = index < colors.length ? colors[index] : SeoguColors.primary;
            return _buildDongStatusItem(data.name, data.percentage, color);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDongStatusItem(String dongName, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 120,
                child: Text(
                  dongName,
                  style: const TextStyle(
                    fontSize: 19,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 80,
                alignment: Alignment.centerRight,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: SeoguColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. 민원 TOP 3 키워드
  Widget _buildComplaintKeywords() {
    final complaintKeywords = _dashboardData?.complaintKeywords;
    final keywordData = complaintKeywords?.data ?? [];
    
    if (keywordData.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    // 순위별 색상 지정 (1=highlight, 2=warning, 3=primary)
    Color getColorByRank(String rank) {
      switch (rank) {
        case '1':
          return SeoguColors.highlight;
        case '2':
          return SeoguColors.warning;
        case '3':
          return SeoguColors.primary;
        default:
          return SeoguColors.primary;
      }
    }
    
    return Container(
      height: 140,
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
            complaintKeywords?.title ?? '🔥 민원 TOP 3 키워드',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: keywordData.map((data) {
                return _buildKeywordItem(
                  data.rank,
                  data.keyword,
                  data.count,
                  getColorByRank(data.rank),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordItem(String rank, String keyword, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    rank,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SeoguColors.surface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                keyword,
                style: const TextStyle(
                  fontSize: 16,
                  color: SeoguColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count건',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // 5. 민원 해결 사례
  /// 민원 해결 사례 섹션을 생성합니다.
  /// 터치 가능한 사례 목록을 표시하며, 각 항목을 터치하면 상세 정보 다이얼로그가 표시됩니다.
  /// [context]: 다이얼로그 표시를 위한 BuildContext
  Widget _buildComplaintCases(BuildContext context) {
    final complaintCases = _dashboardData?.complaintCases;
    final casesData = complaintCases?.data ?? [];
    
    if (casesData.isEmpty) {
      return _buildEmptyDataMessage();
    }

    double height = 88.0 + (42 * casesData.length);

    return Container(
      height: height,
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
          Text(
            complaintCases?.title ?? '✅ 민원 해결 사례',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: casesData.map((caseData) {
                return Container(
                  height: 42,
                  child: _buildCaseItem(
                    context,
                    caseData.title,
                    caseData.status,
                    caseData.detail,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseItem(BuildContext context, String title, String status, String detail) {
    final isCompleted = status == '해결';
    return InkWell(
      onTap: () => _showComplaintDetailDialog(context, title, status, detail),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted ? SeoguColors.success : SeoguColors.warning,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                color: SeoguColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? SeoguColors.success.withOpacity(0.1)
                  : SeoguColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isCompleted ? SeoguColors.success : SeoguColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 민원 사례 상세 정보 다이얼로그를 표시합니다.
  /// [context]: 다이얼로그를 표시할 BuildContext
  /// [title]: 민원 사례 제목
  /// [status]: 처리 상태 ('해결' 또는 '진행중')
  /// [detail]: 상세 설명 내용
  void _showComplaintDetailDialog(BuildContext context, String title, String status, String detail) {
    final isCompleted = status == '해결';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEAB308).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.schedule,
                        color: isCompleted ? SeoguColors.success : SeoguColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SeoguColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted 
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFFEAB308).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? SeoguColors.success : SeoguColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                const Text(
                  '상세 내용',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 16,
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
                          fontSize: 14,
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

  /// 타 기관 동향 상세 정보 다이얼로그를 표시합니다.
  /// [context]: 다이얼로그를 표시할 BuildContext
  /// [title]: 동향 제목
  /// [detail]: 상세 설명 내용
  void _showTrendDetailDialog(BuildContext context, String title, String detail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SeoguColors.info.withOpacity(0.1),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: SeoguColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                const Text(
                  '상세 내용',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 16,
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
                          fontSize: 14,
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

  // 6. 민원처리 실적
  Widget _buildComplaintPerformance() {
    final complaintPerformance = _dashboardData?.complaintPerformance;

    return Container(
      height: 160,
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
          Text(
            complaintPerformance?.title ?? '📋 민원처리 실적',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '처리됨',
                      style: TextStyle(
                        fontSize: 19,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaintPerformance?.processed ?? '0건',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: SeoguColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE2E8F0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '처리율',
                      style: TextStyle(
                        fontSize: 19,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaintPerformance?.rate ?? '0%',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: SeoguColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 7. 타 기관·지자체 주요 동향
  Widget _buildOtherOrganizationTrends(BuildContext context) {
    final organizationTrends = _dashboardData?.organizationTrends;
    final trendsData = organizationTrends?.data ?? [];
    
    if (trendsData.isEmpty) {
      return _buildEmptyDataMessage();
    }

    double height = 88.0 + (42 * trendsData.length);
    return Container(
      height: height,
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
          Text(
            organizationTrends?.title ?? '🌐 타 기관·지자체 주요 동향',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: trendsData.map((trendData) {
              return SizedBox(
                height: 42,
                child: _buildTrendItem(
                  context,
                  trendData.title,
                  trendData.detail,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(BuildContext context, String title, String detail) {
    return InkWell(
      onTap: () => _showTrendDetailDialog(context, title, detail),
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
              style: const TextStyle(
                fontSize: 19,
                color: SeoguColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 8. 금주 주요 성과
  Widget _buildWeeklyAchievements() {
    final achievements = _dashboardData?.weeklyAchievements ?? [];
    
    if (achievements.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    final colors = [SeoguColors.secondary, SeoguColors.primary, SeoguColors.accent];

    List<Widget> list = [];

    for (int i = 0; i < achievements.length; i++) {
      list.add(
        Expanded(
          child: _buildAchievementCard(
            achievements[i].title,
            achievements[i].value,
            i < colors.length ? colors[i] : SeoguColors.primary,
          ),
        )
      );
      if (i < achievements.length - 1) list.add(const SizedBox(width: 16));
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
            '🎯 금주 주요 성과',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...list
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}