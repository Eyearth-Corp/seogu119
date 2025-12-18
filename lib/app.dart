import 'package:flutter/material.dart';
import 'package:seogu119/page/admin/admin_login_page.dart';
import 'package:seogu119/page/admin/dong_admin_dashboard_page.dart';
import 'package:seogu119/page/home_page.dart';
import 'package:seogu119/page/data/admin_service.dart';
import 'package:seogu119/services/analytics_service.dart';
import 'core/fonts.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    // Analytics 세션 시작
    AnalyticsService.startSession();
  }

  /// 관리자 인증 상태 확인
  Future<bool> _checkAdminAuth() async {
    try {
      await AdminService.loadStoredToken();
      if (AdminService.isLoggedIn) {
        return await AdminService.validateToken();
      }
      return false;
    } catch (e) {
      print('인증 확인 중 오류: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '서구 골목경제 119',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: SeoguFonts.primaryFont,
        fontFamilyFallback: SeoguFonts.fontFallbacks,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 2560,
            height: 1440,
            child: HomePage(),
          ),
        ),
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
                builder: (context) => FutureBuilder<bool>(
                  future: _checkAdminAuth(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        backgroundColor: Color(0xFFF5F7FA),
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '인증 확인 중...',
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 16,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.data == true) {
                      return FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 2560,
                          height: 1440,
                          child: HomePage(),
                        ),
                      );
                    } else {
                      return const AdminLoginPage();
                    }
                  },
                ),
                settings: settings,
              );
            default:
              // 동별 관리자 대시보드 라우팅 처리
              if (settings.name?.startsWith('/admin/dong/') == true) {
                final dongName = settings.name!.split('/').last;
                return MaterialPageRoute(
                  builder: (context) => FutureBuilder<bool>(
                    future: _checkAdminAuth(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          backgroundColor: Color(0xFFF5F7FA),
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '인증 확인 중...',
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 16,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      if (snapshot.data == true) {
                        return DongAdminDashboardPage(dongName: dongName);
                      } else {
                        return const AdminLoginPage();
                      }
                    },
                  ),
                  settings: settings,
                );
              }
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

