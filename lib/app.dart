import 'package:flutter/material.dart';
import 'package:seogu119/page/home_page.dart';
import 'package:seogu119/page/admin/admin_login_page.dart';
import 'package:seogu119/page/admin/admin_dashboard_page.dart';
import 'package:seogu119/page/admin/admin_guard.dart' hide AdminDashboardPage;
import 'package:seogu119/page/data/admin_service.dart';
import 'core/fonts.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '서구 골목',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: SeoguFonts.primaryFont,
        fontFamilyFallback: SeoguFonts.fontFallbacks,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/admin': (context) => const AdminLoginPage(),
      },
      onGenerateRoute: (settings) {
        // 관리자 관련 라우팅 처리
        if (settings.name?.startsWith('/admin') == true) {
          switch (settings.name) {
            case '/admin':
              return MaterialPageRoute(
                builder: (context) => const AdminLoginPage(),
                settings: settings,
              );
            case '/admin/dashboard':
              return MaterialPageRoute(
                builder: (context) => AdminService.isLoggedIn
                    ? const AdminDashboardPage()
                    : const AdminLoginPage(),
                settings: settings,
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const AdminLoginPage(),
                settings: settings,
              );
          }
        }
        return null;
      },
    );
  }
}

