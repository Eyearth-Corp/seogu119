import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import 'admin_login_page.dart';
import 'admin_dashboard_page.dart';

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