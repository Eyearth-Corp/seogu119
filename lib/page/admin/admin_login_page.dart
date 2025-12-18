import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';
import '../data/admin_service.dart';
import 'new_admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingToken = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Analytics: 페이지 뷰 추적
    AnalyticsService.trackPageView(
      route: '/admin/login',
      name: '관리자 로그인',
    );
    _checkAutoLogin();
  }

  /// 자동 로그인 확인
  Future<void> _checkAutoLogin() async {
    try {
      // 저장된 토큰 로드
      await AdminService.loadStoredToken();
      
      // 토큰이 유효한지 확인
      if (AdminService.isLoggedIn) {
        final isValid = await AdminService.validateToken();
        if (isValid && mounted) {
          print('🔄 자동 로그인 성공! 관리자 대시보드로 이동');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const NewAdminDashboardPage(),
            ),
          );
          return;
        }
      }
      
      print('ℹ️ 자동 로그인 불가 - 로그인 화면 표시');
    } catch (e) {
      print('💥 자동 로그인 확인 중 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingToken = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Analytics: 로그인 시도 추적
    AnalyticsService.trackClick(
      '/admin/login',
      'btn_login',
      elementText: '로그인',
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AdminService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Analytics: 로그인 성공
        AnalyticsService.trackCustomEvent(
          eventType: 'login_success',
          pageRoute: '/admin/login',
          eventData: {
            'username': _usernameController.text.trim(),
          },
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NewAdminDashboardPage(),
          ),
        );
      } else {
        // Analytics: 로그인 실패
        AnalyticsService.trackCustomEvent(
          eventType: 'login_failure',
          pageRoute: '/admin/login',
          eventData: {
            'reason': 'invalid_credentials',
          },
        );
        setState(() {
          _errorMessage = '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.';
        });
      }
    } catch (e) {
      // Analytics: 로그인 에러
      AnalyticsService.trackCustomEvent(
        eventType: 'login_error',
        pageRoute: '/admin/login',
        eventData: {
          'error': e.toString(),
        },
      );
      setState(() {
        _errorMessage = '로그인 중 오류가 발생했습니다: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 토큰 확인 중일 때 로딩 화면 표시
    if (_isCheckingToken) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
              SizedBox(height: 16),
              Text(
                '로그인 상태 확인 중...',
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로고 및 제목
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  '서구 골목경제 119 관리자',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  '관리자 계정으로 로그인하세요',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 14,
                    color: const Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 32),

                // 아이디 입력
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '아이디를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 8),

                // 에러 메시지
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                    fontFamily: 'NotoSans',
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            '로그인',
                            style: TextStyle(
                    fontFamily: 'NotoSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}