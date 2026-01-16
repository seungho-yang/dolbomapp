import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final bool _hasDangerousWords = false; // 임시: 위험단어 없음

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
          const Expanded(
            child: Text(
              'AI 돌보미 APP 리뉴얼',
              style: TextStyle(
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

  // 자주묻는 문의 섹션
  Widget _buildFAQSection() {
    final faqs = [
      {'question': '앱 사용법을 알고 싶어요', 'answer': '사용 가이드 참조'},
      {'question': '로그인이 안돼요', 'answer': '카카오톡 로그인 필요'},
      {'question': '알림이 오지 않아요', 'answer': '알림 설정 확인'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  faqs[index]['question']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  faqs[index]['answer']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
