import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../data/admin_service.dart';
import 'widget_managers.dart' show DashboardMaster;
import 'widget/type1_admin_widget.dart';
import 'widget/bbs1_admin_widget.dart';
import 'widget/bbs2_admin_widget.dart';
import 'widget/chart_admin_widget.dart';
import 'widget/percent_admin_widget.dart';
import 'widget/type2_admin_widget.dart';
import 'widget/type3_admin_widget.dart';
import 'widget/type4_admin_widget.dart';

class NewAdminDashboardPage extends StatefulWidget {
  const NewAdminDashboardPage({super.key});

  @override
  State<NewAdminDashboardPage> createState() => _NewAdminDashboardPageState();
}

class _NewAdminDashboardPageState extends State<NewAdminDashboardPage> {
  List<DashboardMaster> _dashboards = [];
  bool _isLoading = false;
  int? _selectedDashboardId;
  String _selectedWidgetType = '';

  @override
  void initState() {
    super.initState();
    _loadDashboards();
  }

  Future<void> _loadDashboards() async {
    setState(() {
      _isLoading = true;
    });

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
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _onDashboardSelected(int dashboardId, String widgetType) {
    setState(() {
      _selectedDashboardId = dashboardId;
      _selectedWidgetType = widgetType;
    });
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboards,
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
          : Row(
              children: [
                // 왼쪽: 대시보드 마스터 목록
                Expanded(
                  flex: 1,
                  child: DashboardMasterList(
                    dashboards: _dashboards,
                    selectedDashboardId: _selectedDashboardId,
                    onDashboardSelected: _onDashboardSelected,
                    onRefresh: _loadDashboards,
                  ),
                ),
                const VerticalDivider(width: 1),
                // 오른쪽: 위젯 데이터 관리
                Expanded(
                  flex: 2,
                  child: _selectedDashboardId == null
                      ? const Center(
                          child: Text(
                            '왼쪽에서 대시보드를 선택하세요',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : WidgetDataManager(
                          dashboardId: _selectedDashboardId!,
                          widgetType: _selectedWidgetType,
                        ),
                ),
              ],
            ),
    );
  }
}

// 왼쪽 대시보드 마스터 목록
class DashboardMasterList extends StatelessWidget {
  final List<DashboardMaster> dashboards;
  final int? selectedDashboardId;
  final Function(int, String) onDashboardSelected;
  final VoidCallback onRefresh;

  const DashboardMasterList({
    super.key,
    required this.dashboards,
    required this.selectedDashboardId,
    required this.onDashboardSelected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '대시보드 목록 (${dashboards.length}개)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                tooltip: '새로고침',
              ),
            ],
          ),
        ),
        Expanded(
          child: dashboards.isEmpty
              ? const Center(child: Text('대시보드가 없습니다.'))
              : ListView.builder(
                  itemCount: dashboards.length,
                  itemBuilder: (context, index) {
                    final dashboard = dashboards[index];
                    final isSelected = selectedDashboardId == dashboard.id;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                      child: ListTile(
                        title: Text(
                          dashboard.dashboardName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${dashboard.id}'),
                            Text('타입: ${dashboard.widgetType}'),
                          ],
                        ),
                        onTap: () => onDashboardSelected(dashboard.id, dashboard.widgetType),
                        selected: isSelected,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// 오른쪽 위젯 데이터 관리자
class WidgetDataManager extends StatefulWidget {
  final int dashboardId;
  final String widgetType;

  const WidgetDataManager({
    super.key,
    required this.dashboardId,
    required this.widgetType,
  });

  @override
  State<WidgetDataManager> createState() => _WidgetDataManagerState();
}

class _WidgetDataManagerState extends State<WidgetDataManager> {
  @override
  Widget build(BuildContext context) {
    // Remove 'dashboard_' prefix if present and convert to lowercase
    String cleanWidgetType = widget.widgetType.toLowerCase();
    if (cleanWidgetType.startsWith('dashboard_')) {
      cleanWidgetType = cleanWidgetType.substring(10); // Remove 'dashboard_' prefix
    }

    switch (cleanWidgetType) {
      case 'type1':
        return Type1AdminWidget(dashboardId: widget.dashboardId);
      case 'bbs1':
        return Bbs1AdminWidget(dashboardId: widget.dashboardId);
      case 'bbs2':
        return Bbs2AdminWidget(dashboardId: widget.dashboardId);
      case 'chart':
        return ChartAdminWidget(dashboardId: widget.dashboardId);
      case 'percent':
        return PercentAdminWidget(dashboardId: widget.dashboardId);
      case 'type2':
        return Type2AdminWidget(dashboardId: widget.dashboardId);
      case 'type3':
        return Type3AdminWidget(dashboardId: widget.dashboardId);
      case 'type4':
        return Type4AdminWidget(dashboardId: widget.dashboardId);
      default:
        return Center(
          child: Text('지원하지 않는 위젯 타입: ${widget.widgetType}'),
        );
    }
  }
}

