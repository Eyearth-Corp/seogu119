import 'package:flutter/material.dart';
import '../../data/admin_service.dart';

class ChartAdminWidget extends StatefulWidget {
  final int dashboardId;

  const ChartAdminWidget({super.key, required this.dashboardId});

  @override
  State<ChartAdminWidget> createState() => _ChartAdminWidgetState();
}

class _ChartAdminWidgetState extends State<ChartAdminWidget> {
  List<ChartItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(ChartAdminWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dashboardId != widget.dashboardId) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AdminService.fetchFromURL(
          '${AdminService.baseUrl}/api/DashBoardChart?id=${widget.dashboardId}');
      
      if (response != null && response['success'] == true) {
        final chartData = response['data']['chart_data'] as List<dynamic>;
        setState(() {
          _items = chartData.map((item) => ChartItem.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Chart 데이터 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createItem(String title, double x, double y) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/DashBoardChart',
        {
          'dashboard_id': widget.dashboardId,
          'title': title,
          'x': x,
          'y': y,
          'display_order': _items.length,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Chart 아이템이 성공적으로 생성되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Chart 아이템 생성 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _updateItem(int id, String title, double x, double y) async {
    try {
      final response = await AdminService.putToURL(
        '${AdminService.baseUrl}/api/DashBoardChart/$id',
        {
          'title': title,
          'x': x,
          'y': y,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Chart 아이템이 성공적으로 수정되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Chart 아이템 수정 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/DashBoardChart/$id');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Chart 아이템이 성공적으로 삭제되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Chart 아이템 삭제 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  void _showDialog({ChartItem? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final xController = TextEditingController(text: item?.x.toString() ?? '');
    final yController = TextEditingController(text: item?.y.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Chart 아이템 추가' : 'Chart 아이템 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: xController,
              decoration: const InputDecoration(
                labelText: 'X 값',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: yController,
              decoration: const InputDecoration(
                labelText: 'Y 값',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final x = double.tryParse(xController.text) ?? 0.0;
              final y = double.tryParse(yController.text) ?? 0.0;
              if (item == null) {
                _createItem(titleController.text, x, y);
              } else {
                _updateItem(item.id, titleController.text, x, y);
              }
            },
            child: Text(item == null ? '추가' : '수정'),
          ),
        ],
      ),
    );
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
                'Chart 위젯 데이터 (${_items.length}개)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showDialog(),
                icon: const Icon(Icons.add),
                label: const Text('추가'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(child: Text('Chart 아이템이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text('X: ${item.x}, Y: ${item.y}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showDialog(item: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// Chart 데이터 모델
class ChartItem {
  final int id;
  final String title;
  final double x;
  final double y;

  ChartItem({
    required this.id,
    required this.title,
    required this.x,
    required this.y,
  });

  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
    );
  }
}