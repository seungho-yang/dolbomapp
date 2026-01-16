import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_page.dart';

class AutoLoginScreen extends StatefulWidget {
  const AutoLoginScreen({super.key});

  @override
  State<AutoLoginScreen> createState() => _AutoLoginScreenState();
}

class _AutoLoginScreenState extends State<AutoLoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // 2초 대기 (스플래시 효과)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 로그인 상태 확인
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 로그인되어 있으면 MainPage로, 아니면 LoginScreen으로
    if (authProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 중앙 로고
          Center(
            child: Image.asset(
              'assets/images/login_logo.png',
              //로고 크기 지정
              width: 170,
              height: 170,
            ),
          ),
          // 하단 이미지 특정 위치에 위젯 배치
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              //아래쪽에서 40px 띄움
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Image.asset(
                'assets/images/login_bottom.png',
                //높이만 지정 (가로는 자동)
                height: 20,
                //이미지 비율 유지하면서 영역 안에 맞춤
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
