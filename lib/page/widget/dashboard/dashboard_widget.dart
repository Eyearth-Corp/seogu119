import 'package:flutter/material.dart';

import '../../../core/colors.dart';


Widget emptyDataMessage() {
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