import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/dashboard_data.dart';

class DashboardOverviewWidget extends StatefulWidget {
  const DashboardOverviewWidget({super.key});

  @override
  State<DashboardOverviewWidget> createState() => _DashboardOverviewWidgetState();
}

class _DashboardOverviewWidgetState extends State<DashboardOverviewWidget> {
  DashboardData? _dashboardData;
  String _selectedDate = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await DashboardDataManager.loadDataForDate(_selectedDate);
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 선택 드롭다운
          _buildDateSelector(),
          const SizedBox(height: 24),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_dashboardData != null) ...[
            // 통계 카드들
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            
            // 차트 섹션
            Row(
              children: [
                Expanded(child: _buildCategoryChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildCompletionChart()),
              ],
            ),
            const SizedBox(height: 24),
            
            // 지역별 상세 정보
            _buildAreaDetails(),
          ] else
            const Center(child: Text('데이터를 불러올 수 없습니다.')),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final availableDates = DashboardDataManager.getAvailableDates();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '데이터 기준일:',
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedDate,
            items: availableDates.map((date) {
              return DropdownMenuItem(
                value: date.date,
                child: Text(
                  date.displayName,
                  style: GoogleFonts.notoSansKr(),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedDate = value);
                _loadDashboardData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: '총 가맹점 구역',
            value: '${_dashboardData!.totalAreas}개',
            icon: Icons.location_on,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: '총 가맹점 수',
            value: '${_dashboardData!.totalStores.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}개',
            icon: Icons.store,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: '완료율',
            value: '${_dashboardData!.summary.completionRate.toStringAsFixed(1)}%',
            icon: Icons.check_circle,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: '온누리상품권 가맹점',
            value: '${_dashboardData!.onNuriCardRate.toStringAsFixed(1)}%',
            icon: Icons.credit_card,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '업종별 분포',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _dashboardData!.storesByCategory.entries
                    .take(6)
                    .map((entry) {
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.red,
                    Colors.purple,
                    Colors.teal,
                  ];
                  final index = _dashboardData!.storesByCategory.keys.toList().indexOf(entry.key);
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    radius: 60,
                    titleStyle: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildCompletionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '완료 현황',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: _dashboardData!.summary.completionRate,
                    title: '완료\n${_dashboardData!.summary.completionRate.toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.grey.shade300,
                    value: 100 - _dashboardData!.summary.completionRate,
                    title: '미완료\n${(100 - _dashboardData!.summary.completionRate).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
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

  Widget _buildAreaDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지역별 상세 현황',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dashboardData!.areaDetails.length > 10 
                ? 10 
                : _dashboardData!.areaDetails.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final area = _dashboardData!.areaDetails[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text(
                  area.name,
                  style: GoogleFonts.notoSansKr(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  area.category,
                  style: GoogleFonts.notoSansKr(
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: Text(
                  '${area.stores}개',
                  style: GoogleFonts.notoSansKr(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}