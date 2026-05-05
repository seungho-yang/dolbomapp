import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/message_chat_model.dart';
import '../../models/hub_model.dart';
import '../../providers/message_provider.dart';
import '../../providers/signalr_provider.dart';
import '../../services/signalr_service.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String odId; // 인형 ID
  final String name; // 인형 이름
  final int bot; // 봇 타입

  const ChatScreen({
    super.key,
    required this.odId,
    required this.name,
    required this.bot,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SignalRService _signalRService = SignalRService.instance;

  // 개발 모드 플래그 - true면 더미 데이터 사용
  static const bool _useDummyData = false;

  // .NET Ticks 변환용 상수 (Java Android와 동일)
  static const int ticksAtEpoch = 621355968000000000;

  List<MessageChatModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  // AI 자동 응답 메시지 목록
  static const List<String> _aiResponses = [
    '안녕하세요! 오늘 기분이 어떠세요?',
    '그렇군요. 더 자세히 이야기해 주실 수 있나요?',
    '말씀해 주셔서 감사합니다. 제가 도움이 될 수 있으면 좋겠어요.',
    '오늘 하루도 힘내세요!',
    '저는 항상 여기 있어요. 언제든 이야기해 주세요.',
    '좋은 생각이에요!',
    '그런 일이 있었군요. 마음이 어떠셨어요?',
    '천천히 이야기해 주세요. 듣고 있어요.',
    '오늘 날씨가 좋네요. 산책은 어떠세요?',
    '맛있는 거 드셨나요?',
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('ChatScreen: initState - odId: ${widget.odId}, name: ${widget.name}, bot: ${widget.bot}');
    _loadMessages();
    if (!_useDummyData) {
      _signalRService.addListener(_onSignalRMessage);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (!_useDummyData) {
      _signalRService.removeListener(_onSignalRMessage);
    }
    super.dispose();
  }

  /// 더미 메시지 데이터 생성
  /// type 0: 사용자 메시지 (오른쪽)
  /// type 2: 봇 메시지 (왼쪽)
  List<MessageChatModel> _generateDummyMessages() {
    final now = DateTime.now();
    return [
      MessageChatModel(
        id: widget.odId,
        message: '안녕하세요! 오늘 하루는 어떠셨어요?',
        reception: now.subtract(const Duration(minutes: 5)),
        type: 2, // 봇 메시지 (왼쪽)
        bot: widget.bot,
        isDangerousWords: false,
      ),
      MessageChatModel(
        id: widget.odId,
        message: '안녕! 오늘 좀 피곤해',
        reception: now.subtract(const Duration(minutes: 4)),
        type: 0, // 사용자 메시지 (오른쪽)
        bot: 0,
        isDangerousWords: false,
      ),
      MessageChatModel(
        id: widget.odId,
        message: '그렇군요. 푹 쉬셔야 해요. 오늘 뭐 드셨어요?',
        reception: now.subtract(const Duration(minutes: 3)),
        type: 2, // 봇 메시지
        bot: widget.bot,
        isDangerousWords: false,
      ),
      MessageChatModel(
        id: widget.odId,
        message: '점심에 된장찌개 먹었어',
        reception: now.subtract(const Duration(minutes: 2)),
        type: 0, // 사용자 메시지
        bot: 0,
        isDangerousWords: false,
      ),
      MessageChatModel(
        id: widget.odId,
        message: '된장찌개 맛있죠! 저도 좋아해요!',
        reception: now.subtract(const Duration(minutes: 1)),
        type: 2, // 봇 메시지
        bot: widget.bot,
        isDangerousWords: false,
      ),
    ];
  }

  /// SignalR 메시지 수신 처리
  void _onSignalRMessage(HubModel hubModel) {
    // Dialog 메시지이고 현재 채팅방에 해당하는 메시지인지 확인
    if (hubModel.isDialog && hubModel.groupName == widget.odId) {
      if (hubModel.json != null) {
        try {
          final jsonData = jsonDecode(hubModel.json!);
          final newMessage = MessageChatModel(
            id: jsonData['id']?.toString(),
            message: jsonData['message']?.toString(),
            reception: DateTime.tryParse(jsonData['reception'] ?? ''),
            type: jsonData['type'],
            bot: jsonData['bot'],
            image: jsonData['image'],
            isDangerousWords: jsonData['isDangerousWords'],
          );

          setState(() {
            // 중복 메시지 방지
            final exists = _messages.any((m) =>
                m.message == newMessage.message &&
                m.reception == newMessage.reception);
            if (!exists) {
              _messages.insert(0, newMessage);
            }
          });

          _scrollToBottom();
        } catch (e) {
          debugPrint('메시지 파싱 실패: $e');
        }
      }
    }
  }

  /// 대화 내역 로드
  Future<void> _loadMessages() async {
    debugPrint('ChatScreen: _loadMessages 시작');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // 더미 데이터 모드
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
      setState(() {
        _messages = _generateDummyMessages().reversed.toList(); // 최신순 정렬
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      return;
    }

    try {
      // 직접 API 호출
      debugPrint('ChatScreen: API 호출 시작 - odId: ${widget.odId}');
      final apiService = ApiService();
      final response = await apiService.getMessages(widget.odId);
      debugPrint('ChatScreen: API 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data;
        if (response.data is String) {
          data = jsonDecode(response.data as String);
        } else {
          data = response.data;
        }
        debugPrint('ChatScreen: 메시지 수: ${data.length}');

        setState(() {
          _messages = data.map((json) => MessageChatModel.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages = [];
          _isLoading = false;
        });
      }

      // 스크롤 맨 아래로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e, stackTrace) {
      debugPrint('ChatScreen: 오류 - $e');
      debugPrint('ChatScreen: 스택트레이스 - $stackTrace');
      setState(() {
        _error = '메시지를 불러오는데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  /// DateTime을 .NET Ticks로 변환 (Java Android와 동일)
  int _dateTimeToTicks(DateTime dateTime) {
    // UTC+9 시간 추가
    final adjusted = dateTime.add(const Duration(hours: 9));
    return adjusted.millisecondsSinceEpoch * 10000 + ticksAtEpoch;
  }

  /// 추가 메시지 로드 (페이지네이션)
  Future<void> _loadMoreMessages() async {
    if (_messages.isEmpty || _useDummyData) return;

    // 가장 오래된 메시지의 tick 값 사용 (Java Android와 동일한 변환)
    final oldestMessage = _messages.last;
    if (oldestMessage.reception == null) return;

    final tick = _dateTimeToTicks(oldestMessage.reception!);

    try {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      await messageProvider.loadMoreMessages(widget.odId, tick);

      setState(() {
        _messages = List.from(messageProvider.getMessagesForUser(widget.odId));
      });
    } catch (e) {
      debugPrint('추가 메시지 로드 실패: $e');
    }
  }

  /// 메시지 전송
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    // 더미 데이터 모드 - 로컬에서만 처리
    if (_useDummyData) {
      // 사용자 메시지 추가
      final sentMessage = MessageChatModel(
        id: widget.odId,
        message: text,
        reception: DateTime.now(),
        type: 0, // type 0 = 사용자 메시지 (오른쪽)
        bot: 0,
        isDangerousWords: false,
      );

      setState(() {
        _messages.insert(0, sentMessage);
        _isSending = false;
      });

      _messageController.clear();
      _scrollToBottom();

      // AI 자동 응답 (1~2초 후)
      Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(1000)), () {
        if (mounted) {
          final aiResponse = MessageChatModel(
            id: widget.odId,
            message: _aiResponses[Random().nextInt(_aiResponses.length)],
            reception: DateTime.now(),
            type: 2, // type 2 = 봇 메시지 (왼쪽)
            bot: widget.bot,
            isDangerousWords: false,
          );

          setState(() {
            _messages.insert(0, aiResponse);
          });
          _scrollToBottom();
        }
      });

      return;
    }

    try {
      final signalRProvider =
          Provider.of<SignalRProvider>(context, listen: false);

      await signalRProvider.sendChatMessage(
        id: widget.odId,
        message: text,
        bot: 0, // 사용자가 보내는 메시지는 bot=0
        type: 0, // type 0 = 사용자 메시지
      );

      // 전송한 메시지를 로컬에 추가
      final sentMessage = MessageChatModel(
        id: widget.odId,
        message: text,
        reception: DateTime.now(),
        type: 0, // type 0 = 사용자 메시지 (오른쪽)
        bot: 0,
        isDangerousWords: false,
      );

      setState(() {
        _messages.insert(0, sentMessage);
        _isSending = false;
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isSending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지 전송에 실패했습니다.')),
        );
      }
    }
  }

  /// 스크롤을 맨 아래로
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                _getBotImage(widget.bot),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.smart_toy,
                        color: Colors.blue, size: 24),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '인형번호: ${widget.odId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMessages,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? const Center(
                            child: Text(
                              '대화 내역이 없습니다.\n첫 메시지를 보내보세요!',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              // 스크롤이 맨 위에 도달하면 추가 로드
                              if (notification is ScrollEndNotification &&
                                  _scrollController.position.pixels ==
                                      _scrollController
                                          .position.maxScrollExtent) {
                                _loadMoreMessages();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              reverse: true, // 최신 메시지가 아래에 표시
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                return _buildMessageBubble(_messages[index]);
                              },
                            ),
                          ),
          ),

          // 입력창
          _buildInputArea(),
        ],
      ),
    );
  }

  /// 메시지 버블 위젯
  /// type 0: 어르신(사용자) 메시지 (왼쪽, 흰색)
  /// type 1: 타인 메시지 (오른쪽)
  /// type 2: 봇(인형) 메시지 (오른쪽, 파란색)
  /// type 3: 응급 메시지 (오른쪽, 빨간색)
  /// type 4: 알람 메시지 (오른쪽)
  /// type 6: 활성 메시지 (오른쪽)
  Widget _buildMessageBubble(MessageChatModel message) {
    // type 0: 어르신 메시지 (왼쪽), 나머지: 인형 메시지 (오른쪽)
    final isUser = message.type == 0;
    final isDanger = message.isDangerousWords ?? false;
    final isEmergency = message.type == 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 어르신 메시지 여백 (왼쪽)
          if (isUser) const SizedBox(width: 8),

          // 메시지 내용
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.white
                        : isDanger
                            ? Colors.red.shade100
                            : const Color(0xFF4A90D9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 4 : 16),
                      bottomRight: Radius.circular(isUser ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDanger || isEmergency)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEmergency ? Icons.emergency : Icons.warning,
                                size: 14,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isEmergency ? '응급 메시지' : '위험단어 감지',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        message.message ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: isUser
                              ? Colors.black87
                              : (isDanger || isEmergency)
                                  ? Colors.red.shade900
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.reception),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // 인형 아바타 (오른쪽)
          if (!isUser) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _getBotImage(widget.bot),
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.smart_toy,
                        color: Colors.blue, size: 20),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 시간 포맷팅
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return DateFormat('MM/dd HH:mm').format(dateTime);
    } else {
      return DateFormat('HH:mm').format(dateTime);
    }
  }

  /// 입력창 위젯
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 텍스트 입력
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: TextStyle(color: Color(0xFF868e96)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 전송 버튼
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
