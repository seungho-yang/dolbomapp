import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/link_model.dart';
import '../../models/message_chat_model.dart';
import '../../models/message_profile_model.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../services/global_user_info.dart';
import '../webview_screen.dart';
import '../media/media_category_screen.dart';
import '../search/doll_search_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _apiService = ApiService();

  // 위험단어 데이터 (메시지 + 해당 인형 정보)
  List<({MessageChatModel message, MessageProfileModel user})> _dangerousMessages = [];
  bool _isLoadingDanger = true;

  // 확인 처리된 메시지 ID 목록 (SharedPreferences에 저장)
  static const _dismissedKey = 'dismissed_danger_ids';
  Set<String> _dismissedIds = {};

  // FAQ 및 공지사항 데이터
  List<LinkModel> _faqList = [];
  String? _noticeText;
  bool _isLoadingFaq = true;
  String? _faqError;

  @override
  void initState() {
    super.initState();
    _loadLinks();
    _loadDismissedIds().then((_) {
      // UserProvider의 users가 로드된 후 위험단어를 가져오기 위해 리스너 등록
      final userProvider = context.read<UserProvider>();
      if (userProvider.isLoaded && userProvider.users.isNotEmpty) {
        _loadDangerousWords(userProvider.users);
      } else {
        userProvider.addListener(_onUserProviderChanged);
      }
    });
  }

  void _onUserProviderChanged() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.isLoaded && _isLoadingDanger) {
      userProvider.removeListener(_onUserProviderChanged);
      _loadDangerousWords(userProvider.users);
    }
  }

  @override
  void dispose() {
    // 안전하게 리스너 제거
    try {
      context.read<UserProvider>().removeListener(_onUserProviderChanged);
    } catch (_) {}
    super.dispose();
  }

  /// 확인 처리된 ID 목록 로드
  Future<void> _loadDismissedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_dismissedKey) ?? [];
    _dismissedIds = ids.toSet();
  }

  /// 위험단어 확인 처리 후 ID 저장
  Future<void> _saveDismissedId(String id) async {
    _dismissedIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedKey, _dismissedIds.toList());
  }

  /// 위험단어 데이터 로드
  Future<void> _loadDangerousWords(List<MessageProfileModel> users) async {
    try {
      final List<({MessageChatModel message, MessageProfileModel user})> allDangerous = [];

      for (final user in users) {
        if (user.id == null) continue;
        final response = await _apiService.getDangerMessages(user.id!, 0, 1);
        if (response.statusCode == 200 && response.data != null) {
          final List<dynamic> data = response.data is List
              ? response.data as List<dynamic>
              : [];
          final messages = data
              .map((e) => MessageChatModel.fromJson(e as Map<String, dynamic>))
              .where((m) => m.isDangerousWords == true && !_dismissedIds.contains(m.id))
              .toList();
          for (final msg in messages) {
            allDangerous.add((message: msg, user: user));
          }
        }
      }

      if (mounted) {
        setState(() {
          _dangerousMessages = allDangerous;
          _isLoadingDanger = false;
        });
      }
    } catch (e) {
      debugPrint('위험단어 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoadingDanger = false;
        });
      }
    }
  }

  /// 링크 데이터 로드 (공지사항 + FAQ)
  Future<void> _loadLinks() async {
    try {
      final response = await _apiService.getLinks();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final links = data.map((e) => LinkModel.fromJson(e)).toList();

        final faqItems = <LinkModel>[];
        String? notice;

        for (final link in links) {
          if (link.isFaq) {
            faqItems.add(link);
          } else if (link.isNotice) {
            notice = link.blog;
          }
        }

        setState(() {
          _faqList = faqItems;
          _noticeText = notice;
          _isLoadingFaq = false;
        });
      } else {
        setState(() {
          _faqError = '데이터를 불러올 수 없습니다.';
          _isLoadingFaq = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('링크 로드 실패: $e');
      debugPrint('스택트레이스: $stackTrace');
      setState(() {
        _faqError = '서버 통신이 원활하지 않습니다.\n$e';
        _isLoadingFaq = false;
      });
    }
  }

  /// FAQ 항목 클릭 시 WebView로 이동
  void _openFaqDetail(LinkModel faq) {
    if (faq.blog != null && faq.blog!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebViewScreen(
            url: faq.blog!,
            title: '자주묻는 문의',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 위험단어 섹션
              _buildDangerousWordsSection(),

              const SizedBox(height: 20),

              // 공지사항
              _buildNoticeSection(),

              const SizedBox(height: 20),

              // AI 돌보미 서비스
              const Text(
                'AI 돌보미 서비스',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildServiceGrid(),

              const SizedBox(height: 30),

              // 자주묻는 문의
              const Text(
                '자주묻는 문의',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildFAQSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 위험단어 섹션
  Widget _buildDangerousWordsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '위험단어',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: _dangerousMessages.isEmpty
                  ? null
                  : () => _showDangerousWordsDetail(),
              child: const Text(
                '더 보기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_isLoadingDanger)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_dangerousMessages.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '오늘 위험단어가 없습니다.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _dangerousMessages.map((item) {
                return GestureDetector(
                  onTap: () => _showDangerConfirmDialog(item),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            item.user.botImagePath,
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.user.id ?? ''}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.message.message ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// 위험단어 확인 다이얼로그 (클릭 시)
  void _showDangerConfirmDialog(({MessageChatModel message, MessageProfileModel user}) item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                item.user.botImagePath,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${item.user.displayName} (${item.user.id ?? ''})',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '위험단어',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.message.message ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (item.message.id != null) {
                _saveDismissedId(item.message.id!);
              }
              setState(() {
                _dangerousMessages.remove(item);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 어르신 정보 바텀시트 (위험단어 클릭 시)
  void _showUserProfile(MessageProfileModel user) {
    final profile = user.profile;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // 인형 이미지 및 기본 정보
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      user.botImagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '인형 번호: ${user.id ?? '-'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile?.agency != null)
                          Text(
                            profile!.agency!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 어르신 정보 섹션
              _buildInfoSection(
                title: '어르신 정보',
                icon: Icons.elderly,
                iconColor: Colors.orange,
                name: profile?.protectedPerson,
                phone: profile?.protectedPhone,
              ),

              const SizedBox(height: 16),

              // 보호자 정보 섹션
              _buildInfoSection(
                title: '보호자 정보',
                icon: Icons.person,
                iconColor: Colors.blue,
                name: profile?.name,
                phone: profile?.phone,
              ),

              if (profile?.address != null) ...[
                const SizedBox(height: 16),
                // 주소 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profile!.address!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 삭제 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(user);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    '보호대상자 삭제',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 정보 섹션 위젯 (어르신/보호자)
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    String? name,
    String? phone,
  }) {
    final hasInfo = name != null || phone != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!hasInfo)
            Text(
              '정보 없음',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            )
          else ...[
            // 이름
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '성함',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    name ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 연락처 + 전화 버튼
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '연락처',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    phone ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (phone != null && phone.isNotEmpty)
                  IconButton(
                    onPressed: () => _makePhoneCall(phone),
                    icon: const Icon(Icons.phone, color: Colors.green),
                    tooltip: '전화 걸기',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 전화 걸기
  Future<void> _makePhoneCall(String phoneNumber) async {
    // 전화번호에서 특수문자 제거
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('전화 앱을 실행할 수 없습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('전화 걸기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('전화 걸기 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmDialog(MessageProfileModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.displayName} (${user.id ?? ''})'),
        content: const Text('이 보호대상자를 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.'),
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
      await _deleteUser(user);
    }
  }

  /// 보호대상자 삭제
  Future<void> _deleteUser(MessageProfileModel user) async {
    final userIdStr = GlobalUserInfo.instance.userId;
    final kakaoId = int.tryParse(userIdStr ?? '');
    final aiId = user.id;

    if (kakaoId == null || aiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('삭제에 필요한 정보가 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await _apiService.deleteMatching(aiId, kakaoId);

      if (!mounted) return;

      final success = response.statusCode == 200;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "'${user.displayName}' 보호대상자가 삭제되었습니다."
                : '삭제에 실패했습니다.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        // 사용자 목록 새로고침
        final userProvider = context.read<UserProvider>();
        await userProvider.refresh(kakaoId);

        // 위험단어 목록에서도 제거
        setState(() {
          _dangerousMessages.removeWhere((item) => item.user.id == aiId);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 위험단어 더보기 바텀시트
  void _showDangerousWordsDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '오늘의 위험단어',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: _dangerousMessages.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _dangerousMessages[index];
                        return ListTile(
                          leading: ClipOval(
                            child: Image.asset(
                              item.user.botImagePath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item.message.message ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            item.user.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showUserProfile(item.user);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 공지사항 섹션
  Widget _buildNoticeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/home_notice.png',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _noticeText ?? 'AI 돌보미 APP 리뉴얼',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AI 돌보미 서비스 그리드 (2x2)
  Widget _buildServiceGrid() {
    return Column(
      children: [
        // 첫 번째 줄
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                '인형검색 >',
                '찾고 싶은 인형을 검색하세요',
                const Color(0xFFF9C553), // 노란색/금색
                'assets/images/home_search.png',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DollSearchScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildServiceCard(
                'A/S접수 >',
                'A/S 등록 및 현황을 확인하세요',
                const Color(0xFF46C8F3), // 파란색
                'assets/images/home_as.png',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A/S접수 (추후 구현)')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 두 번째 줄
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                '미디어 >',
                '재생할 컨텐츠를 선택하세요',
                const Color(0xFFF78FAC), // 핑크색
                'assets/images/home_media.png',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediaCategoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildServiceCard(
                '능동대화 >',
                '원하시는 능동대화를 만들어보세요',
                const Color(0xFFF68352), // 주황색
                'assets/images/home_ai.png',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('능동대화 (준비중)')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 서비스 카드
  Widget _buildServiceCard(
    String title,
    String description,
    Color color,
    String iconPath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            const Spacer(),
            // 제목
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            // 설명
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 자주묻는 문의 섹션 (썸네일 이미지 기반)
  Widget _buildFAQSection() {
    // 로딩 중
    if (_isLoadingFaq) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 에러 발생
    if (_faqError != null) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey.shade400, size: 40),
              const SizedBox(height: 8),
              Text(
                _faqError!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoadingFaq = true;
                    _faqError = null;
                  });
                  _loadLinks();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    // FAQ 목록이 비어있음
    if (_faqList.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            '등록된 FAQ가 없습니다.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    // FAQ 목록 표시 (가로 스크롤, 썸네일 이미지)
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _faqList.length,
        itemBuilder: (context, index) {
          final faq = _faqList[index];
          return GestureDetector(
            onTap: () => _openFaqDetail(faq),
            child: Container(
              width: 280,
              margin: EdgeInsets.only(
                right: index < _faqList.length - 1 ? 12 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: faq.thumbnail != null && faq.thumbnail!.isNotEmpty
                    ? Image.network(
                        faq.thumbnail!,
                        fit: BoxFit.cover,
                        width: 280,
                        height: 170,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 280,
                            height: 170,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 280,
                            height: 170,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 280,
                        height: 170,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.help_outline,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
