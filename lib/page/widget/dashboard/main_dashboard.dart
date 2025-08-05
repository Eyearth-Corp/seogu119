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
import 'dashboard_type5_widget.dart';
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
            // DashBoardType1Widget(
            //   dashboardId: 1,
            // ),
            // const SizedBox(height: 20),

            DashBoardType5Widget(
              dashboardId: 1,
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: DashBoardBbs2Widget(
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
                    child: DashBoardBbs2Widget(
                      dashboardId: 3,
                    )
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: DashBoardBbs2Widget(
                      dashboardId: 4,
                    )
                  ),
                ],
              ),
            ),
            //
            // 차트
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
              fontSize: 23,
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
                        fontSize: 21,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaintPerformance?.processed ?? '0건',
                      style: const TextStyle(
                        fontSize: 25,
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
                        fontSize: 21,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaintPerformance?.rate ?? '0%',
                      style: const TextStyle(
                        fontSize: 25,
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
}