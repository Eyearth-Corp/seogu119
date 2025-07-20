import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import 'admin_login_page.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  
  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 로그인 상태 체크
    if (AdminService.isLoggedIn) {
      return child;
    } else {
      // 로그인이 안되어 있으면 로그인 페이지로 리다이렉트
      return const AdminLoginPage();
    }
  }
}

class AdminRouteGuard {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/admin':
        return MaterialPageRoute(
          builder: (_) => const AdminLoginPage(),
          settings: settings,
        );
      
      case '/admin/dashboard':
        return MaterialPageRoute(
          builder: (_) => const AdminGuard(
            child: AdminDashboardPage(),
          ),
          settings: settings,
        );
      
      default:
        return null;
    }
  }
}

// AdminDashboardPage import를 위한 lazy import
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 실제 AdminDashboardPage를 동적으로 로드
    return FutureBuilder(
      future: _loadAdminDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data as Widget;
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Widget> _loadAdminDashboard() async {
    // 동적 import (실제로는 직접 import하지만 예시용)
    const adminDashboard = _AdminDashboardPageImpl();
    return adminDashboard;
  }
}

// 실제 AdminDashboardPage 구현을 별도로 분리
class _AdminDashboardPageImpl extends StatelessWidget {
  const _AdminDashboardPageImpl();

  @override
  Widget build(BuildContext context) {
    // 이 부분을 실제 AdminDashboardPage 내용으로 대체
    return const Scaffold(
      body: Center(
        child: Text('Admin Dashboard'),
      ),
    );
  }
}