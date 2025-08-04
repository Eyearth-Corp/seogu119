import 'package:flutter/material.dart';
import '../../data/admin_service.dart';

class Type2AdminWidget extends StatefulWidget {
  final int dashboardId;

  const Type2AdminWidget({super.key, required this.dashboardId});

  @override
  State<Type2AdminWidget> createState() => _Type2AdminWidgetState();
}

class _Type2AdminWidgetState extends State<Type2AdminWidget> {
  List<Type2Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(Type2AdminWidget oldWidget) {
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
          '${AdminService.baseUrl}/api/DashBoardType2?id=${widget.dashboardId}');
      
      if (response != null && response['success'] == true) {
        final type2Data = response['data']['type2_data'] as List<dynamic>;
        setState(() {
          _items = type2Data.map((item) => Type2Item.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Type2 데이터 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createItem(String title, String value) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/DashBoardType2',
        {
          'dashboard_id': widget.dashboardId,
          'title': title,
          'value': value,
          'display_order': _items.length,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type2 아이템이 성공적으로 생성되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type2 아이템 생성 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _updateItem(int id, String title, String value) async {
    try {
      final response = await AdminService.putToURL(
        '${AdminService.baseUrl}/api/DashBoardType2/$id',
        {
          'title': title,
          'value': value,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type2 아이템이 성공적으로 수정되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type2 아이템 수정 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/DashBoardType2/$id');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type2 아이템이 성공적으로 삭제되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type2 아이템 삭제 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  void _showDialog({Type2Item? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final valueController = TextEditingController(text: item?.value ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Type2 아이템 추가' : 'Type2 아이템 수정'),
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
              controller: valueController,
              decoration: const InputDecoration(
                labelText: '값',
                border: OutlineInputBorder(),
              ),
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
              if (item == null) {
                _createItem(titleController.text, valueController.text);
              } else {
                _updateItem(item.id, titleController.text, valueController.text);
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
                'Type2 위젯 데이터 (${_items.length}개)',
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
                  ? const Center(child: Text('Type2 아이템이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text(item.value),
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

// Type2 데이터 모델
class Type2Item {
  final int id;
  final String title;
  final String value;

  Type2Item({
    required this.id,
    required this.title,
    required this.value,
  });

  factory Type2Item.fromJson(Map<String, dynamic> json) {
    return Type2Item(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      value: json['value'] ?? '',
    );
  }
}