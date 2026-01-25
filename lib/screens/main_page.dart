import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/alarm_provider.dart';
import '../providers/signalr_provider.dart';
import '../providers/user_provider.dart';
import '../services/global_user_info.dart';
import 'tabs/home_tab.dart';
import 'tabs/message_tab.dart';
import 'tabs/alarm_tab.dart';
import 'tabs/user_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  DateTime? _lastPressedAt;

  final List<Widget> _tabs = const [
    HomeTab(),
    MessageTab(),
    AlarmTab(),
    UserTab(),
  ];

  bool _appInitialized = false;

  @override
  void initState() {
    super.initState();
    // 첫 번째 프레임 렌더링 후 초기화 시작 (UI 블로킹 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// 앱 초기화 - 사용자 데이터 로드 및 SignalR 연결
  /// Java의 Home.java 생성자와 동일한 역할
  Future<void> _initializeApp() async {
    if (_appInitialized) return;
    _appInitialized = true;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    final signalRProvider = Provider.of<SignalRProvider>(context, listen: false);

    // GlobalUserInfo 싱글톤에서 userId 가져오기 (Java의 GlobalLogin.getInstance().getUserInfo().getUserId()와 동일)
    final userId = GlobalUserInfo.instance.userId;
    if (userId != null && userId.isNotEmpty) {
      final userIdInt = int.parse(userId);

      // 1. 보호대상자 목록 로드 (Java Home.java 생성자의 API 호출과 동일)
      // GET /app?id={userId}
      debugPrint('MainPage: 보호대상자 목록 로드 시작 - userId: $userId');
      userProvider.loadUsers(userIdInt).then((_) {
        debugPrint('MainPage: 보호대상자 목록 로드 완료 - ${userProvider.users.length}명');
      }).catchError((e) {
        debugPrint('MainPage: 보호대상자 목록 로드 실패 - $e');
      });

      // 2. 알람 목록 로드
      // GET /alarm?id={userId}
      debugPrint('MainPage: 알람 목록 로드 시작 - userId: $userId');
      alarmProvider.loadAlarms(userIdInt).then((_) {
        debugPrint('MainPage: 알람 목록 로드 완료 - ${alarmProvider.alarms.length}개');
      }).catchError((e) {
        debugPrint('MainPage: 알람 목록 로드 실패 - $e');
      });

      // 3. SignalR 연결 (실시간 배터리 업데이트 등)
      signalRProvider.connect(userId).then((_) {
        debugPrint('MainPage: SignalR 연결 완료 - userId: $userId');
      }).catchError((e) {
        debugPrint('MainPage: SignalR 연결 실패 - $e');
      });
    } else {
      debugPrint('MainPage: userId가 없어서 초기화 건너뜀 (GlobalUserInfo.userId: $userId)');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final maxDuration = const Duration(seconds: 2);
    final isWarning =
        _lastPressedAt == null || now.difference(_lastPressedAt!) > maxDuration;

    if (isWarning) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('뒤로 버튼을 한번 더 누르시면 종료됩니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    // 앱 종료
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: _tabs[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/chat.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
              ),
              label: '대화',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/alarm.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
              ),
              label: '알람',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/person_pin.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
              ),
              label: '보호대상자',
            ),
          ],
        ),
      ),
    );
  }
}
