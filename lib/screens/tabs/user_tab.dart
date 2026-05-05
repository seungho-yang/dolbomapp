import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/message_profile_model.dart';
import '../../services/api_service.dart';
import '../../services/global_user_info.dart';
import '../profile/profile_edit_screen.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  final TextEditingController _searchController = TextEditingController();

  List<MessageProfileModel> _filteredUsers = [];

  // 정렬 옵션: true = 낮은순, false = 높은순
  bool _sortAscending = true;

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
      _sortUsers();
    });
  }

  /// 인형번호순 정렬
  void _sortUsers() {
    _filteredUsers.sort((a, b) {
      final idA = int.tryParse(a.id ?? '0') ?? 0;
      final idB = int.tryParse(b.id ?? '0') ?? 0;
      return _sortAscending ? idA.compareTo(idB) : idB.compareTo(idA);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 필터링된 목록 초기화 (Provider 데이터 변경 시)
        if (_filteredUsers.isEmpty && userProvider.users.isNotEmpty) {
          _filteredUsers = List.from(userProvider.users);
          _sortUsers();
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

              // 정렬 옵션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '전체 ${_filteredUsers.length}명',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
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
                                _sortUsers();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
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
                        : _filteredUsers.isEmpty
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
                                padding: const EdgeInsets.only(bottom: 70),
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  return _buildUserItem(_filteredUsers[index]);
                                },
                              ),
              ),

            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(MessageProfileModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.displayName} (${user.id ?? ''})'),
        content: const Text('보호대상자를 삭제하시겠습니까?'),
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

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final userIdStr = authProvider.userId ?? GlobalUserInfo.instance.userId;
      final kakaoId = int.tryParse(userIdStr ?? '');
      final aiId = user.id;

      debugPrint('삭제 정보 - userId: $userIdStr, kakaoId: $kakaoId, aiId: $aiId');

      if (kakaoId == null || aiId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제에 필요한 정보가 없습니다. (userId: ${authProvider.userId}, aiId: $aiId)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final apiService = ApiService();
        final response = await apiService.deleteMatching(aiId, kakaoId);
        if (!mounted) return;

        final success = response.statusCode == 200;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? "'${user.displayName}' 보호대상자가 삭제되었습니다."
                : '삭제에 실패했습니다.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          final userProvider = context.read<UserProvider>();
          await userProvider.refresh(kakaoId!);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showUserMenu(MessageProfileModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단: 인형 이미지 + 이름
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
                      user.botImagePath,
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
                            Icons.smart_toy,
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
                      '${user.displayName} ${user.id ?? ''}',
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
            // 하단: 수정하기, 삭제하기 버튼
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileEditScreen(user: user),
                          ),
                        );
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
                        _showDeleteDialog(user);
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
                    children: [
                      Text(
                        user.id ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        batteryImage,
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.battery_unknown,
                            size: 28,
                            color: Colors.grey,
                          );
                        },
                      ),
                      // TODO: 활성/비활성 표시 (추후 구현)
                      // const Spacer(),
                      // Builder(builder: (context) {
                      //   final userProvider = context.watch<UserProvider>();
                      //   final isActive = user.id != null && userProvider.isDollActive(user.id!);
                      //   ...
                      // }),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // 더보기 메뉴
            GestureDetector(
              onTap: () => _showUserMenu(user),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.more_vert, color: Colors.grey, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
