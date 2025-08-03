import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/admin_service.dart';
import '../data/dong_list.dart';
import '../../core/colors.dart';

class NewAdminDashboardPage extends StatefulWidget {
  const NewAdminDashboardPage({super.key});

  @override
  State<NewAdminDashboardPage> createState() => _NewAdminDashboardPageState();
}

class _NewAdminDashboardPageState extends State<NewAdminDashboardPage> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Load all dashboard data from multiple API endpoints
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load data from multiple API endpoints
      final summaryResponse = await AdminService.fetchFromURL(
          '${AdminService.baseUrl}/api/admin/dashboard/summary');
      final statsResponse = await AdminService.fetchFromURL(
          '${AdminService.baseUrl}/api/admin/dashboard/statistics');

      if (summaryResponse != null && statsResponse != null) {
        setState(() {
          _dashboardData = {
            'summary': summaryResponse['data'],
            'statistics': statsResponse['data'],
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API 호출 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // 동별 관리 대시보드 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.location_city, color: SeoguColors.primary),
            tooltip: '동별 대시보드',
            onSelected: (dongName) {
              Navigator.pushNamed(context, '/admin/dong/$dongName');
            },
            itemBuilder: (context) => DongList.all.map((dong) =>
                PopupMenuItem<String>(
                  value: dong.name,
                  child: Text(dong.name),
                )).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
              ? const Center(child: Text('데이터가 없습니다'))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 동 목록 Wrap 위젯
                          _buildDistrictList(),
                          const SizedBox(height: 20),
                          _buildSummaryMetrics(),
                          const SizedBox(height: 20),
                          _buildGlobalMetrics(),
                          const SizedBox(height: 20),
                          _buildTrendChart(),
                          const SizedBox(height: 20),
                          _buildLivingZones(),
                          const SizedBox(height: 20),
                          _buildRecentActivity(),
                          const SizedBox(height: 80), // 버튼 공간 확보
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton.extended(
                        onPressed: _loadDashboardData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('새로고침'),
                        backgroundColor: SeoguColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDistrictList() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
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
            '🗺️ 동별 관리 대시보드',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DongList.all.map((dong) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/admin/dong/${dong.name}');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: dong.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: dong.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dong.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dong.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: SeoguColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    final summary = _dashboardData?['summary']?['summary'] as Map<String, dynamic>? ?? {};
    
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
            '📊 주요 통계',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(
                '생활권',
                summary['total_living_zones']?.toString() ?? '0',
                '개',
                SeoguColors.primary,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                '행정동',
                summary['total_districts']?.toString() ?? '0',
                '개',
                SeoguColors.secondary,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                '상인회',
                summary['total_merchants']?.toString() ?? '0',
                '개',
                SeoguColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(
                '총 점포',
                summary['total_stores']?.toString() ?? '0',
                '개',
                SeoguColors.primary,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                '가맹점포',
                summary['total_member_stores']?.toString() ?? '0',
                '개',
                SeoguColors.secondary,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                '전체 가맹률',
                '${summary['overall_membership_rate']?.toString() ?? '0'}',
                '%',
                SeoguColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SeoguColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SeoguColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalMetrics() {
    final metrics = _dashboardData?['statistics']?['global_metrics'] as List<dynamic>? ?? [];
    
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
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
            '📈 글로벌 메트릭',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: metrics.map((metric) {
              return _buildGlobalMetricItem(
                metric['title'] ?? '',
                metric['value'] ?? '',
                metric['unit'] ?? '',
                SeoguColors.chart1,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalMetricItem(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SeoguColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: SeoguColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    final trends = _dashboardData?['statistics']?['recent_trends'] as List<dynamic>? ?? [];
    
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert trend data to chart spots
    final chartData = trends.reversed.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;
      return FlSpot(
        index.toDouble(),
        double.tryParse(trend['value'].toString()) ?? 0.0,
      );
    }).toList();

    return Container(
      height: 360,
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
            '📈 최근 트렌드',
            style: TextStyle(
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
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < trends.length) {
                          final trend = trends.reversed.toList()[index];
                          return Text(
                            trend['period_label'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          );
                        }
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
                    spots: chartData,
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

  Widget _buildLivingZones() {
    final zones = _dashboardData?['statistics']?['living_zones'] as List<dynamic>? ?? [];
    
    if (zones.isEmpty) {
      return const SizedBox.shrink();
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
            '🏘️ 생활권별 현황',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: zones.map((zone) {
              return _buildLivingZoneItem(
                zone['zone_name'] ?? '',
                zone['merchant_count'] ?? 0,
                zone['total_stores'] ?? 0,
                zone['member_stores'] ?? 0,
                (zone['membership_rate'] ?? 0.0).toDouble(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLivingZoneItem(String zoneName, int merchantCount, int totalStores, 
      int memberStores, double membershipRate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SeoguColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  zoneName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: SeoguColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${membershipRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: membershipRate > 80 
                      ? SeoguColors.success 
                      : membershipRate > 60 
                          ? SeoguColors.warning 
                          : SeoguColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildZoneMetric('상인회', merchantCount.toString(), SeoguColors.primary),
              const SizedBox(width: 16),
              _buildZoneMetric('총 점포', totalStores.toString(), SeoguColors.secondary),
              const SizedBox(width: 16),
              _buildZoneMetric('가맹점포', memberStores.toString(), SeoguColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: SeoguColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final summary = _dashboardData?['summary']?['summary'] as Map<String, dynamic>? ?? {};
    
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
            '🕒 최근 활동',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.notifications, color: SeoguColors.primary),
            title: const Text('최근 7일간 생성된 공지사항'),
            subtitle: Text('${summary['recent_notices'] ?? 0}건'),
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: SeoguColors.secondary),
            title: const Text('최근 7일간 생활권 공지사항'),
            subtitle: Text('${summary['recent_zone_notices'] ?? 0}건'),
          ),
          ListTile(
            leading: const Icon(Icons.login, color: SeoguColors.accent),
            title: const Text('최근 24시간 로그인한 관리자'),
            subtitle: Text('${summary['recent_active_admins'] ?? 0}명'),
          ),
        ],
      ),
    );
  }
}