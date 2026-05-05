import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hub_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/signalr_provider.dart';
import '../../services/api_service.dart';

/// 인형검색 화면
class DollSearchScreen extends StatefulWidget {
  const DollSearchScreen({super.key});

  @override
  State<DollSearchScreen> createState() => _DollSearchScreenState();
}

class _DollSearchScreenState extends State<DollSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  // 인증 대기 관련
  bool _isWaitingAuth = false;
  int _countdownSeconds = 60;
  Timer? _countdownTimer;
  String? _pendingAiId;

  @override
  void initState() {
    super.initState();
    // SignalR 리스너 등록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSignalRListener();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// SignalR 리스너 설정
  void _setupSignalRListener() {
    final signalRProvider = Provider.of<SignalRProvider>(context, listen: false);
    // Provider를 통해 메시지 변경 감지
  }

  /// 인형 검색
  Future<void> _searchDoll(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getAiByStringId(query);

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _searchResults = [Map<String, dynamic>.from(response.data)];
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('인형 검색 실패: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _error = '검색에 실패했습니다.';
      });
    }
  }

  /// 인형 선택 시 인증 요청
  Future<void> _onDollSelected(Map<String, dynamic> doll) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      _showSnackBar('로그인이 필요합니다.');
      return;
    }

    final aiId = doll['id']?.toString() ?? '';
    if (aiId.isEmpty) {
      _showSnackBar('인형 정보가 올바르지 않습니다.');
      return;
    }

    try {
      final response = await _apiService.getAuthorize(int.parse(userId), aiId);

      if (response.statusCode == 200) {
        // 인증 대기 시작
        _pendingAiId = aiId;
        _startAuthCountdown();
      } else if (response.statusCode == 204) {
        _showSnackBar('이미 연결되어 있는 인형입니다.');
      } else {
        _showSnackBar('인증 요청에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('인증 요청 실패: $e');
      _showSnackBar('서버 통신이 원활하지 않습니다.');
    }
  }

  /// 인증 대기 카운트다운 시작
  void _startAuthCountdown() {
    setState(() {
      _isWaitingAuth = true;
      _countdownSeconds = 60;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _cancelAuthWait();
        _showSnackBar('인증 시간이 초과되었습니다.');
      }
    });

    // 인증 대기 다이얼로그 표시
    _showAuthWaitDialog();
  }

  /// 인증 대기 취소
  void _cancelAuthWait() {
    _countdownTimer?.cancel();
    setState(() {
      _isWaitingAuth = false;
      _pendingAiId = null;
    });
  }

  /// 인증 대기 다이얼로그
  void _showAuthWaitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 타이머로 다이얼로그 업데이트
            Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!_isWaitingAuth) {
                timer.cancel();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              } else {
                setDialogState(() {});
              }
            });

            return AlertDialog(
              title: const Text('인증 대기 중'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    '${_countdownSeconds ~/ 60}분 ${_countdownSeconds % 60}초',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('인형에서 인증을 완료해주세요.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _cancelAuthWait();
                    Navigator.pop(context);
                  },
                  child: const Text('취소'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 인증 성공 처리
  Future<void> _onAuthSuccess() async {
    _countdownTimer?.cancel();
    setState(() {
      _isWaitingAuth = false;
    });

    if (_pendingAiId == null) return;

    // 초기화 정보 조회
    try {
      final response = await _apiService.getInitialize(_pendingAiId!);

      if (response.statusCode == 200 && response.data != null) {
        // 이름 선택 다이얼로그 표시
        final List<dynamic> nameOptions = response.data as List<dynamic>;
        if (mounted) {
          _showNameSelectDialog(nameOptions);
        }
      } else {
        // 이름 선택 없이 바로 연결 완료
        _showConnectionSuccessDialog();
      }
    } catch (e) {
      debugPrint('초기화 정보 조회 실패: $e');
      _showConnectionSuccessDialog();
    }
  }

  /// 이름 선택 다이얼로그
  void _showNameSelectDialog(List<dynamic> nameOptions) {
    String? selectedName;
    int? selectedBot;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('인형 이름 선택'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('이름은 선택 후 변경하실 수 없습니다.'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '이름 선택',
                    ),
                    hint: const Text('인형에 맞는 이름을 선택해주세요'),
                    value: selectedName,
                    items: nameOptions.map<DropdownMenuItem<String>>((option) {
                      return DropdownMenuItem<String>(
                        value: option['name']?.toString(),
                        child: Text(option['name']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedName = value;
                        // bot 값 찾기
                        for (var option in nameOptions) {
                          if (option['name'] == value) {
                            selectedBot = option['bot'];
                            break;
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: selectedName == null
                      ? null
                      : () async {
                          await _submitNameSelection(selectedBot);
                          if (mounted) {
                            Navigator.pop(context);
                            _showConnectionSuccessDialog();
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

  /// 이름 선택 제출
  Future<void> _submitNameSelection(int? bot) async {
    if (_pendingAiId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    try {
      await _apiService.postInitialize({
        'id': int.tryParse(_pendingAiId!) ?? 0,
        'name': userId,
        'bot': bot,
      });
      _showSnackBar('인형 이름이 설정되었습니다.');
    } catch (e) {
      debugPrint('이름 설정 실패: $e');
    }
  }

  /// 연결 성공 다이얼로그
  void _showConnectionSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('$_pendingAiId 와 연결되었습니다.'),
          content: const Text('초기 화면으로 이동합니다.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context, _pendingAiId); // 검색 화면 닫기 (결과 반환)
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SignalR 메시지 감지
    return Consumer<SignalRProvider>(
      builder: (context, signalRProvider, child) {
        // 'U' 모드 메시지 처리 (인증 응답)
        final lastMessage = signalRProvider.lastMessage;

        // 디버그 로그
        if (lastMessage != null) {
          debugPrint('DollSearch: SignalR 메시지 수신 - mode: ${lastMessage.mode}, isWaitingAuth: $_isWaitingAuth');
        }

        if (lastMessage != null && lastMessage.mode == 85 && _isWaitingAuth) {
          // 85 = 'U'
          debugPrint('DollSearch: 인증 응답 처리 시작');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleAuthResponse(lastMessage);
          });
        }

        return _buildBody();
      },
    );
  }

  /// 인증 응답 처리
  void _handleAuthResponse(HubModel hubModel) {
    if (hubModel.json == null) return;

    try {
      final jsonData = jsonDecode(hubModel.json!.toLowerCase());
      final isSuccess = jsonData['response'] == true;

      if (isSuccess) {
        _onAuthSuccess();
      } else {
        _cancelAuthWait();
        _showSnackBar('연결에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('인증 응답 파싱 실패: $e');
    }
  }

  Widget _buildBody() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '인형검색',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 검색 입력
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchDoll,
              decoration: InputDecoration(
                hintText: '인형 ID를 입력하세요',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 검색 결과
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? '인형 ID를 입력하세요'
                                  : '검색 결과가 없습니다.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final doll = _searchResults[index];
                              return _buildDollItem(doll);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDollItem(Map<String, dynamic> doll) {
    final id = doll['id']?.toString() ?? '';
    final bot = doll['bot'] ?? 0;

    return GestureDetector(
      onTap: () => _onDollSelected(doll),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 인형 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _getBotImage(bot),
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.smart_toy, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            // 인형 번호
            Expanded(
              child: Text(
                id,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 화살표 아이콘
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 28,
            ),
          ],
        ),
      ),
    );
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
}
