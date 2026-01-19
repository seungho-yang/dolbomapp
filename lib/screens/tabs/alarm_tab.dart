import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _allAlarms = [];
  List<Map<String, dynamic>> _filteredAlarms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      setState(() {
        _error = '로그인이 필요합니다.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _apiService.getAlarms(int.parse(userId));

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        setState(() {
          _allAlarms = data.map((item) => Map<String, dynamic>.from(item)).toList();
          _filteredAlarms = List.from(_allAlarms);
          _isLoading = false;
        });
      } else {
        setState(() {
          _allAlarms = [];
          _filteredAlarms = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('알람 로드 실패: $e');
      setState(() {
        _error = '서버 통신이 원활하지 않습니다.';
        _isLoading = false;
      });
    }
  }

  void _filterAlarms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAlarms = List.from(_allAlarms);
      } else {
        _filteredAlarms = _allAlarms
            .where((alarm) => alarm['ai'].toString().contains(query))
            .toList();
      }
    });
  }

  /// bot 값에 따른 이미지 경로 반환
  String _getBotImage(int bot) {
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

  /// division 문자열을 요일 리스트로 파싱
  List<String> _parseDivision(String? division) {
    if (division == null || division.isEmpty) return [];
    // division은 "1,2,3,4,5" 형식 또는 "월,화,수" 형식일 수 있음
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    final parts = division.split(',');

    // 숫자인 경우
    if (parts.isNotEmpty && int.tryParse(parts[0].trim()) != null) {
      return parts.map((p) {
        final idx = int.tryParse(p.trim()) ?? 0;
        return idx < days.length ? days[idx] : '';
      }).where((d) => d.isNotEmpty).toList();
    }

    // 문자열인 경우
    return parts.map((p) => p.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 배너 이미지
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알람 도움말 (추후 구현)')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/alarm_banner.png',
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
          ),

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
                              _filterAlarms('');
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _filterAlarms(value);
                  });
                },
              ),
            ),
          ),

          // 알람 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _error = null;
                                });
                                _loadAlarms();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : _filteredAlarms.isEmpty
                        ? const Center(
                            child: Text(
                              '알람이 없습니다',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAlarms,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: _filteredAlarms.length,
                              itemBuilder: (context, index) {
                                return _buildAlarmItem(_filteredAlarms[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('알람 추가 (추후 구현)')),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAlarmItem(Map<String, dynamic> alarm) {
    final id = alarm['id']?.toString() ?? '';
    final ai = alarm['ai'] ?? 0;
    final name = alarm['name']?.toString() ?? '알람';
    final title = alarm['title']?.toString() ?? '';
    final time = alarm['time']?.toString() ?? '';
    final isOn = alarm['on'] ?? false;
    final division = alarm['division']?.toString() ?? '';
    final selectedDays = _parseDivision(division);
    final allDays = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _getBotImage(alarm['imagePath'] ?? 0),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.alarm, color: Colors.blue),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // 시간 및 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 인형 번호
                Text(
                  '인형 번호: $ai',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // 시간
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isOn ? Colors.black : Colors.grey,
                  ),
                ),
                // 제목
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 8),
                // 요일
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isOn ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    ...allDays.map((day) {
                      final isSelected = selectedDays.contains(day);
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isOn && isSelected
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              color: isOn && isSelected
                                  ? Colors.blue
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // ON/OFF 스위치
          Switch(
            value: isOn,
            onChanged: (value) {
              setState(() {
                alarm['on'] = value;
              });
              // TODO: API 호출하여 알람 상태 업데이트
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '알람 켜짐' : '알람 꺼짐'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            activeColor: Colors.blue,
          ),

          // 메뉴 버튼
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('알람 설정 ($id) - 추후 구현'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
