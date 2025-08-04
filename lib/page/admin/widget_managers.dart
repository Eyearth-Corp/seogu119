import 'package:flutter/material.dart';
import '../data/admin_service.dart';

// Type2 위젯 관리자 (계속)
class Type2WidgetManager extends StatefulWidget {
  final int dashboardId;

  const Type2WidgetManager({super.key, required this.dashboardId});

  @override
  State<Type2WidgetManager> createState() => _Type2WidgetManagerState();
}

class _Type2WidgetManagerState extends State<Type2WidgetManager> {
  List<Type2Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(Type2WidgetManager oldWidget) {
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

// Type3 위젯 관리자
class Type3WidgetManager extends StatefulWidget {
  final int dashboardId;

  const Type3WidgetManager({super.key, required this.dashboardId});

  @override
  State<Type3WidgetManager> createState() => _Type3WidgetManagerState();
}

class _Type3WidgetManagerState extends State<Type3WidgetManager> {
  List<Type3Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(Type3WidgetManager oldWidget) {
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

// Type4 위젯 관리자
class Type4WidgetManager extends StatefulWidget {
  final int dashboardId;

  const Type4WidgetManager({super.key, required this.dashboardId});

  @override
  State<Type4WidgetManager> createState() => _Type4WidgetManagerState();
}

class _Type4WidgetManagerState extends State<Type4WidgetManager> {
  List<Type4Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(Type4WidgetManager oldWidget) {
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
          '${AdminService.baseUrl}/api/DashBoardType4?id=${widget.dashboardId}');
      
      if (response != null && response['success'] == true) {
        final type4Data = response['data']['type4_data'] as List<dynamic>;
        setState(() {
          _items = type4Data.map((item) => Type4Item.fromJson(item)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Type4 데이터 로드 실패: ${AdminService.getErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createItem(String title, String processed, String rate) async {
    try {
      final response = await AdminService.postToURL(
        '${AdminService.baseUrl}/api/DashBoardType4',
        {
          'dashboard_id': widget.dashboardId,
          'title': title,
          'processed': processed,
          'rate': rate,
          'display_order': _items.length,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type4 아이템이 성공적으로 생성되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type4 아이템 생성 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _updateItem(int id, String title, String processed, String rate) async {
    try {
      final response = await AdminService.putToURL(
        '${AdminService.baseUrl}/api/DashBoardType4/$id',
        {
          'title': title,
          'processed': processed,
          'rate': rate,
        },
      );

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type4 아이템이 성공적으로 수정되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type4 아이템 수정 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await AdminService.deleteFromURL(
          '${AdminService.baseUrl}/api/DashBoardType4/$id');

      if (response != null && response['success'] == true) {
        _showSuccessSnackBar('Type4 아이템이 성공적으로 삭제되었습니다.');
        _loadItems();
      }
    } catch (e) {
      _showErrorSnackBar('Type4 아이템 삭제 실패: ${AdminService.getErrorMessage(e)}');
    }
  }

  void _showDialog({Type4Item? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final processedController = TextEditingController(text: item?.processed ?? '');
    final rateController = TextEditingController(text: item?.rate ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Type4 아이템 추가' : 'Type4 아이템 수정'),
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
              controller: processedController,
              decoration: const InputDecoration(
                labelText: '처리된 수',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: '비율',
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
                _createItem(
                  titleController.text,
                  processedController.text,
                  rateController.text,
                );
              } else {
                _updateItem(
                  item.id,
                  titleController.text,
                  processedController.text,
                  rateController.text,
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
                'Type4 위젯 데이터 (${_items.length}개)',
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
                  ? const Center(child: Text('Type4 아이템이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text('처리: ${item.processed}, 비율: ${item.rate}'),
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

// 데이터 모델 클래스들
class DashboardMaster {
  final int id;
  final String dashboardName;
  final String dashboardDescription;
  final String widgetType;
  final DateTime createdAt;
  final DateTime updatedAt;

  DashboardMaster({
    required this.id,
    required this.dashboardName,
    required this.dashboardDescription,
    required this.widgetType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardMaster.fromJson(Map<String, dynamic> json) {
    return DashboardMaster(
      id: json['id'],
      dashboardName: json['dashboard_name'],
      dashboardDescription: json['dashboard_description'] ?? '',
      widgetType: json['widget_type'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Type1Item {
  final int id;
  final String title;
  final String value;
  final String unit;

  Type1Item({
    required this.id,
    required this.title,
    required this.value,
    required this.unit,
  });

  factory Type1Item.fromJson(Map<String, dynamic> json) {
    return Type1Item(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}

class Bbs1Item {
  final int id;
  final String title;
  final String status;
  final String detail;

  Bbs1Item({
    required this.id,
    required this.title,
    required this.status,
    required this.detail,
  });

  factory Bbs1Item.fromJson(Map<String, dynamic> json) {
    return Bbs1Item(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

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

class Type4Item {
  final int id;
  final String title;
  final String processed;
  final String rate;

  Type4Item({
    required this.id,
    required this.title,
    required this.processed,
    required this.rate,
  });

  factory Type4Item.fromJson(Map<String, dynamic> json) {
    return Type4Item(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      processed: json['processed'] ?? '',
      rate: json['rate'] ?? '',
    );
  }
}