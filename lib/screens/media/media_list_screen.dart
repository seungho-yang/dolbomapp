import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media_model.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';

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
  String? _error;

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
      debugPrint('미디어 로드 시작 - 코드: ${widget.categoryCode}');
      final response = await _apiService.getMediaContents(widget.categoryCode);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> mediaData = response.data as List<dynamic>;
        debugPrint('미디어 개수: ${mediaData.length}');

        setState(() {
          _mediaList =
              mediaData.map((json) => MediaModel.fromJson(json)).toList();
          _filteredMediaList = List.from(_mediaList);
          _isLoading = false;
        });
      } else {
        debugPrint('미디어 로드 실패: ${response.statusCode}');
        setState(() {
          _error = '콘텐츠를 불러오는데 실패했습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('미디어 로드 오류: $e');
      setState(() {
        _error = '서버 통신이 원활하지 않습니다.';
        _isLoading = false;
      });
    }
  }

  void _searchMedia(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMediaList = List.from(_mediaList);
      } else {
        _filteredMediaList = _mediaList.where((media) {
          final title = (media.title ?? '').toLowerCase();
          final subtitle = _getSubtitle().toLowerCase();
          return title.contains(query.toLowerCase()) ||
              subtitle.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  /// 카테고리별 subtitle
  String _getSubtitle() {
    switch (String.fromCharCode(widget.categoryCode)) {
      case 'A':
        return '동화';
      case 'B':
        return '옛날이야기';
      case 'C':
        return '동요';
      case 'S':
        return '수면음악';
      case 'L':
        return '성경말씀';
      case 'U':
        return '경전';
      case 'T':
        return '트로트';
      default:
        return widget.categoryName;
    }
  }

  /// 카테고리별 카운트 단위
  String _getCountUnit() {
    switch (String.fromCharCode(widget.categoryCode)) {
      case 'A':
      case 'B':
        return '편';
      case 'C':
      case 'S':
      case 'T':
        return '곡';
      case 'L':
        return '말씀';
      case 'U':
        return '경전';
      default:
        return '곡';
    }
  }

  /// 카테고리별 배경색
  Color _getCategoryColor() {
    switch (String.fromCharCode(widget.categoryCode)) {
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

  /// 인형 선택 다이얼로그 표시
  void _showDollSelectDialog(MediaModel media) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dolls = userProvider.users;

    showDialog(
      context: context,
      builder: (context) {
        String? selectedDollId;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                '콘텐츠를 재생할 인형을 선택해주세요.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: dolls.isEmpty
                  ? const Text('연결된 인형이 없습니다.')
                  : DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('인형 아이디를 선택해주세요.'),
                      value: selectedDollId,
                      items: dolls.map((doll) {
                        final dollId = doll.id?.toString() ?? '';
                        return DropdownMenuItem<String>(
                          value: dollId,
                          child: Text('${doll.name ?? ''} $dollId'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDollId = value;
                        });
                      },
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDollId != null) {
                      _playMedia(media, selectedDollId!);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('인형 아이디를 선택해주세요.')),
                      );
                    }
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 미디어 재생 (SignalR로 전송)
  void _playMedia(MediaModel media, String dollId) {
    // TODO: SignalR로 미디어 재생 요청 전송
    // Hub_Model hub_model = Hub_Model();
    // hub_model.setMode('M');
    // hub_model.setGroupname(dollId);
    // hub_model.setJson(jsonEncode(media));
    // Hub.getInstance().hubConnection.send("SendAsync", hub_model);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('재생될 때 까지 다소 시간이 걸릴 수 있습니다.\n재생될 때 까지 기다려 주세요.'),
        duration: Duration(seconds: 3),
      ),
    );

    debugPrint('미디어 재생 요청: ${media.title} -> 인형 $dollId');
  }

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

            // 검색창
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchMedia,
                  decoration: const InputDecoration(
                    hintText: '제목 및 카테고리를 입력하세요.',
                    hintStyle: TextStyle(color: Color(0xFF868e96)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),

            // 카운트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredMediaList.length} ${_getCountUnit()}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 미디어 목록
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5), // alarm_list_background
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = true;
                                      _error = null;
                                    });
                                    _loadMedia();
                                  },
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          )
                        : _filteredMediaList.isEmpty
                            ? const Center(
                                child: Text(
                                  '콘텐츠가 없습니다.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: _filteredMediaList.length,
                                itemBuilder: (context, index) {
                                  final media = _filteredMediaList[index];
                                  return _buildMediaItem(media);
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(MediaModel media) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: _getCategoryColor(),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getSubtitle(),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),

          // 제목 + 재생 버튼
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              children: [
                // 제목
                Expanded(
                  child: Text(
                    media.title ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // 재생 버튼
                GestureDetector(
                  onTap: () => _showDollSelectDialog(media),
                  child: Image.asset(
                    'assets/images/play_button.png',
                    width: 30,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.play_circle_outline,
                        size: 30,
                        color: Colors.black54,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
