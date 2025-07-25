import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/admin_service.dart';
import '../data/dong_list.dart';
import '../../core/colors.dart';

class DongAdminDashboardPage extends StatefulWidget {
  final String dongName;
  
  const DongAdminDashboardPage({super.key, required this.dongName});

  @override
  State<DongAdminDashboardPage> createState() => _DongAdminDashboardPageState();
}

class _DongAdminDashboardPageState extends State<DongAdminDashboardPage> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  List<String> _availableDates = [];
  String? _selectedDate;
  Dong? _selectedDong;
  
  // 편집 가능한 필드들을 위한 로컬 상태
  final Map<String, dynamic> _editedData = {};

  @override
  void initState() {
    super.initState();
    _findSelectedDong();
    _loadDongDashboardFromAPI();
  }

  /// 선택된 동 찾기
  void _findSelectedDong() {
    _selectedDong = DongList.all.firstWhere(
      (dong) => dong.name == widget.dongName,
      orElse: () => DongList.all.first,
    );
  }

  /// 동별 대시보드 API 호출
  Future<void> _loadDongDashboardFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminService.getDongDashboardByDate(widget.dongName, '2025-07-25');
      
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

  /// 특정 날짜의 동별 대시보드 데이터 로드
  Future<void> _loadDashboardData(String date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminService.getDongDashboardByDate(widget.dongName, date);
      
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
          current[parts[i]] = <String, dynamic>{};
        }
        if (current[parts[i]] is! Map<String, dynamic>) {
          current[parts[i]] = <String, dynamic>{};
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

  /// 저장 확인 다이얼로그
  Future<void> _showSaveConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 저장'),
        content: Text('${widget.dongName} 변경사항을 저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveData();
    }
  }

  /// 데이터 저장
  Future<void> _saveData() async {
    // 날짜를 '2025-07-25'로 고정
    const fixedDate = '2025-07-25';

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AdminService.updateDongDashboard(widget.dongName, fixedDate, _editedData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '${widget.dongName} 데이터가 성공적으로 저장되었습니다.' : '데이터 저장에 실패했습니다.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          await _loadDashboardData(_selectedDate ?? fixedDate);
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

  /// 상인회 삭제
  void _deleteMerchant(int index) {
    setState(() {
      final merchants = List<dynamic>.from(_editedData['merchants'] as List<dynamic>? ?? []);
      if (index >= 0 && index < merchants.length) {
        merchants.removeAt(index);
        _editedData['merchants'] = merchants;
      }
    });
  }

  /// 새로운 상인회 추가
  Future<void> _addNewMerchant() async {
    final nameController = TextEditingController();
    final xController = TextEditingController();
    final yController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 상인회 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '상인회 이름',
                hintText: '예: 동천동상인회',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: xController,
              decoration: const InputDecoration(
                labelText: 'X 좌표',
                hintText: '예: 360',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: yController,
              decoration: const InputDecoration(
                labelText: 'Y 좌표',
                hintText: '예: 257',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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

    if (result == true && nameController.text.isNotEmpty) {
      setState(() {
        final merchants = _editedData['merchants'] as List<dynamic>? ?? [];
        final nextId = merchants.isNotEmpty 
          ? (merchants.map((m) => m['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b)) + 1
          : 1;
        
        merchants.add({
          'id': nextId,
          'name': nameController.text,
          'x': double.tryParse(xController.text) ?? 0,
          'y': double.tryParse(yController.text) ?? 0,
        });
        _editedData['merchants'] = merchants;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dongName} 관리자 대시보드'),
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
                          _buildDongHeader(),
                          const SizedBox(height: 20),
                          _buildDongMetrics(),
                          const SizedBox(height: 20),
                          _buildMerchantsList(),
                          const SizedBox(height: 20),
                          _buildDongComplaints(),
                          const SizedBox(height: 20),
                          _buildDongAchievements(),
                          const SizedBox(height: 80), // 버튼 공간 확보
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: ElevatedButton.icon(
                        onPressed: _showSaveConfirmDialog,
                        icon: const Icon(Icons.save),
                        label: const Text('저장하기'),
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

  Widget _buildDongHeader() {
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
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _selectedDong?.color ?? SeoguColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${widget.dongName} 관리',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '총 ${_selectedDong?.merchantList.length ?? 0}개 상인회',
            style: const TextStyle(
              fontSize: 16,
              color: SeoguColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDongMetrics() {
    final metrics = _editedData['metrics'] as List<dynamic>? ?? [];
    
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
            '📊 동별 주요 지표',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEditableMetricCard(
                  '🏪 총 상인회',
                  _getNestedValue('total_merchants')?.toString() ?? (_selectedDong?.merchantList.length ?? 0).toString(),
                  '개',
                  _selectedDong?.color ?? SeoguColors.primary,
                  'total_merchants',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEditableMetricCard(
                  '✨ 가맹률',
                  _getNestedValue('membership_rate')?.toString() ?? '85.0',
                  '%',
                  SeoguColors.success,
                  'membership_rate',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEditableMetricCard(
                  '📊 이번주 방문',
                  _getNestedValue('weekly_visits')?.toString() ?? '12',
                  '회',
                  SeoguColors.warning,
                  'weekly_visits',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableMetricCard(String title, String value, String unit, Color color, String editKey) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: SeoguColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
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
                    fontSize: 24,
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
                      fontSize: 14,
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

  Widget _buildMerchantsList() {
    final merchants = _selectedDong?.merchantList ?? [];
    
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
          Row(
            children: [
              const Text(
                '🏪 상인회 목록',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: SeoguColors.primary,
                onPressed: _addNewMerchant,
                tooltip: '상인회 추가',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...merchants.asMap().entries.map((entry) {
            final index = entry.key;
            final merchant = entry.value;
            return _buildMerchantItem(merchant, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMerchantItem(Merchant merchant, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (_selectedDong?.color ?? SeoguColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (_selectedDong?.color ?? SeoguColors.primary).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedDong?.color ?? SeoguColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                merchant.id.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: SeoguColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '좌표: (${merchant.x.toInt()}, ${merchant.y.toInt()})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: SeoguColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red.shade400,
            onPressed: () => _showDeleteConfirmationDialog(
              merchant.name,
              () => _deleteMerchant(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDongComplaints() {
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
            '🔥 ${widget.dongName} 민원 현황',
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
                child: _buildComplaintItem(
                  '주차 문제',
                  _getNestedValue('complaints.parking')?.toString() ?? '5',
                  SeoguColors.highlight,
                  'complaints.parking',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplaintItem(
                  '소음 방해',
                  _getNestedValue('complaints.noise')?.toString() ?? '3',
                  SeoguColors.warning,
                  'complaints.noise',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplaintItem(
                  '청소 문제',
                  _getNestedValue('complaints.cleaning')?.toString() ?? '2',
                  SeoguColors.primary,
                  'complaints.cleaning',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintItem(String title, String count, Color color, String editKey) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: SeoguColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showEditDialog(editKey, title, count),
          child: Text(
            '${count}건',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDongAchievements() {
    final achievements = _editedData['achievements'] as List<dynamic>? ?? [];
    
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
            '🎯 ${widget.dongName} 금주 성과',
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
                child: _buildAchievementCard(
                  '신규 가맹',
                  _getNestedValue('achievements.new_merchants')?.toString() ?? '2개',
                  _selectedDong?.color ?? SeoguColors.primary,
                  'achievements.new_merchants',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAchievementCard(
                  '민원 해결',
                  _getNestedValue('achievements.resolved_complaints')?.toString() ?? '1건',
                  SeoguColors.success,
                  'achievements.resolved_complaints',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAchievementCard(
                  '지원 예산',
                  _getNestedValue('achievements.support_budget')?.toString() ?? '50만원',
                  SeoguColors.accent,
                  'achievements.support_budget',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value, Color color, String editKey) {
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
              fontSize: 16,
              color: SeoguColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _showEditDialog(editKey, title, value),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}