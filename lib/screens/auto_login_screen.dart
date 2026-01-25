import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
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

  // 로그인 바이패스 플래그 (개발용) - true면 바로 메인화면으로
  static const bool _bypassLogin = true;
  // 테스트용 userId (실제 카카오 사용자 ID: 2285656840)
  static const String _testUserId = TestUserIds.kakaoUser;

  Future<void> _checkAutoLogin() async {
    // 로그인 바이패스 - 바로 메인화면으로
    if (_bypassLogin) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      // 테스트용 userId 설정 (GlobalUserInfo 싱글톤에도 자동 저장됨)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.setTestUser(_testUserId);
      // Provider 상태 반영 대기
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // AuthProvider 초기화 완료될 때까지 대기 (최대 5초)
    int waitCount = 0;
    while (!authProvider.isInitialized && waitCount < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitCount++;
    }

    // 최소 스플래시 표시 시간 보장 (2초)
    if (waitCount < 20) {
      await Future.delayed(Duration(milliseconds: (20 - waitCount) * 100));
    }

    if (!mounted) return;

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
