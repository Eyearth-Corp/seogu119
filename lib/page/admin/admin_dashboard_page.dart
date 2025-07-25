import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import 'admin_login_page.dart';

enum AdminPageType {
  dashboard,
  merchants,
  data,
  settings,
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '로그아웃',
          style: TextStyle(fontFamily: 'NotoSans'),
        ),
        content: const Text(
          '정말 로그아웃하시겠습니까?',
          style: TextStyle(fontFamily: 'NotoSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'NotoSans',
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '로그아웃',
              style: TextStyle(
                fontFamily: 'NotoSans',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AdminService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminLoginPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '관리자 대시보드',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '로그아웃',
                        style: TextStyle(fontFamily: 'NotoSans'),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF374151),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 20),
              Text(
                '관리자 대시보드',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '새로운 관리자 대시보드를 준비 중입니다.',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}