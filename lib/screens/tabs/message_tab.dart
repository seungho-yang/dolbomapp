import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/signalr_provider.dart';
import '../../models/message_profile_model.dart';
import '../../models/hub_model.dart';
import '../../services/signalr_service.dart';
import '../chat/chat_screen.dart';

/// MessageTab - 대화 목록 화면
/// Java의 fragment/Message.java와 동일한 역할
class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  final TextEditingController _searchController = TextEditingController();
  final SignalRService _signalRService = SignalRService.instance;

  List<MessageProfileModel> _filteredMessages = [];
  List<MessageProfileModel> _sortedMessages = [];

  @override
  void initState() {
    super.initState();
    // SignalR 메시지 리스너 등록 (Java의 Hub.setUpListener와 동일)
    _signalRService.addListener(_onSignalRMessage);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _signalRService.removeListener(_onSignalRMessage);
    super.dispose();
  }

  /// SignalR 메시지 수신 처리 (Java Message.java의 Hub.setUpListener와 동일)
  /// mode 'D': Dialog 메시지 수신
  void _onSignalRMessage(HubModel hubModel) {
    if (hubModel.isDialog && hubModel.json != null) {
      try {
        final jsonData = jsonDecode(hubModel.json!);
        final messageId = jsonData['id']?.toString();
        final messageText = jsonData['message']?.toString();

        if (messageId != null && messageText != null) {
          // 해당 인형의 마지막 메시지 업데이트
          setState(() {
            for (var user in _sortedMessages) {
              if (user.id == messageId) {
                user.lastDialog = messageText;
                user.lastTime = _formatCurrentTime();
                break;
              }
            }
            // 최근 메시지 시간 기준으로 재정렬
            _sortMessagesByTime();
            _applyFilter(_searchController.text);
          });

          debugPrint('MessageTab: 실시간 메시지 수신 - id: $messageId, message: $messageText');
        }
      } catch (e) {
        debugPrint('MessageTab: 메시지 파싱 실패 - $e');
      }
    }
  }

  /// 현재 시간 포맷팅
  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// 최근 대화 시간 기준으로 정렬 (Java Message.java의 arrayList.sort와 동일)
  void _sortMessagesByTime() {
    _sortedMessages.sort((a, b) {
      // lastTime이 있는 항목을 위로
      if (a.lastTime == null && b.lastTime == null) return 0;
      if (a.lastTime == null) return 1;
      if (b.lastTime == null) return -1;
      // 최신 메시지가 위로 (내림차순)
      return b.lastTime!.compareTo(a.lastTime!);
    });
  }

  /// 검색 필터 적용
  void _applyFilter(String query) {
    if (query.isEmpty) {
      _filteredMessages = List.from(_sortedMessages);
    } else {
      _filteredMessages = _sortedMessages
          .where((msg) => msg.id?.contains(query) ?? false)
          .toList();
    }
  }

  /// 검색 처리 (Java Message.java의 search 메서드와 동일)
  void _filterMessages(String query, List<MessageProfileModel> allMessages) {
    setState(() {
      _applyFilter(query);
    });
  }

  /// 데이터 새로고침 (userId 기반)
  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final userId = authProvider.userId;
    if (userId != null && userId.isNotEmpty) {
      debugPrint('MessageTab: 데이터 새로고침 - userId: $userId');
      await userProvider.refresh(int.parse(userId));

      setState(() {
        _sortedMessages = List.from(userProvider.users);
        _sortMessagesByTime();
        _applyFilter(_searchController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, AuthProvider>(
      builder: (context, userProvider, authProvider, child) {
        // 필터링된 목록 초기화 (Provider 데이터 변경 시)
        if (_sortedMessages.isEmpty && userProvider.users.isNotEmpty) {
          _sortedMessages = List.from(userProvider.users);
          _sortMessagesByTime();
          _filteredMessages = List.from(_sortedMessages);
        }

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

              // 검색창 (Java Message.java의 editSearch와 동일)
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
                      suffixIcon: Icon(Icons.search, color: Color(0xFF868e96)),
                    ),
                    onChanged: (value) {
                      _filterMessages(value, userProvider.users);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 대화 목록
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F5F5),
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
                                    onPressed: _refreshData,
                                    child: const Text('다시 시도'),
                                  ),
                                ],
                              ),
                            )
                          : _filteredMessages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchController.text.isEmpty
                                            ? '연결된 인형이 없습니다'
                                            : '검색 결과가 없습니다',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (_searchController.text.isEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '홈 화면에서 인형을 등록해주세요',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _refreshData,
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
      },
    );
  }

  /// 대화 목록 아이템 위젯 (Java Message_Adapter와 동일한 역할)
  Widget _buildMessageItem(MessageProfileModel message) {
    final id = message.id ?? '';
    final name = message.displayName;
    final bot = message.bot ?? 0;
    // chats에서 마지막 메시지와 시간 가져오기
    final lastMessage = message.lastChatMessage ?? '';
    final lastTime = message.lastChatTime ?? '';

    return InkWell(
      onTap: () async {
        debugPrint('MessageTab: 채팅 화면으로 이동 - id: $id, name: $name, bot: $bot');
        // 채팅 화면으로 이동 (Java의 startActivityForResult와 동일)
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              odId: id,
              name: name,
              bot: bot,
            ),
          ),
        );
        debugPrint('MessageTab: 채팅 화면에서 돌아옴 - result: $result');

        // 채팅 화면에서 돌아올 때 마지막 메시지 업데이트
        if (result != null && mounted) {
          setState(() {
            for (var user in _sortedMessages) {
              if (user.id == id) {
                user.lastDialog = result['message'];
                user.lastTime = result['time'];
                break;
              }
            }
            _sortMessagesByTime();
            _applyFilter(_searchController.text);
          });
        }
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
                message.botImagePath,
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
                  // 첫 번째 줄: 이름 + 인형번호 | 시간
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // 이름
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 인형번호 (굵게, # 제거)
                            Text(
                              id,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 마지막 채팅 시간
                      if (lastTime.isNotEmpty)
                        Text(
                          lastTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                  // 두 번째 줄: 마지막 메시지
                  if (lastMessage.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 화살표 아이콘
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
