import 'package:flutter/material.dart';

class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allAlarms = [];
  List<Map<String, dynamic>> _filteredAlarms = [];

  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 임시 더미 데이터 (30개)
  void _loadAlarms() {
    _allAlarms = List.generate(30, (index) {
      return {
        'id': '${10000 + index}',
        'time': '${(index % 12) + 1}:${(index % 60).toString().padLeft(2, '0')}',
        'period': index % 2 == 0 ? '오전' : '오후',
        'days': ['월', '화', '수', '목', '금', '토', '일'], // 7일 모두 표시
        'selectedDays': index % 2 == 0
            ? ['월', '화', '수', '목', '금']
            : ['토', '일'], // 선택된 요일
        'isOn': index % 3 != 0, // 3개 중 2개는 켜짐
        'label': index % 5 == 0 ? '약 복용 시간' : '',
      };
    });
    _filteredAlarms = List.from(_allAlarms);
  }

  void _filterAlarms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAlarms = List.from(_allAlarms);
      } else {
        _filteredAlarms = _allAlarms
            .where((alarm) => alarm['id'].toString().contains(query))
            .toList();
      }
      _currentPage = 0; // 검색 시 페이지 리셋
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMoreAlarms();
    }
  }

  void _loadMoreAlarms() {
    if (_isLoadingMore) return;

    final totalPages = (_filteredAlarms.length / _itemsPerPage).ceil();
    if (_currentPage >= totalPages - 1) return;

    setState(() {
      _isLoadingMore = true;
    });

    // 페이지네이션 시뮬레이션
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> get _displayedAlarms {
    final endIndex = (_currentPage + 1) * _itemsPerPage;
    return _filteredAlarms.take(endIndex.clamp(0, _filteredAlarms.length)).toList();
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

          // 검색창 (예쁜 디자인)
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
            child: _displayedAlarms.isEmpty
                ? const Center(
                    child: Text(
                      '알람이 없습니다',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: _displayedAlarms.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _displayedAlarms.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildAlarmItem(_displayedAlarms[index]);
                    },
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
          // 시간 표시
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 인형 번호 (맨 위로 이동)
                Text(
                  '인형 번호: ${alarm['id']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // 시간
                Text(
                  '${alarm['period']} ${alarm['time']}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: alarm['isOn'] ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // 라벨
                if (alarm['label'].isNotEmpty)
                  Text(
                    alarm['label'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 8),
                // 시계 아이콘과 요일 배지 (한 줄로)
                Row(
                  children: [
                    // 시계 아이콘 (맨 왼쪽)
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: alarm['isOn'] ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    // 요일 배지 (월화수목금토일 한 줄로 표시)
                    ...List.generate((alarm['days'] as List<String>).length, (i) {
                      final day = (alarm['days'] as List<String>)[i];
                      final isSelected = (alarm['selectedDays'] as List<String>).contains(day);
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: alarm['isOn'] && isSelected
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 11,
                              color: alarm['isOn'] && isSelected
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
            value: alarm['isOn'],
            onChanged: (value) {
              setState(() {
                alarm['isOn'] = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? '알람 켜짐' : '알람 꺼짐'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            activeColor: Colors.blue,
          ),

          // 세로 점 3개 메뉴 버튼
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
            onPressed: () {
              // 알람 설정 화면으로 이동 (기존 Android 앱과 동일)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('알람 설정 화면 (${alarm['id']}) - 추후 구현'),
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
