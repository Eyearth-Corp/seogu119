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
      print('🔄 동별 대시보드 로드 시작: ${widget.dongName}');
      final response = await AdminService.getDongDashboardByDate(widget.dongName, '2025-07-25');
      print('📡 API 응답 받음: ${response != null ? "성공" : "null"}');
      
      if (response != null) {
        print('📊 응답 데이터 구조: ${response.keys}');
        if (response['success'] == true && response['data'] != null) {
          print('✅ 성공적인 API 응답');
        } else {
          print('⚠️ API 응답이 있지만 success=false 또는 data=null');
          print('  - success: ${response['success']}');
          print('  - data: ${response['data']}');
        }
      }
      
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
        print('📝 기본 데이터로 대체');
        _createDefaultData();
      }
    } catch (e) {
      print('❌ 동별 대시보드 로드 중 예외 발생: $e');
      print('📍 스택 트레이스: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동별 대시보드 데이터 로드 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // 오류 발생 시에도 기본 데이터 생성
      print('📝 예외 처리 후 기본 데이터 생성');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
        content: Container(
          width: 400,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
              ),
              hintText: '값을 입력하세요',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: SeoguColors.textPrimary,
            ),
            keyboardType: _isNumericField(key) ? TextInputType.number : TextInputType.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              '확인',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '데이터 저장',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
        content: const Text(
          '변경사항을 저장하시겠습니까?',
          style: TextStyle(
            fontSize: 16,
            color: SeoguColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              '저장',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '삭제 확인',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          '정말로 "$itemName"을(를) 삭제하시겠습니까?',
          style: const TextStyle(
            fontSize: 16,
            color: SeoguColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              '삭제',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      ),
    );

    if (result == true) {
      onConfirm();
    }
  }

  /// 주요 지표 삭제
  void _deleteDongMetric(int index) {
    setState(() {
      final metrics = List<dynamic>.from(_editedData['dongMetrics'] as List<dynamic>? ?? []);
      if (index >= 0 && index < metrics.length) {
        metrics.removeAt(index);
        _editedData['dongMetrics'] = metrics;
      }
    });
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

  /// 새로운 주요 지표 추가
  Future<void> _addNewDongMetric() async {
    final titleController = TextEditingController();
    final valueController = TextEditingController();
    final unitController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '새 주요 지표 추가',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  hintText: '예: 🏪 총 상인회',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: '값',
                  hintText: '예: 5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: InputDecoration(
                  labelText: '단위',
                  hintText: '예: 개, %',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              '추가',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      ),
    );

    if (result == true && titleController.text.isNotEmpty && valueController.text.isNotEmpty) {
      setState(() {
        final dongMetrics = _editedData['dongMetrics'] as List<dynamic>? ?? [];
        dongMetrics.add({
          'title': titleController.text,
          'value': valueController.text,
          'unit': unitController.text,
        });
        _editedData['dongMetrics'] = dongMetrics;
      });
    }
  }

  /// 새로운 상인회 추가
  Future<void> _addNewMerchant() async {
    final nameController = TextEditingController();
    final xController = TextEditingController();
    final yController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '새 상인회 추가',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '상인회 이름',
                  hintText: '예: 홍길동상회',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: xController,
                decoration: InputDecoration(
                  labelText: 'X 좌표',
                  hintText: '예: 100',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: yController,
                decoration: InputDecoration(
                  labelText: 'Y 좌표',
                  hintText: '예: 200',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              '추가',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
          Row(
            children: [
              const Text(
                '📊 주요 지표',
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
                onPressed: _addNewDongMetric,
                tooltip: '지표 추가',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...metrics.map((metric) {
                final index = metrics.indexOf(metric);
                return Expanded(
                  child: _buildEditableMetricCard(
                    metric['title'] ?? '',
                    metric['value']?.toString() ?? '',
                    metric['unit'] ?? '',
                    [SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent][index % 3],
                    'dongMetrics.$index.value',
                    index,
                  ),
                );
              }).toList(),
              if (metrics.length < 4) // 최대 4개까지 추가 버튼 표시
                const SizedBox(width: 16),
              if (metrics.length < 4)
                SizedBox(
                  width: 60,
                  height: 94,
                  child: ElevatedButton(
                    onPressed: _addNewDongMetric,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEditableMetricCard(String title, String value, String unit, Color color, String editKey, int index) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SeoguColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                color: Colors.red.shade400,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showDeleteConfirmationDialog(
                  title,
                  () => _deleteDongMetric(index),
                ),
              ),
            ],
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
          _buildComplaintsList(),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _showAddComplaintDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('민원 유형 추가'),
              style: TextButton.styleFrom(
                foregroundColor: SeoguColors.primary,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
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
                child: _buildAchievementCardWithDelete(
                  achievement['title'] ?? '',
                  achievement['value']?.toString() ?? '',
                  [SeoguColors.secondary, SeoguColors.primary, SeoguColors.accent][index % 3],
                  'weeklyAchievements.$index.value',
                  index,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _showAddAchievementDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('성과 항목 추가'),
              style: TextButton.styleFrom(
                foregroundColor: SeoguColors.primary,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
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

  Widget _buildAchievementCardWithDelete(String title, String value, Color color, String editKey, int index) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SeoguColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (index >= 3) // 기본 3개 항목은 삭제 불가
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 14),
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showDeleteConfirmationDialog(
                    title,
                    () => _deleteAchievement(index),
                  ),
                ),
            ],
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

  void _showAddComplaintDialog() {
    final titleController = TextEditingController();
    final countController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '민원 유형 추가',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '민원 유형',
                  hintText: '예: 불법주차',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: countController,
                decoration: InputDecoration(
                  labelText: '건수',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addComplaint(titleController.text, int.tryParse(countController.text) ?? 0);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              '추가',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      ),
    );
  }

  void _showAddAchievementDialog() {
    final titleController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '성과 항목 추가',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '성과 제목',
                  hintText: '예: 교육 횟수',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: '성과 값',
                  hintText: '예: 5회',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SeoguColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && valueController.text.isNotEmpty) {
                _addAchievement(titleController.text, valueController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              '추가',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      ),
    );
  }

  void _addComplaint(String title, int count) {
    setState(() {
      final complaints = _editedData['complaints'] as Map<String, dynamic>? ?? {};
      final newKey = title.replaceAll(' ', '_').toLowerCase();
      complaints[newKey] = count;
      _editedData['complaints'] = complaints;
    });
  }

  void _addAchievement(String title, String value) {
    setState(() {
      final achievements = List<Map<String, dynamic>>.from(
        _editedData['weeklyAchievements'] as List<dynamic>? ?? []
      );
      achievements.add({'title': title, 'value': value});
      _editedData['weeklyAchievements'] = achievements;
    });
  }

  void _deleteAchievement(int index) {
    setState(() {
      final achievements = List<Map<String, dynamic>>.from(
        _editedData['weeklyAchievements'] as List<dynamic>? ?? []
      );
      if (index < achievements.length && index >= 3) { // 기본 3개 항목은 삭제 불가
        achievements.removeAt(index);
        _editedData['weeklyAchievements'] = achievements;
      }
    });
  }

  Widget _buildComplaintsList() {
    // complaints 데이터 처리 - Map 또는 List 형태 모두 지원
    Map<String, dynamic> complaints = {};
    
    final complaintsData = _editedData['complaints'];
    if (complaintsData is Map<String, dynamic>) {
      complaints = complaintsData;
    } else if (complaintsData is List) {
      // List 형태일 경우 Map으로 변환
      complaints = {
        'parking': 5,
        'noise': 3,
        'cleaning': 2,
      };
      // API 응답에서 실제 값 추출
      for (var item in complaintsData) {
        if (item is Map<String, dynamic>) {
          final keyword = item['keyword']?.toString() ?? '';
          final count = item['count'] ?? 0;
          
          if (keyword == '주차 문제') complaints['parking'] = count;
          else if (keyword == '소음 방해') complaints['noise'] = count;
          else if (keyword == '청소 문제') complaints['cleaning'] = count;
        }
      }
    } else {
      complaints = {'parking': 5, 'noise': 3, 'cleaning': 2};
    }
    
    final colors = [SeoguColors.warning, SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: complaints.entries.map((entry) {
        final index = complaints.keys.toList().indexOf(entry.key);
        final title = _getComplaintTitle(entry.key);
        final count = entry.value as int;
        final color = colors[index % colors.length];
        
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 80) / 3 - 8,
          child: _buildComplaintItemWithDelete(title, count, color, 'complaints.${entry.key}', entry.key),
        );
      }).toList(),
    );
  }

  String _getComplaintTitle(String key) {
    switch (key) {
      case 'parking': return '주차 문제';
      case 'noise': return '소음 방해'; 
      case 'cleaning': return '청소 문제';
      default: return key.replaceAll('_', ' ');
    }
  }

  Widget _buildComplaintItemWithDelete(String title, int count, Color color, String editKey, String complaintKey) {
    final isBasicComplaint = ['parking', 'noise', 'cleaning'].contains(complaintKey);
    
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SeoguColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!isBasicComplaint) // 기본 민원 유형은 삭제 불가
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 14),
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showDeleteConfirmationDialog(
                    title,
                    () => _deleteComplaint(complaintKey),
                  ),
                ),
            ],
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
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteComplaint(String key) {
    setState(() {
      final complaints = Map<String, dynamic>.from(_editedData['complaints'] as Map<String, dynamic>? ?? {});
      complaints.remove(key);
      _editedData['complaints'] = complaints;
    });
  }
}