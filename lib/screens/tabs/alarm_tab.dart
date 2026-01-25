import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_model.dart';
import '../../providers/alarm_provider.dart';
import '../../services/global_user_info.dart';
import '../alarm/alarm_add_screen.dart';
import '../alarm/alarm_setting_screen.dart';

/// AlarmTab - 알람 목록 화면
/// Java의 Alarm.java Fragment와 동일한 기능
class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlarms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    // GlobalUserInfo 사용 (MainPage와 동일하게)
    final userIdStr = GlobalUserInfo.instance.userId;
    final userId = int.tryParse(userIdStr ?? '') ?? 0;

    debugPrint('AlarmTab: 알람 로드 시도 - userId: $userId');

    if (userId > 0) {
      await alarmProvider.loadAlarms(userId);
    } else {
      debugPrint('AlarmTab: userId가 유효하지 않음 ($userIdStr)');
    }
  }

  /// 알람 추가 화면으로 이동
  Future<void> _navigateToAddAlarm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlarmAddScreen()),
    );

    if (result == true) {
      // 알람이 추가되면 목록 새로고침
      _loadAlarms();
    }
  }

  /// 알람 수정 화면으로 이동
  Future<void> _navigateToEditAlarm(AlarmModel alarm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmSettingScreen(alarm: alarm),
      ),
    );

    if (result != null) {
      // 알람이 수정되면 목록 새로고침
      _loadAlarms();
    }
  }

  /// 알람 삭제 확인 다이얼로그
  Future<void> _showDeleteDialog(AlarmModel alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${alarm.name ?? ''} ${alarm.title ?? ''}'),
        content: const Text('알람을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && alarm.id != null) {
      final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
      final success = await alarmProvider.deleteAlarm(alarm.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? "'${alarm.title}' 알람이 삭제 되었습니다."
                  : '알람 삭제에 실패했습니다.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  /// 수정/삭제 다이얼로그 (Java alarm_alert_view.xml과 동일)
  void _showActionDialog(AlarmModel alarm) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단: 인형 이미지 + 이름 (alarm_alert_view.xml과 동일)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 인형 이미지 - 40x40dp
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      _getBotImage(alarm.ai),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF258AE4).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.alarm,
                            color: Color(0xFF258AE4),
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 인형 이름 + AI 번호 - 25dp bold
                  Flexible(
                    child: Text(
                      '${alarm.name ?? ''} ${alarm.ai ?? ''}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // 하단: 수정하기, 삭제하기 버튼 (가로 배치) - #258AE4 배경
            Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF258AE4),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  // 수정하기 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToEditAlarm(alarm);
                      },
                      child: SizedBox(
                        height: 60,
                        child: Center(
                          child: Image.asset(
                            'assets/images/update_button.png',
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                '수정하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 삭제하기 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteDialog(alarm);
                      },
                      child: SizedBox(
                        height: 60,
                        child: Center(
                          child: Image.asset(
                            'assets/images/delete_button.png',
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                '삭제하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 알람 ON/OFF 토글
  Future<void> _toggleAlarm(AlarmModel alarm) async {
    if (alarm.id == null) return;

    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    final userId = int.tryParse(GlobalUserInfo.instance.userId ?? '') ?? 0;

    final success = await alarmProvider.toggleAlarm(alarm.id!, userId);

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('알람 상태 변경에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// bot 값에 따른 이미지 경로 반환
  String _getBotImage(int? bot) {
    switch (bot) {
      case 8:
        return 'assets/images/mapodong.png';
      case 13:
        return 'assets/images/kingstrawberry.png';
      case 14:
        return 'assets/images/dongdaemun.png';
      case 17:
        return 'assets/images/haeon.png';
      case 19:
        return 'assets/images/hamo.png';
      case 20:
        return 'assets/images/atongii.png';
      case 22:
        return 'assets/images/gumdoll.png';
      case 23:
        return 'assets/images/gumsunii.png';
      case 24:
        return 'assets/images/bamangii.png';
      case 25:
        return 'assets/images/sangii.png';
      case 26:
        return 'assets/images/pepper.png';
      case 27:
        return 'assets/images/organic.png';
      case 28:
        return 'assets/images/future.png';
      case 30:
        return 'assets/images/sun_on.png';
      case 31:
        return 'assets/images/jangsangii.png';
      case 32:
      case 33:
        return 'assets/images/jadu.png';
      case 34:
        return 'assets/images/rumi.png';
      case 35:
        return 'assets/images/gold_dragon.png';
      default:
        return 'assets/images/bokdongii.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // alarm_list_background
      body: Column(
        children: [
          // 배너 이미지 - Java fragment_alarm.xml과 동일
          Container(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/alarm_banner.png',
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF258AE4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '알람 설정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF258AE4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD8D8D8)),
              ),
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '인형 번호로 검색',
                  hintStyle: const TextStyle(
                    color: Color(0xFFD8D8D8),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFD8D8D8),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFFD8D8D8),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // 알람 목록
          Expanded(
            child: Consumer<AlarmProvider>(
              builder: (context, alarmProvider, child) {
                if (alarmProvider.isLoading && !alarmProvider.isLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (alarmProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          alarmProvider.error!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAlarms,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                // 검색 필터 적용
                final filteredAlarms = _searchQuery.isEmpty
                    ? alarmProvider.alarms
                    : alarmProvider.searchByAi(_searchQuery);

                if (filteredAlarms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alarm_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '알람이 없습니다',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _navigateToAddAlarm,
                          child: const Text('알람 추가하기'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadAlarms,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: filteredAlarms.length,
                    itemBuilder: (context, index) {
                      return _buildAlarmItem(filteredAlarms[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
          onPressed: _navigateToAddAlarm,
          backgroundColor: const Color(0xFF258AE4),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 알람 아이템 - Java alarm_list_row.xml과 동일한 구조
  Widget _buildAlarmItem(AlarmModel alarm) {
    final isOn = alarm.on ?? false;
    final allDays = ['일', '월', '화', '수', '목', '금', '토'];
    final selectedDays = alarm.selectedDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단 - 흰색 배경, 둥근 상단 모서리
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 10, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: AI ID, 시간, 제목
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI ID (인형 번호)
                      Text(
                        '${alarm.ai ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 1),
                      // 시간 - 30dp 크기
                      Text(
                        alarm.time ?? '',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isOn ? Colors.black : const Color(0xFFD8D8D8),
                        ),
                      ),
                      // 제목 - 20dp 크기
                      Text(
                        alarm.title ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          color: isOn ? Colors.black : const Color(0xFFD8D8D8),
                        ),
                      ),
                    ],
                  ),
                ),
                // 오른쪽: ON/OFF 토글 + 더보기 버튼
                Row(
                  children: [
                    // ON/OFF 토글 - 90x45dp 크기
                    GestureDetector(
                      onTap: () => _toggleAlarm(alarm),
                      child: Image.asset(
                        isOn
                            ? 'assets/images/truebutton.png'
                            : 'assets/images/falsebutton.png',
                        width: 90,
                        height: 45,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Switch(
                            value: isOn,
                            onChanged: (value) => _toggleAlarm(alarm),
                            activeColor: const Color(0xFF258AE4),
                          );
                        },
                      ),
                    ),
                    // 더보기 버튼
                    GestureDetector(
                      onTap: () => _showActionDialog(alarm),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/alarm_more.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 하단 - #EFF0F4 배경, 둥근 하단 모서리, 알람 아이콘 + 요일
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF0F4), // alarm_bottom_background
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                // 알람 ON/OFF 아이콘
                Image.asset(
                  isOn
                      ? 'assets/images/alarm_on.png'
                      : 'assets/images/alarm_off.png',
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.access_time,
                      size: 28,
                      color: isOn ? const Color(0xFF258AE4) : const Color(0xFFD8D8D8),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // 요일 또는 날짜
                Expanded(
                  child: alarm.classification == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: allDays.asMap().entries.map((entry) {
                            final day = entry.value;
                            final isSelected = selectedDays.contains(day);
                            final isWeekend = entry.key == 0 || entry.key == 6; // 일, 토
                            return _buildDayLabel(day, isSelected, isOn, isWeekend);
                          }).toList(),
                        )
                      : Text(
                          alarm.division ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isOn ? Colors.black : const Color(0xFFD8D8D8),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 요일 라벨 위젯 - Java와 동일한 스타일
  Widget _buildDayLabel(String day, bool isSelected, bool isOn, bool isWeekend) {
    Color textColor;
    if (!isOn) {
      textColor = const Color(0xFFD8D8D8);
    } else if (isSelected) {
      textColor = const Color(0xFF258AE4);
    } else if (isWeekend) {
      textColor = Colors.red;
    } else {
      textColor = Colors.black;
    }

    return Text(
      day,
      style: TextStyle(
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: textColor,
      ),
    );
  }
}
