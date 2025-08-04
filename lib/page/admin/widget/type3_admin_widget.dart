import 'package:flutter/material.dart';
import '../../data/admin_service.dart';

class Type3AdminWidget extends StatefulWidget {
  final int dashboardId;

  const Type3AdminWidget({super.key, required this.dashboardId});

  @override
  State<Type3AdminWidget> createState() => _Type3AdminWidgetState();
}

class _Type3AdminWidgetState extends State<Type3AdminWidget> {
  List<Type3Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(Type3AdminWidget oldWidget) {
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
          '${AdminService.baseUrl}/api/DashBoardType3?id=${widget.dashboardId}');
      
      if (response != null && response['success'] == true) {
        final type3Data = response['data']['type3_data'] as List<dynamic>;
        setState(() {
          _items = type3Data.map((item) => Type3Item.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Type3 데이터 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createItem(String title, String rank, String keyword, int count) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/DashBoardType3',
        {
          'dashboard_id': widget.dashboardId,
          'title': title,
          'rank': rank,
          'keyword': keyword,
          'count': count,
          'display_order': _items.length,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type3 아이템이 성공적으로 생성되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type3 아이템 생성 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _updateItem(int id, String title, String rank, String keyword, int count) async {
    try {
      final response = await AdminService.putToURL(
        '${AdminService.baseUrl}/api/DashBoardType3/$id',
        {
          'title': title,
          'rank': rank,
          'keyword': keyword,
          'count': count,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type3 아이템이 성공적으로 수정되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type3 아이템 수정 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/DashBoardType3/$id');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type3 아이템이 성공적으로 삭제되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type3 아이템 삭제 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  void _showDialog({Type3Item? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final rankController = TextEditingController(text: item?.rank ?? '');
    final keywordController = TextEditingController(text: item?.keyword ?? '');
    final countController = TextEditingController(text: item?.count.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Type3 아이템 추가' : 'Type3 아이템 수정'),
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
              controller: rankController,
              decoration: const InputDecoration(
                labelText: '순위',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keywordController,
              decoration: const InputDecoration(
                labelText: '키워드',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: countController,
              decoration: const InputDecoration(
                labelText: '개수',
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
              final count = int.tryParse(countController.text) ?? 0;
              if (item == null) {
                _createItem(
                  titleController.text,
                  rankController.text,
                  keywordController.text,
                  count,
                );
              } else {
                _updateItem(
                  item.id,
                  titleController.text,
                  rankController.text,
                  keywordController.text,
                  count,
                );
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
                'Type3 위젯 데이터 (${_items.length}개)',
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
                  ? const Center(child: Text('Type3 아이템이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text('${item.rank}. ${item.keyword} (${item.count}개)'),
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

// Type3 데이터 모델
class Type3Item {
  final int id;
  final String title;
  final String rank;
  final String keyword;
  final int count;

  Type3Item({
    required this.id,
    required this.title,
    required this.rank,
    required this.keyword,
    required this.count,
  });

  factory Type3Item.fromJson(Map<String, dynamic> json) {
    return Type3Item(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      rank: json['rank'] ?? '',
      keyword: json['keyword'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}