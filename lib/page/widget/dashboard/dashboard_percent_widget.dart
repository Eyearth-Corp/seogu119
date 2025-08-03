import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_widget.dart';

class DashBoardPercentWidget extends StatefulWidget {
  const DashBoardPercentWidget({super.key, required this.title, required this.data});
  final String title;
  final List<PercentItemData> data;

  @override
  State<DashBoardPercentWidget> createState() => _DashBoardPercentWidgetState();
}

class _DashBoardPercentWidgetState extends State<DashBoardPercentWidget> {
  @override
  Widget build(BuildContext context) {
    
    if (widget.data.isEmpty) {
      return emptyDataMessage();
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
            widget.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.data.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final color = index < colors.length ? colors[index] : SeoguColors.primary;
            return _buildPercentItem(data.name, data.percentage, color);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPercentItem(String dongName, double percentage, Color color) {
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
}