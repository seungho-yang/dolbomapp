import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;

  Future<void> _handleKakaoLogin() async {
    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 카카오 로그인 실행
    final success = await authProvider.loginWithKakao();

    setState(() {
      _isLoggingIn = false;
    });

    if (!mounted) return;

    if (success) {
      // 로그인 성공 - MainPage로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      // 로그인 실패 - 에러 메시지 표시
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        authProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //Stack 여러 위젯을 겹쳐서 배치, 로고(중앙) + 하단 이미지 구조에 적합
      body: Stack(
        //Stack 안에 들어갈 위젯 목록
        children: [
          // 중앙 로고
          Center(
            child: Image.asset(
              'assets/images/login_logo.png',
              width: 180,
              height: 180,
            ),
          ),
          // 카카오 로그인 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: GestureDetector(
                onTap: _isLoggingIn ? null : _handleKakaoLogin,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: _isLoggingIn ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/images/kakao_login_btn.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (_isLoggingIn)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // 하단 이미지
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Image.asset(
                'assets/images/login_bottom.png',
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
