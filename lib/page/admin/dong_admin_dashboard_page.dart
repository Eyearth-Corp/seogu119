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
      
      // complaints가 List로 온 경우 Map으로 변환
      if (_editedData['complaints'] is List) {
        _editedData['complaints'] = {
          'parking': 5,
          'noise': 3,
          'cleaning': 2,
        };
      }
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
                          _buildWeeklyAchievements(),
                          const SizedBox(height: 20),
                          _buildComplaints(),
                          const SizedBox(height: 20),
                          _buildMerchantList(),
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

  // 동별 메트릭 카드들
  Widget _buildDongMetrics() {
    if (_editedData.isEmpty) {
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
              fontSize: 18,
              color: SeoguColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final metrics = _editedData['metrics'] as List<dynamic>? ?? [];
    if (metrics.isEmpty) {
      // 기본 메트릭 데이터 생성
      final defaultMetrics = [
        {'title': '🏪 총 상인회', 'value': '${_selectedDong?.merchantList.length ?? 0}', 'unit': '개'},
        {'title': '✨ 가맹률', 'value': '85.0', 'unit': '%'},
        {'title': '📊 이번주 방문', 'value': '12', 'unit': '회'},
      ];
      
      return Row(
        children: [
          for (int i = 0; i < defaultMetrics.length && i < 3; i++) ...[
            Expanded(
              child: _buildMetricCard(
                defaultMetrics[i]['title'] ?? '',
                defaultMetrics[i]['value'] ?? '',
                defaultMetrics[i]['unit'] ?? '',
                i == 0 ? _selectedDong?.color ?? SeoguColors.primary : (i == 1 ? SeoguColors.success : SeoguColors.warning),
                'metrics.$i.value',
                defaultMetrics[i]['value'],
              ),
            ),
            if (i < 2) const SizedBox(width: 16),
          ],
        ],
      );
    }
    
    return Row(
      children: [
        for (int i = 0; i < metrics.length && i < 3; i++) ...[
          Expanded(
            child: _buildMetricCard(
              metrics[i]['title'] ?? '',
              metrics[i]['value'] ?? '',
              metrics[i]['unit'] ?? '',
              i == 0 ? _selectedDong?.color ?? SeoguColors.primary : (i == 1 ? SeoguColors.success : SeoguColors.warning),
              'metrics.$i.value',
              metrics[i]['value'],
            ),
          ),
          if (i < metrics.length - 1 && i < 2) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, Color color, String editKey, dynamic editValue) {
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
              fontSize: 14,
              color: SeoguColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showEditDialog(editKey, title, editValue),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: SeoguColors.textSecondary, width: 1)),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
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

  // 주간 성과 섹션
  Widget _buildWeeklyAchievements() {
    final achievements = _editedData['achievements'] as Map<String, dynamic>? ?? {};
    
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
              fontSize: 18,
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
                  achievements['new_merchants']?.toString() ?? '2개',
                  _selectedDong?.color ?? SeoguColors.primary,
                  'achievements.new_merchants',
                  achievements['new_merchants'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAchievementCard(
                  '민원 해결',
                  achievements['resolved_complaints']?.toString() ?? '1건',
                  SeoguColors.primary,
                  'achievements.resolved_complaints',
                  achievements['resolved_complaints'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAchievementCard(
                  '지원 예산',
                  achievements['support_budget']?.toString() ?? '50만원',
                  SeoguColors.accent,
                  'achievements.support_budget',
                  achievements['support_budget'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value, Color color, String editKey, dynamic editValue) {
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
              fontSize: 14,
              color: SeoguColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showEditDialog(editKey, title, editValue),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: SeoguColors.textSecondary, width: 1)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 민원 현황 섹션
  Widget _buildComplaints() {
    final complaints = _editedData['complaints'] as Map<String, dynamic>? ?? {};
    
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
              fontSize: 18,
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
                  complaints['parking']?.toString() ?? '5',
                  SeoguColors.highlight,
                  'complaints.parking',
                  complaints['parking'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplaintItem(
                  '소음 방해',
                  complaints['noise']?.toString() ?? '3',
                  SeoguColors.warning,
                  'complaints.noise',
                  complaints['noise'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplaintItem(
                  '청소 문제',
                  complaints['cleaning']?.toString() ?? '2',
                  SeoguColors.primary,
                  'complaints.cleaning',
                  complaints['cleaning'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintItem(String title, String count, Color color, String editKey, dynamic editValue) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.warning,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: SeoguColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showEditDialog(editKey, title, editValue),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SeoguColors.textSecondary, width: 1)),
            ),
            child: Text(
              '${count}건',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SeoguColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 상인회 목록 섹션
  Widget _buildMerchantList() {
    final merchants = _editedData['merchants'] as List<dynamic>? ?? _selectedDong?.merchantList ?? [];
    
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
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _selectedDong?.color ?? SeoguColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🏪 ${widget.dongName} 상인회 목록 (${merchants.length}개)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          merchants.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  child: const Center(
                    child: Text(
                      '데이터가 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: SeoguColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: merchants.length,
                  itemBuilder: (context, index) {
                    final merchant = merchants[index];
                    return _buildMerchantCard(merchant, index);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(dynamic merchant, int index) {
    final name = merchant is Map ? merchant['name'] ?? '' : (merchant.name ?? '');
    final id = merchant is Map ? merchant['id'] ?? index + 1 : (merchant.id ?? index + 1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          Text(
            '$id. $name',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: SeoguColors.textPrimary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // 상인회 추가 다이얼로그
  Future<void> _showAddMerchantDialog() async {
    final nameController = TextEditingController();
    final xController = TextEditingController();
    final yController = TextEditingController();
    
    final result = await showDialog<Map<String, dynamic>>(
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
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: xController,
              decoration: const InputDecoration(
                labelText: 'X 좌표',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: yController,
              decoration: const InputDecoration(
                labelText: 'Y 좌표',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'x': double.tryParse(xController.text) ?? 0.0,
                  'y': double.tryParse(yController.text) ?? 0.0,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
            ),
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (_editedData['merchants'] == null) {
          _editedData['merchants'] = List.from(_selectedDong?.merchantList ?? []);
        }
        final merchants = _editedData['merchants'] as List;
        final newId = merchants.length + 1;
        merchants.add({
          'id': newId,
          'name': result['name'],
          'x': result['x'],
          'y': result['y'],
        });
      });
    }
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


}