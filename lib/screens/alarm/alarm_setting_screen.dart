import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_model.dart';
import '../../models/message_profile_model.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/global_user_info.dart';

/// AlarmSettingScreen - 알람 수정 화면
/// Java의 Alarm_Setting.java와 동일한 기능
class AlarmSettingScreen extends StatefulWidget {
  final AlarmModel alarm;

  const AlarmSettingScreen({
    super.key,
    required this.alarm,
  });

  @override
  State<AlarmSettingScreen> createState() => _AlarmSettingScreenState();
}

class _AlarmSettingScreenState extends State<AlarmSettingScreen> {
  final _titleController = TextEditingController();
  final _contentsController = TextEditingController();

  MessageProfileModel? _selectedUser;

  // 시간 설정
  DateTime _selectedTime = DateTime.now();

  // 날짜 설정
  DateTime _selectedDate = DateTime.now();
  bool _isDateChanged = false;

  // 요일 선택 상태 (월화수목금토일)
  final List<bool> _selectedDays = [false, false, false, false, false, false, false];
  final List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  final List<int> _dayIndices = [1, 2, 3, 4, 5, 6, 0];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeFromAlarm();
  }

  /// 기존 알람 데이터로 초기화
  void _initializeFromAlarm() {
    final alarm = widget.alarm;

    _titleController.text = alarm.title ?? '';
    _contentsController.text = alarm.contents ?? '';

    // 시간 설정
    final timeOfDay = alarm.timeOfDay;
    if (timeOfDay != null) {
      _selectedTime = DateTime(2024, 1, 1, timeOfDay.hour, timeOfDay.minute);
    }

    // 날짜/요일 설정
    if (alarm.classification == 1) {
      // 특정 날짜
      final specificDate = alarm.specificDate;
      if (specificDate != null) {
        _selectedDate = specificDate;
        _isDateChanged = true;
      }
    } else {
      // 반복 요일 - division에서 요일 인덱스 파싱
      final division = alarm.division ?? '';
      for (int i = 0; i < division.length; i++) {
        final dayIndex = int.tryParse(division[i]);
        if (dayIndex != null) {
          // Java 인덱스를 Flutter 인덱스로 변환
          // Java: 0=일, 1=월, 2=화, 3=수, 4=목, 5=금, 6=토
          // Flutter: 0=월, 1=화, 2=수, 3=목, 4=금, 5=토, 6=일
          final flutterIndex = dayIndex == 0 ? 6 : dayIndex - 1;
          if (flutterIndex >= 0 && flutterIndex < 7) {
            _selectedDays[flutterIndex] = true;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentsController.dispose();
    super.dispose();
  }

  String _buildDivisionString() {
    final buffer = StringBuffer();
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        buffer.write(_dayIndices[i]);
      }
    }
    final chars = buffer.toString().split('');
    chars.sort();
    return chars.join();
  }

  bool get _hasSelectedDays => _selectedDays.any((d) => d);

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  bool _validateInputs() {
    if (_selectedUser == null) {
      _showError('보호 대상 아이디를 선택해주세요.');
      return false;
    }

    if (_titleController.text.trim().isEmpty || _contentsController.text.trim().isEmpty) {
      _showError('알람 이름과 내용은 전부 작성해 주셔야 합니다.');
      return false;
    }

    if (_hasSelectedDays && _isDateChanged && !_isToday) {
      _showError('날짜와 요일은 둘다 설정하실 수 없습니다.');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveAlarm() async {
    if (!_validateInputs()) return;

    setState(() => _isSubmitting = true);

    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    final userId = int.tryParse(GlobalUserInfo.instance.userId ?? '') ?? 0;

    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    int classification;
    String division;

    if (_hasSelectedDays) {
      classification = 0;
      division = _buildDivisionString();
    } else {
      classification = 1;
      division = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    }

    final updatedAlarm = AlarmModel(
      id: widget.alarm.id,
      title: _titleController.text.trim(),
      contents: _contentsController.text.trim(),
      on: widget.alarm.on ?? true,
      classification: classification,
      division: division,
      time: timeStr,
      ai: int.tryParse(_selectedUser!.id ?? ''),
      name: _selectedUser!.displayName,
    );

    debugPrint('AlarmSettingScreen: 알람 수정 시도');
    debugPrint('  - id: ${updatedAlarm.id}');
    debugPrint('  - title: ${updatedAlarm.title}');
    debugPrint('  - classification: ${updatedAlarm.classification}');
    debugPrint('  - division: ${updatedAlarm.division}');

    final success = await alarmProvider.updateAlarm(userId, updatedAlarm);

    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알람이 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedAlarm);
      }
    } else {
      _showError(alarmProvider.error ?? '알람 수정에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              width: double.infinity,
              height: 70,
              color: Colors.white,
              alignment: Alignment.center,
              child: const Text(
                '알람수정',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final users = userProvider.users;

                  // 기존 알람의 보호대상자 찾기
                  if (_selectedUser == null) {
                    final aiId = widget.alarm.ai?.toString();
                    for (final user in users) {
                      if (user.id == aiId) {
                        _selectedUser = user;
                        break;
                      }
                    }
                  }

                  return SingleChildScrollView(
                    child: Container(
                      color: const Color(0xFFE8E8E8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('보호 대상'),
                          _buildDropdown(users),
                          const SizedBox(height: 8),

                          _buildSectionTitle('알람 이름'),
                          _buildTextField(
                            controller: _titleController,
                            hint: '알람 이름을 입력하세요.',
                          ),
                          const SizedBox(height: 8),

                          _buildSectionTitle('알람 내용'),
                          _buildTextField(
                            controller: _contentsController,
                            hint: '알람 내용을 입력하세요.',
                          ),
                          const SizedBox(height: 8),

                          _buildSectionTitle('날짜 설정'),
                          _buildDatePicker(),
                          const SizedBox(height: 8),

                          _buildSectionTitle('시간 설정'),
                          _buildTimePicker(),
                          const SizedBox(height: 8),

                          _buildSectionTitle('요일 설정'),
                          _buildDaySelector(),
                          const SizedBox(height: 20),

                          _buildButtons(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<MessageProfileModel> users) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MessageProfileModel>(
          isExpanded: true,
          hint: const Text(
            '보호 대상 아이디를 선택해주세요.',
            style: TextStyle(color: Colors.grey),
          ),
          value: _selectedUser,
          items: users.map((user) {
            return DropdownMenuItem(
              value: user,
              child: Text(
                '${user.displayName} ${user.id}',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedUser = value);
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD8D8D8)),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD8D8D8)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 173,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _selectedDate,
        minimumDate: DateTime.now().subtract(const Duration(days: 1)),
        maximumDate: DateTime.now().add(const Duration(days: 365)),
        onDateTimeChanged: (DateTime newDate) {
          setState(() {
            _selectedDate = newDate;
            _isDateChanged = true;
          });
        },
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 173,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: _selectedTime,
        use24hFormat: true,
        onDateTimeChanged: (DateTime newTime) {
          setState(() {
            _selectedTime = newTime;
          });
        },
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = _selectedDays[index];
          final isWeekend = index == 5 || index == 6;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDays[index] = !_selectedDays[index];
              });
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF258AE4)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF258AE4)
                      : const Color(0xFFD8D8D8),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _dayLabels[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : isWeekend
                            ? Colors.red
                            : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _isSubmitting ? null : _saveAlarm,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF258AE4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '수정',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
