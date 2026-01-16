import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final maxDuration = const Duration(seconds: 2);
    final isWarning = _lastPressedAt == null ||
        now.difference(_lastPressedAt!) > maxDuration;

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
