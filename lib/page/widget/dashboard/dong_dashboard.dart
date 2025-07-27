import 'package:flutter/material.dart';
import '../../data/dong_list.dart';
import '../../../core/colors.dart';

class DongDashboard extends StatefulWidget {
  final Dong dong;
  final VoidCallback onBackPressed;
  final Function(Merchant) onMerchantSelected;

  const DongDashboard({
    super.key,
    required this.dong,
    required this.onBackPressed,
    required this.onMerchantSelected,
  });

  @override
  State<DongDashboard> createState() => _DongDashboardState();
}

class _DongDashboardState extends State<DongDashboard> {
  @override
  Widget build(BuildContext context) {
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
            // 뒤로가기 헤더
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildDongHeader(),
            ),
            // 빈 화면
            Expanded(
              child: Center(
                child: Text(
                  'API 변경으로 인해 준비 중입니다.',
                  style: TextStyle(
                    fontSize: 18,
                    color: SeoguColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDongHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onBackPressed,
          icon: const Icon(Icons.arrow_back, size: 24),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: widget.dong.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${widget.dong.name} 대시보드',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
      ],
    );
  }
}