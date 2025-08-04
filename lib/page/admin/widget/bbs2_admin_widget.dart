import 'package:flutter/material.dart';
import '../../data/admin_service.dart';

class Bbs2AdminWidget extends StatefulWidget {
  final int dashboardId;

  const Bbs2AdminWidget({super.key, required this.dashboardId});

  @override
  State<Bbs2AdminWidget> createState() => _Bbs2AdminWidgetState();
}

class _Bbs2AdminWidgetState extends State<Bbs2AdminWidget> {
  List<Bbs2Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(Bbs2AdminWidget oldWidget) {
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
          '${AdminService.baseUrl}/api/DashBoardBbs2?id=${widget.dashboardId}');
      
      if (response != null && response['success'] == true) {
        final bbs2Data = response['data']['bbs2_data'] as List<dynamic>;
        setState(() {
          _items = bbs2Data.map((item) => Bbs2Item.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('BBS2 데이터 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createItem(String title, String detail) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/DashBoardBbs2',
        {
          'dashboard_id': widget.dashboardId,
          'title': title,
          'detail': detail,
          'display_order': _items.length,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('BBS2 아이템이 성공적으로 생성되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('BBS2 아이템 생성 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _updateItem(int id, String title, String detail) async {
    try {
      final response = await AdminService.putToURL(
        '${AdminService.baseUrl}/api/DashBoardBbs2/$id',
        {
          'title': title,
          'detail': detail,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('BBS2 아이템이 성공적으로 수정되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('BBS2 아이템 수정 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/DashBoardBbs2/$id');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('BBS2 아이템이 성공적으로 삭제되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('BBS2 아이템 삭제 실패: ${AdminService.getErrorMessage(e)}');
      print(AdminService.getErrorMessage(e));
    }
  }

  void _showDialog({Bbs2Item? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final detailController = TextEditingController(text: item?.detail ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'BBS2 아이템 추가' : 'BBS2 아이템 수정'),
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
              controller: detailController,
              decoration: const InputDecoration(
                labelText: '상세 내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
                _createItem(
                  titleController.text,
                  detailController.text,
                );
              } else {
                _updateItem(
                  item.id,
                  titleController.text,
                  detailController.text,
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
                'BBS2 위젯 데이터 (${_items.length}개)',
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
                  ? const Center(child: Text('BBS2 아이템이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text(
                              item.detail,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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

// BBS2 데이터 모델
class Bbs2Item {
  final int id;
  final String title;
  final String detail;

  Bbs2Item({
    required this.id,
    required this.title,
    required this.detail,
  });

  factory Bbs2Item.fromJson(Map<String, dynamic> json) {
    return Bbs2Item(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}