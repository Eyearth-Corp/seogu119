import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../data/admin_service.dart';
import '../widget/dashboard/dashboard_type1_widget.dart';
import '../widget/dashboard/dashboard_type2_widget.dart';
import '../widget/dashboard/dashboard_type3_widget.dart';
import '../widget/dashboard/dashboard_type4_widget.dart';
import '../widget/dashboard/dashboard_bbs1_widget.dart';
import '../widget/dashboard/dashboard_bbs2_widget.dart';
import '../widget/dashboard/dashboard_chart_widget.dart';
import '../widget/dashboard/dashboard_percent_widget.dart';

class NewAdminDashboardPage extends StatefulWidget {
  const NewAdminDashboardPage({super.key});

  @override
  State<NewAdminDashboardPage> createState() => _NewAdminDashboardPageState();
}

class _NewAdminDashboardPageState extends State<NewAdminDashboardPage> {
  List<DashboardLayoutItem> _layouts = [];
  bool _isLoading = false;
  bool _isEditMode = false;

  final Map<String, String> _widgetTypeNames = {
    'type1': 'Type1 위젯 (메트릭 카드)',
    'type2': 'Type2 위젯 (상태 카드)',
    'type3': 'Type3 위젯 (순위)',
    'type4': 'Type4 위젯 (처리 현황)',
    'bbs1': 'BBS1 위젯 (공지사항)',
    'bbs2': 'BBS2 위젯 (트렌드)',
    'chart': '차트 위젯',
    'percent': '퍼센트 위젯',
  };

  @override
  void initState() {
    super.initState();
    _loadLayouts();
  }

  Future<void> _loadLayouts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminService.fetchFromURL(
          '${AdminService.baseUrl}/api/dashboard-layout');
      
      if (response != null && response['success'] == true) {
        final layouts = response['data']['layouts'] as List<dynamic>;
        setState(() {
          _layouts = layouts.map((item) => DashboardLayoutItem.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('레이아웃 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addWidget(String widgetType, int dashboardId, String layoutType) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/dashboard-layout',
        {
          'widget_type': widgetType,
          'dashboard_id': dashboardId,
          'layout_type': layoutType,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('위젯이 성공적으로 추가되었습니다.');
        _loadLayouts();
      }
    } catch (e) {
      _showErrorSnackBar('위젯 추가 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteWidget(int layoutId) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/dashboard-layout/$layoutId');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('위젯이 성공적으로 삭제되었습니다.');
        _loadLayouts();
      }
    } catch (e) {
      _showErrorSnackBar('위젯 삭제 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddWidgetDialog() {
    String selectedWidgetType = 'type1';
    int dashboardId = 1;
    String layoutType = 'full';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('위젯 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedWidgetType,
                decoration: const InputDecoration(labelText: '위젯 타입'),
                items: _widgetTypeNames.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedWidgetType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: dashboardId.toString(),
                decoration: const InputDecoration(labelText: '대시보드 ID'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  dashboardId = int.tryParse(value) ?? 1;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: layoutType,
                decoration: const InputDecoration(labelText: '레이아웃 타입'),
                items: const [
                  DropdownMenuItem(value: 'full', child: Text('전체 너비')),
                  DropdownMenuItem(value: 'half', child: Text('절반 너비')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    layoutType = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addWidget(selectedWidgetType, dashboardId, layoutType);
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidget(DashboardLayoutItem layout) {
    switch (layout.widgetType) {
      case 'type1':
        return DashBoardType1Widget(dashboardId: layout.dashboardId);
      case 'type2':
        return DashBoardType2Widget(dashboardId: layout.dashboardId);
      case 'type3':
        return DashBoardType3Widget(dashboardId: layout.dashboardId);
      case 'type4':
        return DashBoardType4Widget(dashboardId: layout.dashboardId);
      case 'bbs1':
        return DashBoardBbs1Widget(dashboardId: layout.dashboardId);
      case 'bbs2':
        return DashBoardBbs2Widget(dashboardId: layout.dashboardId);
      case 'chart':
        return DashBoardChartWidget(dashboardId: layout.dashboardId);
      case 'percent':
        return DashBoardPercentWidget(dashboardId: layout.dashboardId);
      default:
        return Container(
          height: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SeoguColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          child: Center(
            child: Text(
              '알 수 없는 위젯 타입: ${layout.widgetType}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
    }
  }

  Widget _buildLayoutItem(DashboardLayoutItem layout) {
    final widget = _buildWidget(layout);
    
    return Stack(
      children: [
        widget,
        if (_isEditMode)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () => _deleteWidget(layout.id),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDashboardRows() {
    final rows = <Widget>[];
    final groupedLayouts = <int, List<DashboardLayoutItem>>{};
    
    // 행별로 그룹화
    for (final layout in _layouts) {
      final rowGroup = layout.rowGroup ?? layout.positionOrder;
      groupedLayouts.putIfAbsent(rowGroup, () => []).add(layout);
    }
    
    // 정렬된 행 키 순서대로 처리
    final sortedRowKeys = groupedLayouts.keys.toList()..sort();
    
    for (final rowKey in sortedRowKeys) {
      final rowLayouts = groupedLayouts[rowKey]!;
      
      if (rowLayouts.length == 1 && rowLayouts.first.layoutType == 'full') {
        // 전체 너비 위젯
        rows.add(_buildLayoutItem(rowLayouts.first));
      } else {
        // 행에 여러 위젯이 있거나 절반 너비 위젯들
        final rowChildren = <Widget>[];
        
        for (int i = 0; i < rowLayouts.length; i++) {
          rowChildren.add(
            Expanded(child: _buildLayoutItem(rowLayouts[i])),
          );
          if (i < rowLayouts.length - 1) {
            rowChildren.add(const SizedBox(width: 20));
          }
        }
        
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        );
      }
      
      rows.add(const SizedBox(height: 20));
    }
    
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            tooltip: _isEditMode ? '편집 완료' : '편집 모드',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWidgetDialog,
            tooltip: '위젯 추가',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLayouts,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _layouts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.dashboard,
                        size: 64,
                        color: SeoguColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '위젯이 없습니다.',
                        style: TextStyle(
                          fontSize: 18,
                          color: SeoguColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddWidgetDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('위젯 추가'),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: const Color(0xFFF8FAFC),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: _buildDashboardRows(),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class DashboardLayoutItem {
  final int id;
  final String widgetType;
  final int dashboardId;
  final int positionOrder;
  final String layoutType;
  final int? rowGroup;
  final DateTime createdAt;
  final DateTime updatedAt;

  DashboardLayoutItem({
    required this.id,
    required this.widgetType,
    required this.dashboardId,
    required this.positionOrder,
    required this.layoutType,
    this.rowGroup,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardLayoutItem.fromJson(Map<String, dynamic> json) {
    return DashboardLayoutItem(
      id: json['id'],
      widgetType: json['widget_type'],
      dashboardId: json['dashboard_id'],
      positionOrder: json['position_order'],
      layoutType: json['layout_type'],
      rowGroup: json['row_group'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}