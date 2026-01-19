import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _filteredMessages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      setState(() {
        _error = '로그인이 필요합니다.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _apiService.getMessageProfileList(int.parse(userId));

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        setState(() {
          _messages = data.map((item) => Map<String, dynamic>.from(item)).toList();
          _filteredMessages = List.from(_messages);
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages = [];
          _filteredMessages = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('인형 목록 로드 실패: $e');
      setState(() {
        _error = '서버 통신이 원활하지 않습니다.';
        _isLoading = false;
      });
    }
  }

  void _filterMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMessages = List.from(_messages);
      } else {
        _filteredMessages = _messages
            .where((msg) => msg['id'].toString().contains(query))
            .toList();
      }
    });
  }

  /// bot 값에 따른 이미지 경로 반환
  String _getBotImage(int bot) {
    switch (bot) {
      case 8:
        return 'assets/images/mapodong.png';
      case 13:
        return 'assets/images/kingstrawberry.png';
      case 14:
        return 'assets/images/dongdaemun.png';
      case 17:
        return 'assets/images/haeon.png';
      case 19:
        return 'assets/images/hamo.png';
      case 20:
        return 'assets/images/atongii.png';
      case 22:
        return 'assets/images/gumdoll.png';
      case 23:
        return 'assets/images/gumsunii.png';
      case 24:
        return 'assets/images/bamangii.png';
      case 25:
        return 'assets/images/sangii.png';
      case 26:
        return 'assets/images/pepper.png';
      case 27:
        return 'assets/images/organic.png';
      case 28:
        return 'assets/images/future.png';
      case 30:
        return 'assets/images/sun_on.png';
      case 31:
        return 'assets/images/jangsangii.png';
      case 32:
      case 33:
        return 'assets/images/jadu.png';
      case 34:
        return 'assets/images/rumi.png';
      case 35:
        return 'assets/images/gold_dragon.png';
      default:
        return 'assets/images/bokdongii.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),

          // 제목
          const Text(
            '채팅목록',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 20),

          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '인형 번호를 검색하세요',
                  hintStyle: TextStyle(color: Color(0xFF868e96)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onChanged: _filterMessages,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 대화 목록
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
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
                                  _loadMessages();
                                },
                                child: const Text('다시 시도'),
                              ),
                            ],
                          ),
                        )
                      : _filteredMessages.isEmpty
                          ? const Center(
                              child: Text(
                                '연결된 인형이 없습니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadMessages,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 70),
                                itemCount: _filteredMessages.length,
                                itemBuilder: (context, index) {
                                  return _buildMessageItem(_filteredMessages[index]);
                                },
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final id = message['id']?.toString() ?? '';
    final name = message['name']?.toString() ?? '이름 없음';
    final bot = message['bot'] ?? 0;
    final lastMessage = message['lastDialog']?.toString() ?? '';
    final lastTime = message['lastTime']?.toString() ?? '';

    return InkWell(
      onTap: () {
        // TODO: 채팅 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name 대화방 (추후 구현)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            // 인형 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                _getBotImage(bot),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.blue,
                      size: 30,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

            // 대화 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (lastTime.isNotEmpty)
                        Text(
                          lastTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '인형번호: $id',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (lastMessage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
