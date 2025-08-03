import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_widget.dart';

class DashBoardType1Widget extends StatefulWidget {
  const DashBoardType1Widget({super.key, required this.data});
  final List<Type1Data> data;

  @override
  State<DashBoardType1Widget> createState() => _DashBoardType1WidgetState();
}

class _DashBoardType1WidgetState extends State<DashBoardType1Widget> {
  @override
  Widget build(BuildContext context) {

    if (widget.data.isEmpty) {
      return emptyDataMessage();
    }

    final colors = [SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent];

    List<Widget> list = [];
    for (int i = 0; i < widget.data.length; i++) {
      list.add(
          Expanded(
            child: _buildType1Item(
              widget.data[i].title,
              widget.data[i].value,
              widget.data[i].unit,
              i < colors.length ? colors[i] : SeoguColors.primary,
            ),
          )
      );
      if(i < widget.data.length - 1) list.add(const SizedBox(width: 16));
    }

    return Row(
      children: [
        ...list
      ],
    );
  }

  Widget _buildType1Item(String title, String value, String unit, Color color) {
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
}
