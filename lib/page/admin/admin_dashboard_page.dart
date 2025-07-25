import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/admin_service.dart';
import '../data/dong_list.dart';
import 'dong_admin_dashboard_page.dart';
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
    print("key: $key, title: $title, currentValue: $currentValue");

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
    print("key $key : value : $value");
    if (key.contains('.')) {
      final parts = key.split('.');
      dynamic current = _editedData;

      for (int i = 0; i < parts.length - 1; i++) {
        final currentKey = parts[i];
        if (int.tryParse(currentKey) != null) {
          // 배열 인덱스인 경우
          final index = int.parse(currentKey);
          if (current is List && index < current.length) {
            current = current[index];
          } else {
            return; // 잘못된 인덱스
          }
        } else {
          // 객체 키인 경우  
          if (current is Map<String, dynamic>) {
            if (current[currentKey] == null) {
              current[currentKey] = <String, dynamic>{};
            }
            current = current[currentKey];
          } else {
            return; // 잘못된 타입
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

  /// JSON 포맷팅
  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// 데이터 저장
  Future<void> _saveData() async {
    // 날짜를 '2025-07-25'로 고정
    const fixedDate = '2025-07-25';

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AdminService.updateMainDashboard(fixedDate, _editedData);
      
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

  /// 성과 삭제
  void _deleteAchievement(int index) {
    setState(() {
      final achievements = List<dynamic>.from(_editedData['weeklyAchievements'] as List<dynamic>? ?? []);
      if (index >= 0 && index < achievements.length) {
        achievements.removeAt(index);
        _editedData['weeklyAchievements'] = achievements;
      }
    });
  }

  /// 새로운 성과 추가
  Future<void> _addNewAchievement() async {
    final titleController = TextEditingController();
    final valueController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 성과 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '예: 신규 가맹점',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: '값',
                hintText: '예: 47개',
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
        final weeklyAchievements = _editedData['weeklyAchievements'] as List<dynamic>? ?? [];
        weeklyAchievements.add({
          'title': titleController.text,
          'value': valueController.text,
        });
        _editedData['weeklyAchievements'] = weeklyAchievements;
      });
    }
  }

  /// 차트 데이터 편집 다이얼로그
  Future<void> _showChartEditDialog() async {
    final trendData = _editedData['trendChart'] as Map<String, dynamic>? ?? {};
    final chartDataList = List<Map<String, dynamic>>.from(
      (trendData['data'] as List<dynamic>? ?? []).map((item) => Map<String, dynamic>.from(item)),
    );
    
    // 기본 데이터가 없으면 초기화
    if (chartDataList.isEmpty) {
      chartDataList.addAll([
        {'x': 0, 'y': 75},
        {'x': 1, 'y': 78},
        {'x': 2, 'y': 82},
        {'x': 3, 'y': 80},
        {'x': 4, 'y': 85},
        {'x': 5, 'y': 87},
      ]);
    }
    
    final List<TextEditingController> controllers = chartDataList
        .map((data) => TextEditingController(text: data['y'].toString()))
        .toList();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('온누리 가맹점 추이 수정'),
        content: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '각 포인트의 Y값(%)을 수정하세요',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            alignment: Alignment.centerRight,
                            child: Text(
                              'X: ${chartDataList[index]['x']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: controllers[index],
                              decoration: InputDecoration(
                                labelText: 'Y값 (%)',
                                border: const OutlineInputBorder(),
                                suffixText: '%',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          if (controllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () {
                                Navigator.pop(context);
                                chartDataList.removeAt(index);
                                _updateChartData(chartDataList);
                                _showChartEditDialog();
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final newX = chartDataList.isNotEmpty 
                          ? (chartDataList.last['x'] as num) + 1 
                          : 0;
                      chartDataList.add({'x': newX, 'y': 85});
                      _updateChartData(chartDataList);
                      _showChartEditDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('포인트 추가'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeoguColors.primary,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      // 수정된 값들을 저장
      for (int i = 0; i < controllers.length; i++) {
        final yValue = double.tryParse(controllers[i].text) ?? chartDataList[i]['y'];
        chartDataList[i]['y'] = yValue;
      }
      _updateChartData(chartDataList);
    }
    
    // 컨트롤러 정리
    for (final controller in controllers) {
      controller.dispose();
    }
  }
  
  /// 차트 데이터 업데이트
  void _updateChartData(List<Map<String, dynamic>> newData) {
    setState(() {
      if (_editedData['trendChart'] == null) {
        _editedData['trendChart'] = {};
      }
      (_editedData['trendChart'] as Map<String, dynamic>)['data'] = newData;
    });
  }

  /// 동별 가맹률 삭제
  void _deleteDongMembership(int index) {
    setState(() {
      final dongData = _editedData['dongMembership'] as Map<String, dynamic>? ?? {};
      final items = List<dynamic>.from(dongData['data'] as List<dynamic>? ?? []);
      if (index >= 0 && index < items.length) {
        items.removeAt(index);
        if (_editedData['dongMembership'] == null) {
          _editedData['dongMembership'] = {};
        }
        (_editedData['dongMembership'] as Map<String, dynamic>)['data'] = items;
      }
    });
  }

  /// 새로운 동별 가맹률 추가
  Future<void> _addNewDongMembership() async {
    final nameController = TextEditingController();
    final percentageController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 동 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '동 이름',
                hintText: '예: 양동',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: percentageController,
              decoration: const InputDecoration(
                labelText: '가맹률',
                hintText: '예: 85.5',
                suffixText: '%',
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

    if (result == true && nameController.text.isNotEmpty && percentageController.text.isNotEmpty) {
      setState(() {
        if (_editedData['dongMembership'] == null) {
          _editedData['dongMembership'] = {'data': []};
        }
        final dongData = _editedData['dongMembership'] as Map<String, dynamic>;
        final items = dongData['data'] as List<dynamic>? ?? [];
        items.add({
          'name': nameController.text,
          'percentage': double.tryParse(percentageController.text) ?? 0,
        });
        dongData['data'] = items;
      });
    }
  }

  /// 민원 키워드 삭제
  void _deleteComplaintKeyword(int index) {
    setState(() {
      final keywordData = _editedData['complaintKeywords'] as Map<String, dynamic>? ?? {};
      final keywords = List<dynamic>.from(keywordData['data'] as List<dynamic>? ?? []);
      if (index >= 0 && index < keywords.length) {
        keywords.removeAt(index);
        if (_editedData['complaintKeywords'] == null) {
          _editedData['complaintKeywords'] = {};
        }
        (_editedData['complaintKeywords'] as Map<String, dynamic>)['data'] = keywords;
      }
    });
  }

  /// 새로운 민원 키워드 추가
  Future<void> _addNewComplaintKeyword() async {
    final keywordController = TextEditingController();
    final countController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 키워드 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keywordController,
              decoration: const InputDecoration(
                labelText: '키워드',
                hintText: '예: 주차 문제',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: countController,
              decoration: const InputDecoration(
                labelText: '건수',
                hintText: '예: 25',
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

    if (result == true && keywordController.text.isNotEmpty && countController.text.isNotEmpty) {
      setState(() {
        if (_editedData['complaintKeywords'] == null) {
          _editedData['complaintKeywords'] = {'data': []};
        }
        final keywordData = _editedData['complaintKeywords'] as Map<String, dynamic>;
        final keywords = keywordData['data'] as List<dynamic>? ?? [];
        keywords.add({
          'rank': keywords.length + 1,
          'keyword': keywordController.text,
          'count': int.tryParse(countController.text) ?? 0,
        });
        keywordData['data'] = keywords;
      });
    }
  }

  /// 민원 사례 삭제
  void _deleteComplaintCase(int index) {
    setState(() {
      final casesData = _editedData['complaintCases'] as Map<String, dynamic>? ?? {};
      final cases = List<dynamic>.from(casesData['data'] as List<dynamic>? ?? []);
      if (index >= 0 && index < cases.length) {
        cases.removeAt(index);
        if (_editedData['complaintCases'] == null) {
          _editedData['complaintCases'] = {};
        }
        (_editedData['complaintCases'] as Map<String, dynamic>)['data'] = cases;
      }
    });
  }

  /// 타 기관 동향 삭제
  void _deleteOrganizationTrend(int index) {
    setState(() {
      final trendsData = _editedData['organizationTrends'] as Map<String, dynamic>? ?? {};
      final trends = List<dynamic>.from(trendsData['data'] as List<dynamic>? ?? []);
      if (index >= 0 && index < trends.length) {
        trends.removeAt(index);
        if (_editedData['organizationTrends'] == null) {
          _editedData['organizationTrends'] = {};
        }
        (_editedData['organizationTrends'] as Map<String, dynamic>)['data'] = trends;
      }
    });
  }

  /// 새로운 타 기관 동향 추가
  Future<void> _addNewOrganizationTrend() async {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 동향 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '동향 제목',
                  hintText: '예: 부산 동구 골목상권 활성화 사업',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: '상세 내용',
                  hintText: '동향에 대한 상세 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
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

    if (result == true && titleController.text.isNotEmpty) {
      setState(() {
        if (_editedData['organizationTrends'] == null) {
          _editedData['organizationTrends'] = {'data': []};
        }
        final trendsData = _editedData['organizationTrends'] as Map<String, dynamic>;
        final trends = trendsData['data'] as List<dynamic>? ?? [];
        trends.add({
          'title': titleController.text,
          'detail': detailController.text,
        });
        trendsData['data'] = trends;
      });
    }
  }

  /// 새로운 민원 사례 추가
  Future<void> _addNewComplaintCase() async {
    final titleController = TextEditingController();
    final statusController = TextEditingController(text: '진행중');
    final detailController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 민원 사례 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '예: 동천동 주차장 확장',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: statusController.text,
                decoration: const InputDecoration(
                  labelText: '상태',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '해결', child: Text('해결')),
                  DropdownMenuItem(value: '진행중', child: Text('진행중')),
                ],
                onChanged: (value) {
                  statusController.text = value ?? '진행중';
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: '상세 내용',
                  hintText: '민원 해결 과정에 대한 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
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

    if (result == true && titleController.text.isNotEmpty) {
      setState(() {
        if (_editedData['complaintCases'] == null) {
          _editedData['complaintCases'] = {'data': []};
        }
        final casesData = _editedData['complaintCases'] as Map<String, dynamic>;
        final cases = casesData['data'] as List<dynamic>? ?? [];
        cases.add({
          'title': titleController.text,
          'status': statusController.text,
          'detail': detailController.text,
        });
        casesData['data'] = cases;
      });
    }
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
          // 동별 관리 대시보드 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.location_city, color: SeoguColors.primary),
            tooltip: '동별 대시보드',
            onSelected: (dongName) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DongAdminDashboardPage(dongName: dongName),
                ),
              );
            },
            itemBuilder: (context) => DongList.all.map((dong) => 
              PopupMenuItem<String>(
                value: dong.name,
                child: Text(dong.name),
              ),
            ).toList(),
          ),
          const SizedBox(width: 8),
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
                          // 동 목록 Wrap 위젯
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
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
                                  '🗺️ 동별 관리 대시보드',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: SeoguColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: DongList.all.map((dong) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DongAdminDashboardPage(dongName: dong.name),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: dong.color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: dong.color.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: dong.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              dong.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: SeoguColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildTopMetrics() {
    final metricsData = _editedData['topMetrics'];
    final metrics = (metricsData is List) ? metricsData : <dynamic>[];
    
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
    print("title : $title");
    print("value : $value");
    print("unit : $unit");
    print("color : $color");
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
          Row(
            children: [
              Text(
                trendData['title'] ?? '📈 온누리 가맹점 추이',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: SeoguColors.primary,
                onPressed: () => _showChartEditDialog(),
                tooltip: '그래프 수정',
              ),
            ],
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
          Row(
            children: [
              Text(
                dongData['title'] ?? '🗺️ 동별 가맹률 현황',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: SeoguColors.primary,
                onPressed: _addNewDongMembership,
                tooltip: '동 추가',
              ),
            ],
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
              index,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEditableDongStatusItem(String dongName, double percentage, Color color, String editKey, int index) {
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
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red.shade400,
                onPressed: () => _showDeleteConfirmationDialog(
                  dongName,
                  () => _deleteDongMembership(index),
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
      height: 150,
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
                keywordData['title'] ?? '🔥 민원 TOP 3 키워드',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: SeoguColors.primary,
                onPressed: _addNewComplaintKeyword,
                tooltip: '키워드 추가',
              ),
            ],
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
                  index,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableKeywordItem(String rank, String keyword, int count, Color color, String editKeyPrefix, int index) {
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
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                color: Colors.red.shade400,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showDeleteConfirmationDialog(
                  keyword,
                  () => _deleteComplaintKeyword(index),
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
          Row(
            children: [
              Text(
                casesData['title'] ?? '✅ 민원 해결 사례',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: SeoguColors.primary,
                onPressed: _addNewComplaintCase,
                tooltip: '사례 추가',
              ),
            ],
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
                  index,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCaseItem(String title, String status, String detail, String editKeyPrefix, int index) {
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
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              color: Colors.red.shade400,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showDeleteConfirmationDialog(
                title,
                () => _deleteComplaintCase(index),
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
          Row(
            children: [
              Text(
                trendsData['title'] ?? '🌐 타 기관·지자체 주요 동향',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: SeoguColors.primary,
                onPressed: _addNewOrganizationTrend,
                tooltip: '동향 추가',
              ),
            ],
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
                  index,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTrendItem(String title, String detail, String editKeyPrefix, int index) {
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
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              color: Colors.red.shade400,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showDeleteConfirmationDialog(
                title,
                () => _deleteOrganizationTrend(index),
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
            children: [
              ...achievements.asMap().entries.map((entry) {
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
              const SizedBox(width: 16),
              //TODO: 추가 버튼
              SizedBox(
                width: 60,
                height: 94,
                child: ElevatedButton(
                  onPressed: _addNewAchievement,
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


  Widget _buildEditableAchievementCard(String title, String value, Color color, String editKey) {
    // editKey를 파싱하여 인덱스 추출
    final keyParts = editKey.split('.');
    final index = int.tryParse(keyParts[1]) ?? 0;
    
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    color: Color(0xFF64748B),
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