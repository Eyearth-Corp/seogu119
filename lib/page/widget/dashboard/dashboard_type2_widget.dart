import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_widget.dart';

class DashBoardType2Widget extends StatefulWidget {
  const DashBoardType2Widget({super.key, required this.title, required this.data});
  final String title;
  final List<Type2Data> data;

  @override
  State<DashBoardType2Widget> createState() => _DashBoardType2WidgetState();
}

class _DashBoardType2WidgetState extends State<DashBoardType2Widget> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return emptyDataMessage();
    }

    final colors = [SeoguColors.secondary, SeoguColors.primary, SeoguColors.accent];

    List<Widget> list = [];

    for (int i = 0; i < widget.data.length; i++) {
      list.add(
          Expanded(
            child: _buildType2Item(
              widget.data[i].title,
              widget.data[i].value,
              i < colors.length ? colors[i] : SeoguColors.primary,
            ),
          )
      );
      if (i < widget.data.length - 1) list.add(const SizedBox(width: 16));
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
          Text(
            widget.title,
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

  Widget _buildType2Item(String title, String value, Color color) {
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