import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/message_profile_model.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  final TextEditingController _searchController = TextEditingController();

  List<MessageProfileModel> _filteredUsers = [];
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query, List<MessageProfileModel> allUsers) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(allUsers);
      } else {
        _filteredUsers = allUsers
            .where((user) => user.id?.contains(query) ?? false)
            .toList();
      }
      _currentPage = 1; // 검색 시 첫 페이지로 리셋
    });
  }

  int get _totalPages {
    return (_filteredUsers.length / _itemsPerPage).ceil();
  }

  List<MessageProfileModel> get _displayedUsers {
    if (_filteredUsers.isEmpty) return [];
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredUsers.sublist(
      startIndex,
      endIndex > _filteredUsers.length ? _filteredUsers.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 필터링된 목록 초기화 (Provider 데이터 변경 시)
        if (_filteredUsers.isEmpty && userProvider.users.isNotEmpty) {
          _filteredUsers = List.from(userProvider.users);
        }

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
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 110,
                        color: Colors.blue.shade100,
                        child: const Center(
                          child: Text(
                            '보호대상자 도움말',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
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
                                  _filterUsers('', userProvider.users);
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      _filterUsers(value, userProvider.users);
                    },
                  ),
                ),
              ),

              // 사용자 목록
              Expanded(
                child: userProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : userProvider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userProvider.error!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // 새로고침은 MainPage에서 처리됨
                                  },
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          )
                        : _displayedUsers.isEmpty
                            ? const Center(
                                child: Text(
                                  '보호대상자가 없습니다',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
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

              // 페이지네이션
              if (_filteredUsers.isNotEmpty && _totalPages > 1)
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
      },
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

  Widget _buildUserItem(MessageProfileModel user) {
    final batteryImage = user.batteryImagePath ?? 'assets/images/battery.png';

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.displayName} 상세정보 (추후 구현)'),
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
            // 인형 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                user.botImagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.purple,
                      size: 36,
                    ),
                  );
                },
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
                        user.displayName,
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
                          color: (user.state ?? 0) > 0
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (user.state ?? 0) > 0 ? '활성' : '비활성',
                          style: TextStyle(
                            fontSize: 12,
                            color: (user.state ?? 0) > 0
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
                    '인형 번호: ${user.id ?? ''}',
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
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.battery_unknown,
                  size: 32,
                  color: Colors.grey,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
