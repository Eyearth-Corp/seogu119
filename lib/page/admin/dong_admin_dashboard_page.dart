import 'dart:convert';

import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import '../data/dong_list.dart';
import '../../core/colors.dart';

class DongAdminDashboardPage extends StatefulWidget {
  final String dongName;

  const DongAdminDashboardPage({
    super.key,
    required this.dongName,
  });

  @override
  State<DongAdminDashboardPage> createState() => _DongAdminDashboardPageState();
}

class _DongAdminDashboardPageState extends State<DongAdminDashboardPage> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  List<String> _availableDates = [];
  String? _selectedDate;
  
  // 편집 가능한 필드들을 위한 로컬 상태
  final Map<String, dynamic> _editedData = {};

  // 동 정보 가져오기
  Dong get _dong {
    return DongList.all.firstWhere(
      (dong) => dong.name == widget.dongName,
      orElse: () => DongList.all.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDongDashboardFromAPI();
  }

  /// 동별 대시보드 API 호출
  Future<void> _loadDongDashboardFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminService.getDongDashboardByDate(widget.dongName, '2025-07-25');
      
      if (response != null && response['success'] == true && response['data'] != null) {
        // API 응답이 있는 경우 data 필드 사용
        final apiData = response['data'];
        setState(() {
          _dashboardData = apiData;
          _initializeEditedData();
          
          // availableDates가 있으면 설정
          if (apiData['availableDates'] != null) {
            _availableDates = List<String>.from(apiData['availableDates']);
            if (_availableDates.isNotEmpty && _selectedDate == null) {
              _selectedDate = _availableDates.first;
            }
          } else {
            // 기본 날짜 설정
            _availableDates = ['2025-07-25'];
            _selectedDate = '2025-07-25';
          }
        });
      } else {
        // API 응답이 없으면 기본 데이터 생성
        _createDefaultData();
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
      // 오류 발생 시에도 기본 데이터 생성
      _createDefaultData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 기본 데이터 생성
  void _createDefaultData() {
    final merchants = _dong.merchantList;
    setState(() {
      _dashboardData = {
        'dongName': widget.dongName,
        'dongMetrics': [
          {
            'title': '🏪 총 상인회',
            'value': merchants.length.toString(),
            'unit': '개'
          },
          {
            'title': '✨ 가맹률',
            'value': '85.0',
            'unit': '%'
          },
          {
            'title': '📊 이번주 방문',
            'value': '12',
            'unit': '회'
          },
        ],
        'merchants': merchants.map((m) => {
          'id': m.id,
          'name': m.name,
          'x': m.x,
          'y': m.y,
        }).toList(),
        'complaints': {
          'parking': 5,
          'noise': 3,
          'cleaning': 2,
        },
        'weeklyAchievements': [
          {'title': '신규 가맹', 'value': '2개'},
          {'title': '민원 해결', 'value': '1건'},
          {'title': '지원 예산', 'value': '50만원'},
        ],
        'businessTypes': [
          {'type': '음식점', 'count': 2, 'percentage': 40},
          {'type': '소매점', 'count': 2, 'percentage': 30},
          {'type': '서비스업', 'count': 1, 'percentage': 20},
          {'type': '기타', 'count': 1, 'percentage': 10},
        ],
        'availableDates': ['2025-07-26', '2025-07-25'],
        'availableDongs': DongList.all.map((d) => d.name).toList(),
      };
      _initializeEditedData();
    });
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
      final response = await AdminService.getDongDashboardByDate(widget.dongName, date);
      
      if (response != null) {
        setState(() {
          _dashboardData = response;
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
      dynamic current = _editedData;

      for (int i = 0; i < parts.length - 1; i++) {
        final currentKey = parts[i];
        if (int.tryParse(currentKey) != null) {
          final index = int.parse(currentKey);
          if (current is List && index < current.length) {
            current = current[index];
          } else {
            return;
          }
        } else {
          if (current is Map<String, dynamic>) {
            if (current[currentKey] == null) {
              current[currentKey] = <String, dynamic>{};
            }
            current = current[currentKey];
          } else {
            return;
          }
        }
      }

      final lastKey = parts.last;
      if (int.tryParse(lastKey) != null) {
        final index = int.parse(lastKey);
        if (current is List && index < current.length) {
          current[index] = value;
        }
      } else {
        if (current is Map<String, dynamic>) {
          current[lastKey] = value;
        }
      }
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
      'total_merchants', 'membership_rate', 'weekly_visits',
      'parking', 'noise', 'cleaning', 'count', 'percentage', 'value', 'x', 'y'
    };
    
    return numericFields.any((field) => key.contains(field));
  }

  /// 저장 확인 다이얼로그
  Future<void> _showSaveConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 저장'),
        content: const Text('변경사항을 저장하시겠습니까?'),
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
    const fixedDate = '2025-07-25';

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AdminService.updateDongDashboard(widget.dongName, fixedDate, _editedData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '데이터가 성공적으로 저장되었습니다.' : '데이터 저장에 실패했습니다.'),
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
        // 총 상인회 수도 업데이트
        _updateMerchantCount();
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
                hintText: '예: 홍길동상회',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: xController,
              decoration: const InputDecoration(
                labelText: 'X 좌표',
                hintText: '예: 100',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: yController,
              decoration: const InputDecoration(
                labelText: 'Y 좌표',
                hintText: '예: 200',
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
        final newId = merchants.isEmpty ? 1 : (merchants.map((m) => m['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b) + 1);
        merchants.add({
          'id': newId,
          'name': nameController.text,
          'x': double.tryParse(xController.text) ?? 0,
          'y': double.tryParse(yController.text) ?? 0,
        });
        _editedData['merchants'] = merchants;
        _updateMerchantCount();
      });
    }
  }

  /// 상인회 수 업데이트
  void _updateMerchantCount() {
    final merchants = _editedData['merchants'] as List<dynamic>? ?? [];
    final dongMetrics = _editedData['dongMetrics'] as List<dynamic>? ?? [];
    
    if (dongMetrics.isNotEmpty) {
      dongMetrics[0]['value'] = merchants.length.toString();
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
                          _buildComplaints(),
                          const SizedBox(height: 20),
                          _buildMerchants(),
                          const SizedBox(height: 20),
                          _buildWeeklyAchievements(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _dong.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.dongName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '총 상인회: ${(_editedData['merchants'] as List<dynamic>? ?? []).length}개',
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
    final metricsData = _editedData['dongMetrics'];
    final metrics = (metricsData is List) ? metricsData : <dynamic>[];
    
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
            '📊 주요 지표',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: metrics.map((metric) {
              final index = metrics.indexOf(metric);
              return Expanded(
                child: _buildEditableMetricCard(
                  metric['title'] ?? '',
                  metric['value']?.toString() ?? '',
                  metric['unit'] ?? '',
                  [SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent][index % 3],
                  'dongMetrics.$index.value',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableMetricCard(String title, String value, String unit, Color color, String editKey) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: SeoguColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showEditDialog(editKey, title, value),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SeoguColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaints() {
    final complaintsData = _editedData['complaints'];
    final complaints = (complaintsData is List) ? complaintsData : <dynamic>[];
    
    // API 응답에서 키워드별로 카운트 추출
    int getComplaintCount(String keyword) {
      for (var complaint in complaints) {
        if (complaint is Map && complaint['keyword'] == keyword) {
          return complaint['count'] ?? 0;
        }
      }
      return 0;
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
          const Text(
            '📢 민원 현황',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildComplaintItem('주차 문제', getComplaintCount('주차 문제'), SeoguColors.warning, 'complaints.parking'),
              _buildComplaintItem('소음 방해', getComplaintCount('소음 방해'), SeoguColors.primary, 'complaints.noise'),
              _buildComplaintItem('청소 문제', getComplaintCount('청소 문제'), SeoguColors.secondary, 'complaints.cleaning'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintItem(String title, int count, Color color, String editKey) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showEditDialog(editKey, title, count),
              child: Text(
                '$count건',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchants() {
    final merchants = _editedData['merchants'] as List<dynamic>? ?? [];
    
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
            return _buildMerchantItem(
              merchant['name'] ?? '',
              merchant['x']?.toString() ?? '0',
              merchant['y']?.toString() ?? '0',
              index,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMerchantItem(String name, String x, String y, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _showEditDialog('merchants.$index.name', '상인회 이름', name),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: SeoguColors.textPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showEditDialog('merchants.$index.x', 'X 좌표', x),
              child: Text(
                'X: $x',
                style: const TextStyle(
                  fontSize: 14,
                  color: SeoguColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showEditDialog('merchants.$index.y', 'Y 좌표', y),
              child: Text(
                'Y: $y',
                style: const TextStyle(
                  fontSize: 14,
                  color: SeoguColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: Colors.red.shade400,
            onPressed: () => _showDeleteConfirmationDialog(
              name,
              () => _deleteMerchant(index),
            ),
          ),
        ],
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
            '🎯 이번주 성과',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: achievements.map((achievement) {
              final index = achievements.indexOf(achievement);
              return Expanded(
                child: _buildAchievementCard(
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

  Widget _buildAchievementCard(String title, String value, Color color, String editKey) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _showEditDialog(editKey, title, value),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
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