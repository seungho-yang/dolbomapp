import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_model.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/global_user_info.dart';
import '../alarm/alarm_add_screen.dart';
import '../alarm/alarm_setting_screen.dart';

/// AlarmTab - 알람 목록 화면 (인형별 그룹)
class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  // 선택된 인형 ai번호 (null이면 인형 목록 표시)
  int? _selectedAi;
  String? _selectedName;

  // 정렬 옵션: true = 낮은순, false = 높은순
  bool _sortAscending = true;

  // 검색
  final TextEditingController _searchController = TextEditingController();
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
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    final userIdStr = GlobalUserInfo.instance.userId;
    final userId = int.tryParse(userIdStr ?? '') ?? 0;

    if (userId > 0) {
      await alarmProvider.loadAlarms(userId);
    }
  }

  Future<void> _navigateToAddAlarm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlarmAddScreen()),
    );
    if (result == true) {
      _loadAlarms();
    }
  }

  Future<void> _navigateToEditAlarm(AlarmModel alarm) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmSettingScreen(alarm: alarm),
      ),
    );
  }

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

  String _getBotImage(int? bot) {
    switch (bot) {
      case 8: return 'assets/images/mapodong.png';
      case 13: return 'assets/images/kingstrawberry.png';
      case 14: return 'assets/images/dongdaemun.png';
      case 17: return 'assets/images/haeon.png';
      case 19: return 'assets/images/hamo.png';
      case 20: return 'assets/images/atongii.png';
      case 22: return 'assets/images/gumdoll.png';
      case 23: return 'assets/images/gumsunii.png';
      case 24: return 'assets/images/bamangii.png';
      case 25: return 'assets/images/sangii.png';
      case 26: return 'assets/images/pepper.png';
      case 27: return 'assets/images/organic.png';
      case 28: return 'assets/images/future.png';
      case 30: return 'assets/images/sun_on.png';
      case 31: return 'assets/images/jangsangii.png';
      case 32:
      case 33: return 'assets/images/jadu.png';
      case 34: return 'assets/images/rumi.png';
      case 35: return 'assets/images/gold_dragon.png';
      default: return 'assets/images/bokdongii.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // 배너
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

          // 메인 콘텐츠
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
                        Text(alarmProvider.error!,
                            style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAlarms,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                if (alarmProvider.alarms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.alarm_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('알람이 없습니다',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _navigateToAddAlarm,
                          child: const Text('알람 추가하기'),
                        ),
                      ],
                    ),
                  );
                }

                // 선택된 인형이 없으면 인형 목록 표시
                if (_selectedAi == null) {
                  return _buildDollList(alarmProvider);
                }

                // 선택된 인형의 알람 목록 표시
                return _buildAlarmList(alarmProvider);
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

  /// 1단계: 인형 목록 (알람이 있는 인형만)
  Widget _buildDollList(AlarmProvider alarmProvider) {
    // 인형별 알람 그룹핑
    final Map<int, List<AlarmModel>> grouped = {};
    final Map<int, String> nameMap = {};

    for (final alarm in alarmProvider.alarms) {
      if (alarm.ai != null) {
        grouped.putIfAbsent(alarm.ai!, () => []).add(alarm);
        if (alarm.name != null) {
          nameMap[alarm.ai!] = alarm.name!;
        }
      }
    }

    // 검색어로 필터링
    final allAiList = grouped.keys.toList();
    final filteredAiList = _searchQuery.isEmpty
        ? allAiList
        : allAiList
            .where((ai) => ai.toString().contains(_searchQuery))
            .toList();

    // 인형번호순 정렬
    filteredAiList.sort((a, b) => _sortAscending ? a.compareTo(b) : b.compareTo(a));
    final userProvider = context.watch<UserProvider>();

    return Column(
      children: [
        // 검색창
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '인형 번호로 검색',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade400,
                          size: 20,
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

        // 정렬 옵션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: _sortAscending,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    items: const [
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('번호 낮은순'),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('번호 높은순'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortAscending = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // 목록
        Expanded(
          child: RefreshIndicator(
      onRefresh: _loadAlarms,
      child: filteredAiList.isEmpty
          ? Center(
              child: Text(
                _searchQuery.isEmpty ? '알람이 없습니다' : '검색 결과가 없습니다.',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              ),
            )
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: filteredAiList.length,
        itemBuilder: (context, index) {
          final ai = filteredAiList[index];
          final alarms = grouped[ai]!;
          final name = nameMap[ai] ?? '';
          final onCount = alarms.where((a) => a.on == true).length;

          // UserProvider에서 인형 정보 찾기
          final user = userProvider.users
              .where((u) => u.id == ai.toString())
              .firstOrNull;
          final botImage = user?.botImagePath ?? _getBotImage(ai);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAi = ai;
                _selectedName = name;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 인형 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      botImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF258AE4).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(Icons.smart_toy,
                              color: Color(0xFF258AE4), size: 28),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 인형 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$ai',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 알람 개수
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${alarms.length}개',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF258AE4),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$onCount개 활성',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          );
        },
      ),
          ),
        ),
      ],
    );
  }

  /// 2단계: 선택된 인형의 알람 목록
  Widget _buildAlarmList(AlarmProvider alarmProvider) {
    final alarms = alarmProvider.alarms
        .where((a) => a.ai == _selectedAi)
        .toList();

    return Column(
      children: [
        // 뒤로가기 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _selectedAi = null;
                  _selectedName = null;
                }),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  _getBotImage(_selectedAi),
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$_selectedAi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (_selectedName != null && _selectedName!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  _selectedName!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${alarms.length}개',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF258AE4),
                ),
              ),
            ],
          ),
        ),

        // 알람 목록
        Expanded(
          child: alarms.isEmpty
              ? Center(
                  child: Text('등록된 알람이 없습니다.',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                )
              : RefreshIndicator(
                  onRefresh: _loadAlarms,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      return _buildAlarmItem(alarms[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  /// 알람 아이템
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        alarm.time ?? '',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isOn ? Colors.black : const Color(0xFFD8D8D8),
                        ),
                      ),
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
                Row(
                  children: [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF0F4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
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
                Expanded(
                  child: alarm.classification == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: allDays.asMap().entries.map((entry) {
                            final day = entry.value;
                            final isSelected = selectedDays.contains(day);
                            final isWeekend = entry.key == 0 || entry.key == 6;
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

  Widget _buildDayLabel(String day, bool isSelected, bool isOn, bool isWeekend) {
    const primaryColor = Color(0xFF258AE4);

    Color textColor;
    Color? backgroundColor;

    if (!isOn) {
      textColor = const Color(0xFFD8D8D8);
      backgroundColor = isSelected ? const Color(0xFFD8D8D8).withValues(alpha: 0.3) : null;
    } else if (isSelected) {
      textColor = Colors.white;
      backgroundColor = primaryColor;
    } else if (isWeekend) {
      textColor = Colors.red.shade300;
    } else {
      textColor = Colors.grey.shade500;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected && isOn
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
