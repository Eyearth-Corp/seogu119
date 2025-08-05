import 'package:flutter/material.dart';

import '../../../core/api_service.dart';
import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_widget.dart';

class DashBoardType5Widget extends StatefulWidget {
  const DashBoardType5Widget({super.key, required this.dashboardId});
  final int dashboardId;

  @override
  State<DashBoardType5Widget> createState() => _DashBoardType5WidgetState();
}

class _DashBoardType5WidgetState extends State<DashBoardType5Widget> {
  Type5Response? _response;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiService.getDashBoardType5(widget.dashboardId);
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
      return Container(
        height: 180,
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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        height: 180,
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

    if (_response == null || _response!.type5Data.isEmpty) {
      return emptyDataMessage();
    }

    return Row(
      children: _response!.type5Data.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        
        // 블루 그라데이션 색상 배열 (왼쪽에서 오른쪽으로 갈수록 진해짐)
        // final gradientColors = [
        //   [const Color(0xFF93C5FD), const Color(0xFF60A5FA)], // 가장 밝은 파랑
        //   [const Color(0xFF60A5FA), const Color(0xFF3B82F6)], // 밝은 파랑
        //   [const Color(0xFF3B82F6), const Color(0xFF2563EB)], // 중밝은 파랑
        //   [const Color(0xFF2563EB), const Color(0xFF1D4ED8)], // 중간 파랑
        //   [const Color(0xFF1D4ED8), const Color(0xFF1E40AF)], // 중진한 파랑
        //   [const Color(0xFF1E40AF), const Color(0xFF1E3A8A)], // 진한 파랑
        //   [const Color(0xFF1E3A8A), const Color(0xFF172554)], // 더 진한 파랑
        //   [const Color(0xFF172554), const Color(0xFF0F172A)], // 매우 진한 파랑
        //   [const Color(0xFF0F172A), const Color(0xFF020617)], // 거의 검은색에 가까운 파랑
        //   [const Color(0xFF020617), const Color(0xFF000000)], // 가장 진한 색상
        // ];

        final gradientColors = [
          //[const Color(0xAAA5C952), const Color(0xFF89C34B)], // 밝은 초록 → 연초록
          [const Color(0xFFc5e89f), const Color(0xFF5DAE4F)], // 연초록 → 중간 초록
          //[const Color(0xAA5DAE4F), const Color(0xFF3A8D74)], // 중초록 → 청록
          [const Color(0xFF86d0ba), const Color(0xFF2A7AB3)], // 청록 → 하늘파랑
          //[const Color(0xAA2A7AB3), const Color(0xFF2767C9)], // 하늘파랑 → 진한파랑
          [const Color(0xFF70a0eb), const Color(0xFF1D4DB5)], // 진한파랑 → 짙은파랑
          //[const Color(0xAA1D4DB5), const Color(0xFF1A3D8F)], // 짙은파랑 → 남색
          [const Color(0xFF5377ca), const Color(0xFF162F6D)], // 남색 → 어두운 남색
          //[const Color(0xFF162F6D), const Color(0xFF111F47)], // 어두운 남색 → 거의 검정
          [const Color(0xFF445a9a), const Color(0xFF0B122D)], // 거의 검정 → 검정 파랑
        ];


        final colors = gradientColors[index % gradientColors.length];
        
        return Expanded(
          child: Container(
            height: 220,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 배경 패턴
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 80,
                    height: 80,
                    child: Text(
                      data.emoji,
                      style: const TextStyle(fontSize: 42, color: Colors.white),
                    ),

                  ),
                ),
                // 메인 컨텐츠
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 80),
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFd2ffe9),
                        wordSpacing: 2.0,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 내용
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          data.content1,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Text(
                            data.content2,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}