import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../data/admin_service.dart';
import '../data/dong_list.dart';
import 'widget_managers.dart' show DashboardMaster;
import 'widget/type1_admin_widget.dart';
import 'widget/bbs1_admin_widget.dart';
import 'widget/bbs2_admin_widget.dart';
import 'widget/chart_admin_widget.dart';
import 'widget/percent_admin_widget.dart';
import 'widget/type2_admin_widget.dart';
import 'widget/type3_admin_widget.dart';
import 'widget/type4_admin_widget.dart';
import 'dong_admin_dashboard_page.dart';

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

  bool _isItemSelected(DashboardMaster dashboard) {
    return _selectedDashboardId == dashboard.id && 
           _selectedWidgetType == dashboard.widgetType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '대시보드 관리',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadDashboards,
              tooltip: '새로고침',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF475569),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
          : Column(
              children: [
                // 동별 관리 버튼들
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, 
                               color: Color(0xFF475569), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            '동별 관리',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              '${DongList.all.length}개 지역',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: DongList.all.map((dong) => 
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DongAdminDashboardPage(dongName: dong.name),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
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
                                    const SizedBox(width: 8),
                                    Text(
                                      dong.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${dong.merchantList.length}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                // 기존 대시보드 컨텐츠
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 왼쪽: 대시보드 마스터 목록
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DashboardMasterList(
                              dashboards: _dashboards,
                              isItemSelected: _isItemSelected,
                              onDashboardSelected: _onDashboardSelected,
                              onRefresh: _loadDashboards,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 오른쪽: 위젯 데이터 관리
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _selectedDashboardId == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.dashboard_outlined,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '왼쪽에서 대시보드를 선택하세요',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : WidgetDataManager(
                                    dashboardId: _selectedDashboardId!,
                                    widgetType: _selectedWidgetType,
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
}

// 왼쪽 대시보드 마스터 목록
class DashboardMasterList extends StatelessWidget {
  final List<DashboardMaster> dashboards;
  final bool Function(DashboardMaster) isItemSelected;
  final Function(int, String) onDashboardSelected;
  final VoidCallback onRefresh;

  const DashboardMasterList({
    super.key,
    required this.dashboards,
    required this.isItemSelected,
    required this.onDashboardSelected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '대시보드 목록',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '${dashboards.length}개',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: dashboards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '대시보드가 없습니다',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dashboards.length,
                  itemBuilder: (context, index) {
                    final dashboard = dashboards[index];
                    final isSelected = isItemSelected(dashboard);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onDashboardSelected(dashboard.id, dashboard.widgetType),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dashboard.dashboardName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF3B82F6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'edit':
                                              _showEditDialog(context, dashboard);
                                              break;
                                            // case 'delete':
                                            //   _showDeleteDialog(context, dashboard);
                                            //   break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 16, color: Color(0xFF475569)),
                                                SizedBox(width: 8),
                                                Text('수정'),
                                              ],
                                            ),
                                          ),
                                          // const PopupMenuItem(
                                          //   value: 'delete',
                                          //   child: Row(
                                          //     children: [
                                          //       Icon(Icons.delete, size: 16, color: Color(0xFFEF4444)),
                                          //       SizedBox(width: 8),
                                          //       Text('삭제', style: TextStyle(color: Color(0xFFEF4444))),
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.more_vert,
                                            size: 16,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildInfoChip('ID', dashboard.id.toString()),
                                    const SizedBox(width: 8),
                                    _buildInfoChip('타입', dashboard.widgetType),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DashboardCreateDialog(
        onRefresh: onRefresh,
      ),
    );
  }

  void _showEditDialog(BuildContext context, DashboardMaster dashboard) {
    showDialog(
      context: context,
      builder: (context) => DashboardEditDialog(
        dashboard: dashboard,
        onRefresh: onRefresh,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DashboardMaster dashboard) {
    showDialog(
      context: context,
      builder: (context) => DashboardDeleteDialog(
        dashboard: dashboard,
        onRefresh: onRefresh,
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
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

// Dialog widgets for CRUD operations
class DashboardCreateDialog extends StatefulWidget {
  final VoidCallback onRefresh;

  const DashboardCreateDialog({
    super.key,
    required this.onRefresh,
  });

  @override
  State<DashboardCreateDialog> createState() => _DashboardCreateDialogState();
}

class _DashboardCreateDialogState extends State<DashboardCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedWidgetType;
  bool _isLoading = false;
  Map<String, dynamic>? _widgetTypes;

  @override
  void initState() {
    super.initState();
    _loadWidgetTypes();
  }

  Future<void> _loadWidgetTypes() async {
    try {
      final response = await AdminService.getWidgetTypes();
      if (response != null && response['success'] == true) {
        setState(() {
          _widgetTypes = response['data']['widget_types'];
          _selectedWidgetType = _widgetTypes!.keys.first;
        });
      }
    } catch (e) {
      setState(() {
        _widgetTypes = {
          'dashboard_type1': 'Type1 위젯 (메트릭 카드)',
          'dashboard_type2': 'Type2 위젯 (상태 카드)',
          'dashboard_type3': 'Type3 위젯 (순위)',
          'dashboard_type4': 'Type4 위젯 (처리 현황)',
          'dashboard_bbs1': 'BBS1 위젯 (공지사항)',
          'dashboard_bbs2': 'BBS2 위젯 (트렌드)',
          'dashboard_chart': '차트 위젯',
          'dashboard_percent': '퍼센트 위젯'
        };
        _selectedWidgetType = _widgetTypes!.keys.first;
      });
    }
  }

  Future<void> _createDashboard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AdminService.createDashboardMaster(
        id: int.parse(_idController.text),
        widgetType: _selectedWidgetType!,
        dashboardName: _nameController.text.trim(),
        dashboardDescription: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (response != null && response['success'] == true) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('대시보드가 성공적으로 생성되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('생성 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '새 대시보드 추가',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID *',
                  hintText: '대시보드 ID를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ID를 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자만 입력 가능합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_widgetTypes != null && _selectedWidgetType != null)
                DropdownButtonFormField<String>(
                  value: _selectedWidgetType,
                  decoration: const InputDecoration(
                    labelText: '위젯 타입 *',
                    border: OutlineInputBorder(),
                  ),
                  items: _widgetTypes!.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedWidgetType = value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '위젯 타입을 선택해주세요';
                    }
                    return null;
                  },
                )
              else
                const Center(
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '대시보드 이름 *',
                  hintText: '대시보드 이름을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '대시보드 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택사항)',
                  hintText: '대시보드 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createDashboard,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('생성'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class DashboardEditDialog extends StatefulWidget {
  final DashboardMaster dashboard;
  final VoidCallback onRefresh;

  const DashboardEditDialog({
    super.key,
    required this.dashboard,
    required this.onRefresh,
  });

  @override
  State<DashboardEditDialog> createState() => _DashboardEditDialogState();
}

class _DashboardEditDialogState extends State<DashboardEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dashboard.dashboardName);
    _descriptionController = TextEditingController(text: widget.dashboard.dashboardDescription);
  }

  Future<void> _updateDashboard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AdminService.updateDashboardMaster(
        id: widget.dashboard.id,
        widgetType: widget.dashboard.widgetType,
        dashboardName: _nameController.text.trim(),
        dashboardDescription: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (response != null && response['success'] == true) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('대시보드가 성공적으로 수정되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('수정 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '대시보드 수정',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${widget.dashboard.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '위젯 타입: ${widget.dashboard.widgetType}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '대시보드 이름 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '대시보드 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택사항)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateDashboard,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('수정'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class DashboardDeleteDialog extends StatefulWidget {
  final DashboardMaster dashboard;
  final VoidCallback onRefresh;

  const DashboardDeleteDialog({
    super.key,
    required this.dashboard,
    required this.onRefresh,
  });

  @override
  State<DashboardDeleteDialog> createState() => _DashboardDeleteDialogState();
}

class _DashboardDeleteDialogState extends State<DashboardDeleteDialog> {
  bool _isLoading = false;

  Future<void> _deleteDashboard() async {
    setState(() => _isLoading = true);

    try {
      final response = await AdminService.deleteDashboardMaster(
        id: widget.dashboard.id,
        widgetType: widget.dashboard.widgetType,
      );

      if (response != null && response['success'] == true) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('대시보드가 성공적으로 삭제되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
          SizedBox(width: 8),
          Text(
            '대시보드 삭제',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '정말로 삭제하시겠습니까?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '대시보드: ${widget.dashboard.dashboardName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'ID: ${widget.dashboard.id}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '위젯 타입: ${widget.dashboard.widgetType}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '⚠️ 삭제된 데이터는 복구할 수 없습니다.',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteDashboard,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('삭제'),
        ),
      ],
    );
  }
}

