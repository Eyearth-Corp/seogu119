import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/admin_service.dart';
import 'admin_login_page.dart';
import 'widget/admin_sidebar.dart';
import 'widget/dashboard_overview_widget.dart';
import 'widget/merchant_management_widget.dart';
import 'widget/data_management_widget.dart';

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
  AdminPageType _currentPage = AdminPageType.dashboard;
  bool _isCollapsed = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '로그아웃',
          style: GoogleFonts.notoSansKr(),
        ),
        content: Text(
          '정말 로그아웃하시겠습니까?',
          style: GoogleFonts.notoSansKr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: GoogleFonts.notoSansKr(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: GoogleFonts.notoSansKr(color: Colors.red),
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

  Widget _getCurrentPageWidget() {
    switch (_currentPage) {
      case AdminPageType.dashboard:
        return const DashboardOverviewWidget();
      case AdminPageType.merchants:
        return const MerchantManagementWidget();
      case AdminPageType.data:
        return const DataManagementWidget();
      case AdminPageType.settings:
        return const Center(
          child: Text(
            '설정 페이지 (준비 중)',
            style: TextStyle(fontSize: 18),
          ),
        );
    }
  }

  String _getCurrentPageTitle() {
    switch (_currentPage) {
      case AdminPageType.dashboard:
        return '대시보드';
      case AdminPageType.merchants:
        return '가맹점 관리';
      case AdminPageType.data:
        return '데이터 관리';
      case AdminPageType.settings:
        return '설정';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 사이드바
          AdminSidebar(
            currentPage: _currentPage,
            isCollapsed: _isCollapsed,
            onPageChanged: (page) => setState(() => _currentPage = page),
            onToggleCollapse: () => setState(() => _isCollapsed = !_isCollapsed),
            onLogout: _logout,
          ),
          
          // 메인 컨텐츠
          Expanded(
            child: Column(
              children: [
                // 헤더
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getCurrentPageTitle(),
                        style: GoogleFonts.notoSansKr(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      
                      // 사용자 정보
                      Container(
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
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Admin',
                              style: GoogleFonts.notoSansKr(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 페이지 컨텐츠
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _getCurrentPageWidget(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}