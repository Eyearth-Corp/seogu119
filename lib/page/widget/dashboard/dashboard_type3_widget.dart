import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_widget.dart';

class DashBoardType3Widget extends StatefulWidget {
  const DashBoardType3Widget({super.key, required this.title, required this.data});
  final String title;
  final List<Type3ItemData> data;

  @override
  State<DashBoardType3Widget> createState() => _DashBoardType3WidgetState();
}

class _DashBoardType3WidgetState extends State<DashBoardType3Widget> {
  @override
  Widget build(BuildContext context) {

    if (widget.data.isEmpty) {
      return emptyDataMessage();
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
      height: 160,
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
            widget.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: widget.data.map((data) {
                return _buildType3Item(
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

  Widget _buildType3Item(String rank, String keyword, int count, Color color) {
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
}