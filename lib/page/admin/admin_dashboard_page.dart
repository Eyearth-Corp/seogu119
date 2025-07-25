import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/admin_service.dart';
import '../../core/colors.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  List<String> _availableDates = [];
  String? _selectedDate;
  
  // 편집 가능한 필드들을 위한 로컬 상태
  final Map<String, dynamic> _editedData = {};

  @override
  void initState() {
    super.initState();
    _loadMainDashboardFromAPI();
  }

  /// 메인 대시보드 API 호출
  Future<void> _loadMainDashboardFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminService.getMainDashboard();
      
      if (response != null) {
        // availableDates 설정
        if (response['availableDates'] != null) {
          final dateList = List<String>.from(response['availableDates']);
          setState(() {
            _availableDates = dateList;
            if (dateList.isNotEmpty && _selectedDate == null) {
              _selectedDate = dateList.first;
            }
          });
        }
        
        // data 설정
        if (response['data'] != null) {
          setState(() {
            _dashboardData = response['data'];
            _initializeEditedData();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API 호출 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 편집 데이터 초기화
  void _initializeEditedData() {
    _editedData.clear();
    if (_dashboardData != null) {
      _editedData.addAll(_dashboardData!);
    }
  }

  /// 특정 날짜의 대시보드 데이터 로드
  Future<void> _loadDashboardData(String date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminService.getMainDashboardByDate(date);
      
      if (response != null && response['data'] != null) {
        setState(() {
          _dashboardData = response['data'];
          _initializeEditedData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 필드 편집 다이얼로그
  Future<void> _showEditDialog(String key, String title, dynamic currentValue) async {
    final controller = TextEditingController(text: currentValue?.toString() ?? '');
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '값을 입력하세요',
          ),
          keyboardType: _isNumericField(key) ? TextInputType.number : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('확인'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
            ),
          ),
        ],
      ),
    );

    if (result != null && result != currentValue?.toString()) {
      setState(() {
        _updateNestedValue(key, _parseValue(result));
      });
    }
  }

  /// 중첩된 키 값 업데이트
  void _updateNestedValue(String key, dynamic value) {
    if (key.contains('.')) {
      final parts = key.split('.');
      Map<String, dynamic> current = _editedData;
      
      for (int i = 0; i < parts.length - 1; i++) {
        if (current[parts[i]] == null) {
          current[parts[i]] = {};
        }
        current = current[parts[i]] as Map<String, dynamic>;
      }
      
      current[parts.last] = value;
    } else {
      _editedData[key] = value;
    }
  }

  /// 중첩된 키 값 가져오기
  dynamic _getNestedValue(String key) {
    if (key.contains('.')) {
      final parts = key.split('.');
      dynamic current = _editedData;
      
      for (final part in parts) {
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          return null;
        }
      }
      
      return current;
    } else {
      return _editedData[key];
    }
  }

  /// 문자열 값을 적절한 타입으로 변환
  dynamic _parseValue(String value) {
    if (value.isEmpty) return null;
    
    if (double.tryParse(value) != null) {
      final doubleValue = double.parse(value);
      if (doubleValue == doubleValue.toInt()) {
        return doubleValue.toInt();
      }
      return doubleValue;
    }
    
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    
    return value;
  }

  /// 숫자 필드 여부 확인
  bool _isNumericField(String key) {
    final numericFields = {
      'total_merchants', 'new_merchants_this_week', 'membership_rate',
      'processed', 'process_rate', 'count', 'percentage', 'value', 'x', 'y'
    };
    
    return numericFields.any((field) => key.contains(field));
  }

  /// PUT API 미리보기 다이얼로그
  Future<void> _showApiPreviewDialog() async {
    final jsonData = _editedData;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PUT API 미리보기'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Endpoint:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('PUT /api/main-dashboard/$_selectedDate'),
              const SizedBox(height: 16),
              const Text(
                'Request Body:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _formatJson(jsonData),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveData();
            },
            child: const Text('전송'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// JSON 포맷팅
  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// 데이터 저장
  Future<void> _saveData() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AdminService.updateMainDashboard(_selectedDate!, _editedData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '데이터가 성공적으로 저장되었습니다.' : '데이터 저장에 실패했습니다.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          await _loadDashboardData(_selectedDate!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmationDialog(String itemName, VoidCallback onConfirm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('정말로 "$itemName"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (result == true) {
      onConfirm();
    }
  }

  /// 메트릭 삭제
  void _deleteMetric(int index) {
    setState(() {
      final metrics = List<dynamic>.from(_editedData['topMetrics'] as List<dynamic>? ?? []);
      if (index >= 0 && index < metrics.length) {
        metrics.removeAt(index);
        _editedData['topMetrics'] = metrics;
      }
    });
  }

  /// 새로운 메트릭 추가
  Future<void> _addNewMetric() async {
    final titleController = TextEditingController();
    final valueController = TextEditingController();
    final unitController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 메트릭 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '예: 🏪 전체 가맹점',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: '값',
                hintText: '예: 11,426',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: '단위',
                hintText: '예: 개, %',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
            ),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty && valueController.text.isNotEmpty) {
      setState(() {
        final topMetrics = _editedData['topMetrics'] as List<dynamic>? ?? [];
        topMetrics.add({
          'title': titleController.text,
          'value': valueController.text,
          'unit': unitController.text,
        });
        _editedData['topMetrics'] = topMetrics;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (_availableDates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: DropdownButton<String>(
                value: _selectedDate,
                items: _availableDates.map((date) => 
                  DropdownMenuItem(
                    value: date,
                    child: Text(date),
                  ),
                ).toList(),
                onChanged: (date) {
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _loadDashboardData(date);
                  }
                },
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _editedData.isEmpty
              ? const Center(child: Text('데이터가 없습니다'))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildTopMetrics(),
                          const SizedBox(height: 20),
                          _buildWeeklyAchievements(),
                          const SizedBox(height: 20),
                          _buildOnNuriTrendChart(),
                          const SizedBox(height: 20),
                          _buildDongMembershipStatus(),
                          const SizedBox(height: 20),
                          _buildComplaintKeywords(),
                          const SizedBox(height: 20),
                          _buildComplaintPerformance(),
                          const SizedBox(height: 20),
                          _buildComplaintCases(),
                          const SizedBox(height: 20),
                          _buildOtherOrganizationTrends(),
                          const SizedBox(height: 80), // 버튼 공간 확보
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: ElevatedButton.icon(
                        onPressed: _showApiPreviewDialog,
                        icon: const Icon(Icons.preview),
                        label: const Text('PUT API 미리보기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SeoguColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTopMetrics() {
    final metrics = _editedData['topMetrics'] as List<dynamic>? ?? [];
    
    return Row(
      children: [
        ...metrics.map((metric) {
          final index = metrics.indexOf(metric);
          return Expanded(
            child: _buildEditableMetricCard(
              metric['title'] ?? '',
              metric['value']?.toString() ?? '',
              metric['unit'] ?? '',
              [SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent][index % 3],
              'topMetrics.$index.value',
            ),
          );
        }).toList(),
        const SizedBox(width: 16),
        SizedBox(
          width: 60,
          height: 94,
          child: ElevatedButton(
            onPressed: _addNewMetric,
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableMetricCard(String title, String value, String unit, Color color, String editKey) {
    // editKey를 파싱하여 인덱스 추출
    final keyParts = editKey.split('.');
    final index = int.tryParse(keyParts[1]) ?? 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  color: SeoguColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red.shade400,
                onPressed: () => _showDeleteConfirmationDialog(
                  title,
                  () => _deleteMetric(index),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showEditDialog(editKey, title, value),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                    decoration: TextDecoration.underline,
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
          ),
        ],
      ),
    );
  }

  Widget _buildOnNuriTrendChart() {
    final trendData = _editedData['trendChart'] as Map<String, dynamic>? ?? {};
    final chartData = (trendData['data'] as List<dynamic>? ?? [])
        .map((item) => FlSpot(
              (item['x'] ?? 0).toDouble(),
              (item['y'] ?? 0).toDouble(),
            ))
        .toList();

    return Container(
      height: 200,
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
            trendData['title'] ?? '📈 온누리 가맹점 추이',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFE2E8F0),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 70,
                maxY: 90,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: SeoguColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: SeoguColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDongMembershipStatus() {
    final dongData = _editedData['dongMembership'] as Map<String, dynamic>? ?? {};
    final items = (dongData['data'] as List<dynamic>? ?? []);

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
            dongData['title'] ?? '🗺️ 동별 가맹률 현황',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildEditableDongStatusItem(
              item['name'] ?? '',
              (item['percentage'] ?? 0).toDouble(),
              [SeoguColors.secondary, SeoguColors.primary, SeoguColors.accent][index % 3],
              'dongMembership.data.$index.percentage',
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEditableDongStatusItem(String dongName, double percentage, Color color, String editKey) {
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
                width: 100,
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
              InkWell(
                onTap: () => _showEditDialog(editKey, '$dongName 가맹률', percentage),
                child: Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: SeoguColors.textPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintKeywords() {
    final keywordData = _editedData['complaintKeywords'] as Map<String, dynamic>? ?? {};
    final keywords = (keywordData['data'] as List<dynamic>? ?? []);

    return Container(
      height: 140,
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
            keywordData['title'] ?? '🔥 민원 TOP 3 키워드',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: keywords.asMap().entries.map((entry) {
                final index = entry.key;
                final keyword = entry.value;
                return _buildEditableKeywordItem(
                  keyword['rank']?.toString() ?? '${index + 1}',
                  keyword['keyword'] ?? '',
                  keyword['count'] ?? 0,
                  [SeoguColors.highlight, SeoguColors.warning, SeoguColors.primary][index % 3],
                  'complaintKeywords.data.$index',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableKeywordItem(String rank, String keyword, int count, Color color, String editKeyPrefix) {
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
              InkWell(
                onTap: () => _showEditDialog('$editKeyPrefix.keyword', '키워드', keyword),
                child: Text(
                  keyword,
                  style: const TextStyle(
                    fontSize: 16,
                    color: SeoguColors.textPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _showEditDialog('$editKeyPrefix.count', '건수', count),
            child: Text(
              '$count건',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCases() {
    final casesData = _editedData['complaintCases'] as Map<String, dynamic>? ?? {};
    final cases = (casesData['data'] as List<dynamic>? ?? []);

    return Container(
      height: 170,
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
            casesData['title'] ?? '✅ 민원 해결 사례',
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
              children: cases.asMap().entries.map((entry) {
                final index = entry.key;
                final caseItem = entry.value;
                return _buildEditableCaseItem(
                  caseItem['title'] ?? '',
                  caseItem['status'] ?? '',
                  caseItem['detail'] ?? '',
                  'complaintCases.data.$index',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCaseItem(String title, String status, String detail, String editKeyPrefix) {
    final isCompleted = status == '해결';
    return Expanded(
      child: InkWell(
        onTap: () => _showEditDialog('$editKeyPrefix.title', '사례 제목', title),
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
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => _showEditDialog('$editKeyPrefix.status', '상태', status),
              child: Container(
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
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintPerformance() {
    final perfData = _editedData['complaintPerformance'] as Map<String, dynamic>? ?? {};
    
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
            perfData['title'] ?? '📋 민원처리 실적',
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
                    InkWell(
                      onTap: () => _showEditDialog('complaintPerformance.processed', '처리된 민원', perfData['processed']),
                      child: Text(
                        perfData['processed']?.toString() ?? '187건',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: SeoguColors.success,
                          decoration: TextDecoration.underline,
                        ),
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
                    InkWell(
                      onTap: () => _showEditDialog('complaintPerformance.rate', '처리율', perfData['rate']),
                      child: Text(
                        perfData['rate']?.toString() ?? '94.2%',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: SeoguColors.info,
                          decoration: TextDecoration.underline,
                        ),
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

  Widget _buildOtherOrganizationTrends() {
    final trendsData = _editedData['organizationTrends'] as Map<String, dynamic>? ?? {};
    final trends = (trendsData['data'] as List<dynamic>? ?? []);

    return Container(
      height: 140,
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
            trendsData['title'] ?? '🌐 타 기관·지자체 주요 동향',
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
              children: trends.asMap().entries.map((entry) {
                final index = entry.key;
                final trend = entry.value;
                return _buildEditableTrendItem(
                  trend['title'] ?? '',
                  trend['detail'] ?? '',
                  'organizationTrends.data.$index',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTrendItem(String title, String detail, String editKeyPrefix) {
    return Expanded(
      child: InkWell(
        onTap: () => _showEditDialog('$editKeyPrefix.title', '동향 제목', title),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF64748B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  color: SeoguColors.textPrimary,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyAchievements() {
    final achievements = (_editedData['weeklyAchievements'] as List<dynamic>? ?? []);
    
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
          const Text(
            '🎯 금주 주요 성과',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: achievements.asMap().entries.map((entry) {
              final index = entry.key;
              final achievement = entry.value;
              return Expanded(
                child: _buildEditableAchievementCard(
                  achievement['title'] ?? '',
                  achievement['value']?.toString() ?? '',
                  [SeoguColors.secondary, SeoguColors.primary, SeoguColors.accent][index % 3],
                  'weeklyAchievements.$index.value',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableAchievementCard(String title, String value, Color color, String editKey) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          InkWell(
            onTap: () => _showEditDialog(editKey, title, value),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: color,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}