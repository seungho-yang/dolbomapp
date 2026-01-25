import 'package:flutter/material.dart';
import 'media_list_screen.dart';

class MediaCategoryScreen extends StatelessWidget {
  const MediaCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // 뒤로가기 버튼
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'assets/images/backbutton.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black);
                      },
                    ),
                  ),
                  // 타이틀 (중앙 정렬)
                  Expanded(
                    child: const Text(
                      '미디어컨텐츠',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // 오른쪽 여백 (대칭)
                  const SizedBox(width: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 카테고리 그리드
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 첫 번째 줄: 트로트, 옛날 이야기
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryItem(
                            context,
                            '트로트',
                            'T', // code char
                            'assets/images/trot_icon.png',
                          ),
                        ),
                        Expanded(
                          child: _buildCategoryItem(
                            context,
                            '옛날 이야기',
                            'B',
                            'assets/images/history_icon.png',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 두 번째 줄: 수면유도, 동화
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryItem(
                            context,
                            '수면유도',
                            'S',
                            'assets/images/sleep_icon.png',
                          ),
                        ),
                        Expanded(
                          child: _buildCategoryItem(
                            context,
                            '동화',
                            'A',
                            'assets/images/book_icon.png',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 세 번째 줄: 불교, 기독교
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryItem(
                            context,
                            '불교',
                            'U',
                            'assets/images/buddhism_icon.png',
                          ),
                        ),
                        Expanded(
                          child: _buildCategoryItem(
                            context,
                            '기독교',
                            'L',
                            'assets/images/church_icon.png',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 네 번째 줄: 동요
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryItem(
                            context,
                            '동요',
                            'C',
                            'assets/images/agitation_icon.png',
                          ),
                        ),
                        const Expanded(child: SizedBox()), // 빈 공간
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    String codeChar,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaListScreen(
              categoryCode: codeChar.codeUnitAt(0), // char to int
              categoryName: title,
            ),
          ),
        );
      },
      child: Column(
        children: [
          // 아이콘 이미지
          Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 기본 아이콘 표시
              return Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: _getCategoryColor(codeChar),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getCategoryIcon(codeChar),
                  size: 70,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // 텍스트
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String codeChar) {
    switch (codeChar) {
      case 'T':
        return const Color(0xFFFF5E9F);
      case 'B':
        return const Color(0xFF258AE4);
      case 'S':
        return const Color(0xFFCC6AEF);
      case 'A':
        return const Color(0xFFFFB301);
      case 'U':
        return const Color(0xFFE8CFA5);
      case 'L':
        return const Color(0xFFFCBCBD);
      case 'C':
        return const Color(0xFF6DBE80);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String codeChar) {
    switch (codeChar) {
      case 'T':
        return Icons.mic;
      case 'B':
        return Icons.menu_book;
      case 'S':
        return Icons.bedtime;
      case 'A':
        return Icons.auto_stories;
      case 'U':
        return Icons.self_improvement;
      case 'L':
        return Icons.church;
      case 'C':
        return Icons.music_note;
      default:
        return Icons.play_circle_outline;
    }
  }
}
