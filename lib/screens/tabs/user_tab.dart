import 'package:flutter/material.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 임시 더미 데이터 (25개)
  void _loadUsers() {
    _allUsers = List.generate(25, (index) {
      return {
        'id': '${20000 + index}',
        'name': '보호대상자 ${index + 1}',
        'battery': (index % 4) == 0
            ? 'full'
            : (index % 4) == 1
                ? 'middle'
                : (index % 4) == 2
                    ? 'low'
                    : 'battery',
        'status': index % 7 == 0 ? '비활성' : '활성',
      };
    });
    _filteredUsers = List.from(_allUsers);
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers
            .where((user) => user['id'].toString().contains(query))
            .toList();
      }
      _currentPage = 1; // 검색 시 첫 페이지로 리셋
    });
  }

  int get _totalPages {
    return (_filteredUsers.length / _itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> get _displayedUsers {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredUsers.sublist(
      startIndex,
      endIndex > _filteredUsers.length ? _filteredUsers.length : endIndex,
    );
  }

  String _getBatteryImage(String battery) {
    switch (battery) {
      case 'full':
        return 'assets/images/full.png';
      case 'middle':
        return 'assets/images/middle.png';
      case 'low':
        return 'assets/images/low.png';
      default:
        return 'assets/images/battery.png';
    }
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
                const SnackBar(content: Text('보호대상자 도움말 (추후 구현)')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/user_banner.png',
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 검색창 (알람 탭과 동일한 예쁜 디자인)
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
                              _filterUsers('');
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _filterUsers(value);
                  });
                },
              ),
            ),
          ),

          // 사용자 목록
          Expanded(
            child: _displayedUsers.isEmpty
                ? const Center(
                    child: Text(
                      '보호대상자가 없습니다',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _displayedUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserItem(_displayedUsers[index]);
                    },
                  ),
          ),

          // 페이지네이션 (숫자만)
          if (_filteredUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageNumbers(),
              ),
            ),

          const SizedBox(height: 60), // 하단 네비게이션 여백
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];
    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (_currentPage + 2).clamp(1, _totalPages);

    // 시작 부분에 ... 추가
    if (startPage > 1) {
      pageButtons.add(_buildPageButton(1));
      if (startPage > 2) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey)),
        ));
      }
    }

    // 페이지 번호들
    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(i));
    }

    // 끝 부분에 ... 추가
    if (endPage < _totalPages) {
      if (endPage < _totalPages - 1) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey)),
        ));
      }
      pageButtons.add(_buildPageButton(_totalPages));
    }

    return pageButtons;
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == _currentPage;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = pageNumber;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentPage ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPage ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            color: isCurrentPage ? Colors.white : Colors.black,
            fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final batteryImage = _getBatteryImage(user['battery']);

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user['name']} 상세정보 (추후 구현)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
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
            // 프로필 아이콘
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.purple,
                size: 36,
              ),
            ),

            const SizedBox(width: 16),

            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user['status'] == '활성'
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['status'],
                          style: TextStyle(
                            fontSize: 12,
                            color: user['status'] == '활성'
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '인형 번호: ${user['id']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 배터리 이미지
            Image.asset(
              batteryImage,
              width: 32,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}
