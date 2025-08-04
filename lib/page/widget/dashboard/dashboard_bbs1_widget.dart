import 'package:flutter/material.dart';

import '../../../core/api_service.dart';
import '../../../core/colors.dart';
import '../../data/main_data_parser.dart';
import 'dashboard_widget.dart';

class DashBoardBbs1Widget extends StatefulWidget {
  const DashBoardBbs1Widget({super.key, required this.dashboardId});
  final int dashboardId;

  @override
  State<DashBoardBbs1Widget> createState() => _DashBoardBbs1WidgetState();
}

class _DashBoardBbs1WidgetState extends State<DashBoardBbs1Widget> {
  Bbs1Response? _response;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiService.getDashBoardBbs1(widget.dashboardId);
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
    
    if (_response == null || _response!.bbs1Data.isEmpty) {
      return emptyDataMessage();
    }

    double height = 88.0 + (42 * _response!.bbs1Data.length);

    return Container(
      height: height,
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
          if (_response!.title.isNotEmpty)
            Text(
              _response!.title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: SeoguColors.textPrimary,
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _response!.bbs1Data.map((caseData) {
                return Container(
                  height: 42,
                  child: _buildBbs1Item(
                    context,
                    caseData.title,
                    caseData.status,
                    caseData.detail,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBbs1Item(BuildContext context, String title, String status, String detail) {
    final isCompleted = status == '해결';
    return InkWell(
      onTap: () => _showBbs1DetailDialog(context, title, status, detail),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted ? SeoguColors.success : SeoguColors.warning,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                color: SeoguColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? SeoguColors.success.withOpacity(0.1)
                  : SeoguColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isCompleted ? SeoguColors.success : SeoguColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBbs1DetailDialog(BuildContext context, String title, String status, String detail) {
    final isCompleted = status == '해결';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEAB308).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.schedule,
                        color: isCompleted ? SeoguColors.success : SeoguColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SeoguColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted 
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFFEAB308).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? SeoguColors.success : SeoguColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                const Text(
                  '상세 내용',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: SeoguColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}