import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import '../data/dong_list.dart';
import '../../core/colors.dart';

class DongAdminDashboardPage extends StatefulWidget {
  final String dongName;

  const DongAdminDashboardPage({
    super.key,
    required this.dongName,
  });

  @override
  State<DongAdminDashboardPage> createState() => _DongAdminDashboardPageState();
}

class _DongAdminDashboardPageState extends State<DongAdminDashboardPage> {
  bool _isLoading = false;
  
  // 동 정보 가져오기
  Dong get _dong {
    return DongList.all.firstWhere(
      (dong) => dong.name == widget.dongName,
      orElse: () => DongList.all.first,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dongName} 관리자 대시보드'),
        backgroundColor: Colors.white,  
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'API 변경으로 인해 곧 업데이트 예정입니다.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}