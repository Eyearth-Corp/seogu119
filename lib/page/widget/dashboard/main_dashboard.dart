import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:seogu119/page/widget/dashboard/dashboard_percent_widget.dart';
import 'package:seogu119/page/widget/dashboard/dashboard_type3_widget.dart';
import 'package:seogu119/page/widget/dashboard/dashboard_type4_widget.dart';
import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_bbs1_widget.dart';
import 'dashboard_bbs2_widget.dart';
import 'dashboard_chart_widget.dart';
import 'dashboard_type1_widget.dart';
import 'dashboard_type2_widget.dart';
import 'dashboard_widget.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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

    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: EdgeInsets.all(20),
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
        child: Column(
          children: [
            // 타입 1
            DashBoardType1Widget(
              dashboardId: 1,
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: DashBoardBbs1Widget(
                        dashboardId: 1,
                      )
                  ),
                  SizedBox(width: 20),
                  Expanded(
                      child: DashBoardBbs2Widget(
                        dashboardId: 2,
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DashBoardBbs1Widget(
                      dashboardId: 1,
                    )
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: DashBoardBbs2Widget(
                      dashboardId: 2,
                    )
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            //
            // // 차트
            // DashBoardChartWidget(
            //   dashboardId: 3,
            // ),
            // const SizedBox(height: 20),
            //
            // // 동별 가맹률 현황
            // DashBoardPercentWidget(
            //   dashboardId: 4,
            // ),
            // const SizedBox(height: 20),
        
          ],
        ),
      ),
    );
  }

  /// 빈 데이터 메시지를 표시하는 공통 위젯


  Widget baseView({required Widget child}) {
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
      child: child,
    );
  }

  // 타입 4
  Widget _buildType4(String title, processed, rate) {
    final complaintPerformance = Type4Data(
        title: title,
        processed: processed,
        rate: rate
    );

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
            title,
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

  // // 차트
  // Widget _buildChart(String title) {
  //   final trendChart = ChartData(
  //     title: title,
  //     data: [
  //       ChartDataPoint(
  //         x: 1, y: 10
  //       ),
  //       ChartDataPoint(
  //           x: 2, y: 20
  //       )
  //     ],
  //   );
  //   final chartData = trendChart?.data ?? [];
  //
  //   if (chartData.isEmpty) {
  //     return Container(
  //       height: 200,
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: SeoguColors.surface,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 8,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: const Center(
  //         child: Text(
  //           '차트 데이터가 없습니다.',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: SeoguColors.textSecondary,
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //   return Container(
  //     height: 320,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: SeoguColors.surface,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           trendChart?.title ?? '📈 온누리 가맹점 추이',
  //           style: const TextStyle(
  //             fontSize: 19,
  //             fontWeight: FontWeight.bold,
  //             color: SeoguColors.textPrimary,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Expanded(
  //           child: LineChart(
  //             LineChartData(
  //               gridData: FlGridData(
  //                 show: true,
  //                 drawHorizontalLine: true,
  //                 horizontalInterval: 10,
  //                 getDrawingHorizontalLine: (value) => FlLine(
  //                   color: const Color(0xFFE2E8F0),
  //                   strokeWidth: 1,
  //                 ),
  //                 drawVerticalLine: false,
  //               ),
  //               titlesData: FlTitlesData(
  //                 leftTitles: AxisTitles(
  //                   sideTitles: SideTitles(
  //                     showTitles: true,
  //                     reservedSize: 35,
  //                     getTitlesWidget: (value, meta) => Text(
  //                       '${value.toInt()}%',
  //                       style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
  //                     ),
  //                   ),
  //                 ),
  //                 bottomTitles: AxisTitles(
  //                   sideTitles: SideTitles(
  //                     showTitles: true,
  //                     reservedSize: 25,
  //                     getTitlesWidget: (value, meta) {
  //                       return const Text('');
  //                     },
  //                   ),
  //                 ),
  //                 topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                 rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //               ),
  //               borderData: FlBorderData(show: false),
  //               lineBarsData: [
  //                 LineChartBarData(
  //                   spots: chartData.map((point) => FlSpot(point.x, point.y)).toList(),
  //                   isCurved: true,
  //                   color: SeoguColors.primary,
  //                   barWidth: 3,
  //                   isStrokeCapRound: true,
  //                   dotData: FlDotData(
  //                     show: true,
  //                     getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
  //                       radius: 4,
  //                       color: SeoguColors.primary,
  //                       strokeWidth: 2,
  //                       strokeColor: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // // 퍼센트
  // Widget _buildPercent(String title) {
  //   final dongMembership = PercentData(
  //       title: '퍼센트',
  //       data: [
  //         PercentItemData(
  //             name: '1번', percentage: 10
  //         ),
  //         PercentItemData(
  //             name: '2번', percentage: 20
  //         )
  //       ]
  //   );
  //   final membershipData = dongMembership?.data ?? [];
  //
  //   if (membershipData.isEmpty) {
  //     return emptyDataMessage();
  //   }
  //
  //   final colors = [SeoguColors.secondary, SeoguColors.primary, SeoguColors.accent, SeoguColors.warning, SeoguColors.info];
  //
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: SeoguColors.surface,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontSize: 19,
  //             fontWeight: FontWeight.bold,
  //             color: SeoguColors.textPrimary,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         ...membershipData.asMap().entries.map((entry) {
  //           final index = entry.key;
  //           final data = entry.value;
  //           final color = index < colors.length ? colors[index] : SeoguColors.primary;
  //           return _buildPercentItem(data.name, data.percentage, color);
  //         }).toList(),
  //       ],
  //     ),
  //   );
  // }
  // Widget _buildPercentItem(String dongName, double percentage, Color color) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 8,
  //               height: 8,
  //               decoration: BoxDecoration(
  //                 color: color,
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //             ),
  //             const SizedBox(width: 10),
  //             Container(
  //               width: 120,
  //               child: Text(
  //                 dongName,
  //                 style: const TextStyle(
  //                   fontSize: 19,
  //                   color: Color(0xFF64748B),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Container(
  //                 height: 6,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade200,
  //                   borderRadius: BorderRadius.circular(3),
  //                 ),
  //                 child: FractionallySizedBox(
  //                   alignment: Alignment.centerLeft,
  //                   widthFactor: percentage / 100.0,
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: color,
  //                       borderRadius: BorderRadius.circular(3),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Container(
  //               width: 80,
  //               alignment: Alignment.centerRight,
  //               child: Text(
  //                 '${percentage.toStringAsFixed(1)}%',
  //                 style: const TextStyle(
  //                   fontSize: 19,
  //                   fontWeight: FontWeight.w600,
  //                   color: SeoguColors.textPrimary,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }


}