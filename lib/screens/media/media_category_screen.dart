import 'package:flutter/material.dart';
import 'media_list_screen.dart';

class MediaCategoryScreen extends StatelessWidget {
  const MediaCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '미디어컨텐츠',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 첫 번째 줄: 트로트, 옛날 이야기
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    '트로트',
                    84, // 'T'
                    const Color(0xFFFF5E9F),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    '옛날 이야기',
                    66, // 'B'
                    const Color(0xFF258AE4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 두 번째 줄: 수면유도, 동화
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    '수면유도',
                    83, // 'S'
                    const Color(0xFFCC6AEF),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    '동화',
                    65, // 'A'
                    const Color(0xFFFFB301),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 세 번째 줄: 불교, 기독교
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    '불교',
                    85, // 'U'
                    const Color(0xFFE8CFA5),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    '기독교',
                    76, // 'L'
                    const Color(0xFFFCBCBD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 네 번째 줄: 동요 (좌측만)
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    '동요',
                    67, // 'C'
                    const Color(0xFF6DBE80),
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(child: SizedBox()), // 빈 공간
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    int code,
    Color color,
  ) {
    // 카테고리별 아이콘 선택 (Android 원본과 동일하게)
    IconData icon;
    switch (code) {
      case 84: // 트로트 - 마이크 아이콘
        icon = Icons.mic;
        break;
      case 66: // 옛날 이야기 - 책 아이콘
        icon = Icons.menu_book;
        break;
      case 83: // 수면유도 - 초승달+별 아이콘
        icon = Icons.bedtime;
        break;
      case 65: // 동화 - 책 아이콘
        icon = Icons.auto_stories;
        break;
      case 85: // 불교 - 명상 아이콘
        icon = Icons.self_improvement;
        break;
      case 76: // 기독교 - 교회 아이콘
        icon = Icons.church;
        break;
      case 67: // 동요 - 음표 아이콘
        icon = Icons.music_note;
        break;
      default:
        icon = Icons.play_circle_outline;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaListScreen(
              categoryCode: code,
              categoryName: title,
            ),
          ),
        );
      },
      child: Column(
        children: [
          // 카드 (아이콘만 포함)
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20), // 약간만 둥글게
            ),
            child: Center(
              child: Icon(
                icon,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 텍스트 (카드 밖에)
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
}
