import 'package:flutter/material.dart';
import '../../models/link_model.dart';
import '../../services/api_service.dart';
import '../webview_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final bool _hasDangerousWords = false; // 임시: 위험단어 없음
  final ApiService _apiService = ApiService();

  // FAQ 및 공지사항 데이터
  List<LinkModel> _faqList = [];
  String? _noticeText;
  bool _isLoadingFaq = true;
  String? _faqError;

  @override
  void initState() {
    super.initState();
    _loadLinks();
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
    } catch (e) {
      debugPrint('링크 로드 실패: $e');
      setState(() {
        _faqError = '서버 통신이 원활하지 않습니다.';
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

              const SizedBox(height: 100),
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
              onPressed: () {
                // TODO: 위험단어 더보기 페이지로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('위험단어 더보기 (추후 구현)')),
                );
              },
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

        // 위험단어가 없을 때
        if (!_hasDangerousWords)
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
          ),

        // TODO: 위험단어가 있을 때 GridView 표시
      ],
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('인형검색 (추후 구현)')),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('미디어 (추후 구현)')),
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
