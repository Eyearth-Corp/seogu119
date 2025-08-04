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
  List<DashboardMaster> _dashboards = [];
  Map<String, String> _widgetTypeNames = {
    'type1': 'Type1 위젯 (메트릭 카드)',
    'type2': 'Type2 위젯 (상태 카드)',
    'type3': 'Type3 위젯 (순위)',
    'type4': 'Type4 위젯 (처리 현황)',
    'bbs1': 'BBS1 위젯 (공지사항)',
    'bbs2': 'BBS2 위젯 (트렌드)',
    'chart': '차트 위젯',
    'percent': '퍼센트 위젯',
  };
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadLayouts(),
      _loadDashboards(),
      _loadWidgetTypes(),
    ]);
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
    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위젯 삭제'),
        content: const Text('이 위젯을 삭제하시겠습니까?\n삭제된 위젯은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
    if (_widgetTypeNames.isEmpty || _dashboards.isEmpty) {
      _showErrorSnackBar('데이터 로딩 중입니다. 잠시만 기다려 주세요.');
      return;
    }

    String selectedWidgetType = _widgetTypeNames.keys.first;
    int selectedDashboardId = _dashboards.first.dashboardId;
    String layoutType = 'full';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_box, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('위젯 추가'),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '위젯 타입',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedWidgetType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
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
                const Text(
                  '대시보드',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedDashboardId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _dashboards.map((dashboard) {
                    return DropdownMenuItem(
                      value: dashboard.dashboardId,
                      child: Text('${dashboard.dashboardId}. ${dashboard.dashboardName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDashboardId = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '레이아웃 타입',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: layoutType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'full', child: Text('전체 너비 (1행 전체)')),
                    DropdownMenuItem(value: 'half', child: Text('절반 너비 (1행에 2개)')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      layoutType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addWidget(selectedWidgetType, selectedDashboardId, layoutType);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
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
          if (_layouts.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isEditMode ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isEditMode ? Colors.orange : Colors.green,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isEditMode ? Icons.edit : Icons.visibility,
                    size: 16,
                    color: _isEditMode ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isEditMode ? '편집중' : '보기',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isEditMode ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
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
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('데이터를 불러오는 중...'),
                ],
              ),
            )
          : _layouts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.dashboard,
                          size: 64,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '위젯이 없습니다',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: SeoguColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '새 위젯을 추가하여 대시보드를 구성해보세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: SeoguColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddWidgetDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('첫 번째 위젯 추가'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    children: [
                      // 통계 정보 헤더
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            Icon(Icons.widgets, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '대시보드 위젯 관리',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: SeoguColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '총 ${_layouts.length}개 위젯 구성됨',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: SeoguColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isEditMode)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '편집 모드',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 위젯 영역
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: _buildDashboardRows(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // 대시보드 마스터 목록 로드
  Future<void> _loadDashboards() async {
    try {
      final response = await AdminService.fetchFromURL(
          '${AdminService.baseUrl}/api/dashboard-master');
      
      if (response != null && response['success'] == true) {
        final dashboards = response['data']['dashboards'] as List<dynamic>;
        setState(() {
          _dashboards = dashboards.map((item) => DashboardMaster.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('대시보드 목록 로드 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  // 위젯 타입 목록 로드
  Future<void> _loadWidgetTypes() async {
    try {
      final response = await AdminService.fetchFromURL(
          '${AdminService.baseUrl}/api/widget-types');
      
      if (response != null && response['success'] == true) {
        final widgetTypes = response['data']['widget_types'] as Map<String, dynamic>;
        setState(() {
          _widgetTypeNames = widgetTypes.cast<String, String>();
        });
      }
    } catch (e) {
      _showErrorSnackBar('위젯 타입 목록 로드 실패: ${AdminService.getErrorMessage(e)}');
      // 기본값 설정
      setState(() {
        _widgetTypeNames = {
          'type1': 'Type1 위젯 (메트릭 카드)',
          'type2': 'Type2 위젯 (상태 카드)',
          'type3': 'Type3 위젯 (순위)',
          'type4': 'Type4 위젯 (처리 현황)',
          'bbs1': 'BBS1 위젯 (공지사항)',
          'bbs2': 'BBS2 위젯 (트렌드)', 
          'chart': '차트 위젯',
          'percent': '퍼센트 위젯',
        };
      });
    }
  }
}

// 대시보드 마스터 모델 클래스
class DashboardMaster {
  final int dashboardId;
  final String dashboardName;
  final String dashboardDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  DashboardMaster({
    required this.dashboardId,
    required this.dashboardName,
    required this.dashboardDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardMaster.fromJson(Map<String, dynamic> json) {
    return DashboardMaster(
      dashboardId: json['dashboard_id'],
      dashboardName: json['dashboard_name'],
      dashboardDescription: json['dashboard_description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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