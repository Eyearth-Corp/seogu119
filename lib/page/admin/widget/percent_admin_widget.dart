import 'package:flutter/material.dart';
import '../../data/admin_service.dart';

class PercentAdminWidget extends StatefulWidget {
  final int dashboardId;

  const PercentAdminWidget({super.key, required this.dashboardId});

  @override
  State<PercentAdminWidget> createState() => _PercentAdminWidgetState();
}

class _PercentAdminWidgetState extends State<PercentAdminWidget> {
  List<PercentItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(PercentAdminWidget oldWidget) {
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
          '${AdminService.baseUrl}/api/DashBoardPercent?id=${widget.dashboardId}');
      
      if (response != null && response['success'] == true) {
        final percentData = response['data']['percent_data'] as List<dynamic>;
        setState(() {
          _items = percentData.map((item) => PercentItem.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Percent 데이터 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createItem(String title, String name, double percentage) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/DashBoardPercent',
        {
          'dashboard_id': widget.dashboardId,
          'title': title,
          'name': name,
          'percentage': percentage,
          'display_order': _items.length,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Percent 아이템이 성공적으로 생성되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Percent 아이템 생성 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _updateItem(int id, String title, String name, double percentage) async {
    try {
      final response = await AdminService.putToURL(
        '${AdminService.baseUrl}/api/DashBoardPercent/$id',
        {
          'title': title,
          'name': name,
          'percentage': percentage,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Percent 아이템이 성공적으로 수정되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Percent 아이템 수정 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/DashBoardPercent/$id');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Percent 아이템이 성공적으로 삭제되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Percent 아이템 삭제 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  void _showDialog({PercentItem? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final nameController = TextEditingController(text: item?.name ?? '');
    final percentageController = TextEditingController(text: item?.percentage.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Percent 아이템 추가' : 'Percent 아이템 수정'),
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
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: percentageController,
              decoration: const InputDecoration(
                labelText: '백분율',
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
              final percentage = double.tryParse(percentageController.text) ?? 0.0;
              if (item == null) {
                _createItem(titleController.text, nameController.text, percentage);
              } else {
                _updateItem(item.id, titleController.text, nameController.text, percentage);
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
                'Percent 위젯 데이터 (${_items.length}개)',
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
                  ? const Center(child: Text('Percent 아이템이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text('${item.name}: ${item.percentage}%'),
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

// Percent 데이터 모델
class PercentItem {
  final int id;
  final String title;
  final String name;
  final double percentage;

  PercentItem({
    required this.id,
    required this.title,
    required this.name,
    required this.percentage,
  });

  factory PercentItem.fromJson(Map<String, dynamic> json) {
    return PercentItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}