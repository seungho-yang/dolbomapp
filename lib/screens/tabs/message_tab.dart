import 'package:flutter/material.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _filteredMessages = [];

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

  // 임시 더미 데이터
  void _loadMessages() {
    _messages = [
      {
        'id': '12345',
        'name': '테스트 인형 1',
        'lastMessage': '안녕하세요!',
        'time': '오전 10:30',
        'unreadCount': 2,
      },
      {
        'id': '67890',
        'name': '테스트 인형 2',
        'lastMessage': '오늘 날씨가 좋네요',
        'time': '어제',
        'unreadCount': 0,
      },
      {
        'id': '11111',
        'name': '테스트 인형 3',
        'lastMessage': '감사합니다',
        'time': '2일 전',
        'unreadCount': 5,
      },
    ];
    _filteredMessages = List.from(_messages);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 30),

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
              child: _filteredMessages.isEmpty
                  ? const Center(
                      child: Text(
                        '대화 내역이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 70),
                      itemCount: _filteredMessages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageItem(_filteredMessages[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    return InkWell(
      onTap: () {
        // TODO: 채팅 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${message['name']} 대화방 (추후 구현)'),
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
            // 프로필 아이콘
            Container(
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
                        message['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        message['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message['lastMessage'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (message['unreadCount'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${message['unreadCount']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
