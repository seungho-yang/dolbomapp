import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auto_login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/alarm_provider.dart';
import 'providers/message_provider.dart';
import 'providers/signalr_provider.dart';
import 'services/kakao_login_service.dart';
import 'utils/constants.dart';

void main() {
  // Flutter 바인딩 초기화 (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  KakaoLoginService.initialize(KakaoConstants.nativeAppKey);

  runApp(const DolbomEEumApp());
}

class DolbomEEumApp extends StatelessWidget {
  const DolbomEEumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => SignalRProvider()),
      ],
      child: MaterialApp(
        title: '돌봄e음',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AutoLoginScreen(),
      ),
    );
  }
}
