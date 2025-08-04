import 'package:flutter/material.dart';
import '../../data/admin_service.dart';

class Type5AdminWidget extends StatefulWidget {
  final int dashboardId;

  const Type5AdminWidget({super.key, required this.dashboardId});

  @override
  State<Type5AdminWidget> createState() => _Type5AdminWidgetState();
}

class _Type5AdminWidgetState extends State<Type5AdminWidget> {
  List<Type5Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(Type5AdminWidget oldWidget) {
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
          '${AdminService.baseUrl}/api/DashBoardType5?id=${widget.dashboardId}');
      
      if (response != null && response['success'] == true) {
        final type5Data = response['data']['type5_data'] as List<dynamic>;
        setState(() {
          _items = type5Data.map((item) => Type5Item.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Type5 데이터 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createItem(String emoji, String title, String content1, String content2) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/DashBoardType5',
        {
          'dashboard_id': widget.dashboardId,
          'emoji': emoji,
          'title': title,
          'content1': content1,
          'content2': content2,
          'display_order': _items.length,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type5 아이템이 성공적으로 생성되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type5 아이템 생성 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _updateItem(int id, String emoji, String title, String content1, String content2) async {
    try {
      final response = await AdminService.putToURL(
        '${AdminService.baseUrl}/api/DashBoardType5/$id',
        {
          'emoji': emoji,
          'title': title,
          'content1': content1,
          'content2': content2,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type5 아이템이 성공적으로 수정되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type5 아이템 수정 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/DashBoardType5/$id');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type5 아이템이 성공적으로 삭제되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type5 아이템 삭제 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  void _showDialog({Type5Item? item}) {
    final emojiController = TextEditingController(text: item?.emoji ?? '');
    final titleController = TextEditingController(text: item?.title ?? '');
    final content1Controller = TextEditingController(text: item?.content1 ?? '');
    final content2Controller = TextEditingController(text: item?.content2 ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Type5 아이템 추가' : 'Type5 아이템 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(
                labelText: '이모지',
                border: OutlineInputBorder(),
                hintText: '예: 🎯',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: content1Controller,
              decoration: const InputDecoration(
                labelText: '내용 1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: content2Controller,
              decoration: const InputDecoration(
                labelText: '내용 2',
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
                _createItem(emojiController.text, titleController.text, content1Controller.text, content2Controller.text);
              } else {
                _updateItem(item.id, emojiController.text, titleController.text, content1Controller.text, content2Controller.text);
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
                'Type5 위젯 데이터 (${_items.length}개)',
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
                  ? const Center(child: Text('Type5 아이템이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            leading: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(item.title),
                            subtitle: Text('${item.content1}\n${item.content2}'),
                            isThreeLine: true,
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

// Type5 데이터 모델
class Type5Item {
  final int id;
  final String emoji;
  final String title;
  final String content1;
  final String content2;

  Type5Item({
    required this.id,
    required this.emoji,
    required this.title,
    required this.content1,
    required this.content2,
  });

  factory Type5Item.fromJson(Map<String, dynamic> json) {
    return Type5Item(
      id: json['id'] ?? 0,
      emoji: json['emoji'] ?? '',
      title: json['title'] ?? '',
      content1: json['content1'] ?? '',
      content2: json['content2'] ?? '',
    );
  }
}