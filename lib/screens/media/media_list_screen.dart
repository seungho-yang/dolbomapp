import 'package:flutter/material.dart';
import '../../models/media_model.dart';
import '../../services/api_service.dart';
import 'media_player_screen.dart';

class MediaListScreen extends StatefulWidget {
  final int categoryCode;
  final String categoryName;

  const MediaListScreen({
    super.key,
    required this.categoryCode,
    required this.categoryName,
  });

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<MediaModel> _mediaList = [];
  List<MediaModel> _filteredMediaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    try {
      debugPrint('📡 미디어 로드 시작 - 코드: ${widget.categoryCode}');
      final response = await _apiService.getMediaContents(widget.categoryCode);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> mediaData = response.data as List<dynamic>;
        debugPrint('📡 미디어 개수: ${mediaData.length}');

        setState(() {
          _mediaList = mediaData.map((json) => MediaModel.fromJson(json)).toList();
          _filteredMediaList = List.from(_mediaList);
          _isLoading = false;
        });
      } else {
        debugPrint('❌ 미디어 로드 실패: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 미디어 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchMedia(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMediaList = List.from(_mediaList);
      } else {
        _filteredMediaList = _mediaList
            .where((media) =>
                (media.title ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Color _getCategoryColor() {
    switch (widget.categoryCode) {
      case 84: // 'T' - 트로트
        return const Color(0xFFFF5E9F);
      case 66: // 'B' - 옛날이야기
        return const Color(0xFF258AE4);
      case 83: // 'S' - 수면유도
        return const Color(0xFFCC6AEF);
      case 65: // 'A' - 동화
        return const Color(0xFFFFB301);
      case 85: // 'U' - 불교
        return const Color(0xFFE8CFA5);
      case 76: // 'L' - 기독교
        return const Color(0xFFFCBCBD);
      case 67: // 'C' - 동요
        return const Color(0xFF6DBE80);
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    const countUnit = '곡';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 검색바 및 카운트
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _searchMedia,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_filteredMediaList.length} $countUnit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 미디어 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMediaList.isEmpty
                    ? Center(
                        child: Text(
                          '콘텐츠가 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredMediaList.length,
                        itemBuilder: (context, index) {
                          final media = _filteredMediaList[index];
                          return _buildMediaItem(media);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(MediaModel media) {
    return GestureDetector(
      onTap: () {
        // 미디어 플레이어 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaPlayerScreen(
              media: media,
              categoryColor: _getCategoryColor(),
              categoryName: widget.categoryName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCategoryColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 인덱스 번호
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${_filteredMediaList.indexOf(media) + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 제목
            Expanded(
              child: Text(
                media.title ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // 재생 아이콘
            const Icon(
              Icons.play_circle_outline,
              color: Colors.black54,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
