import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_model.dart';
import '../../models/message_profile_model.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/global_user_info.dart';

/// AlarmAddScreen - 알람 추가 화면
/// Java의 Alarm_Add.java와 동일한 기능
class AlarmAddScreen extends StatefulWidget {
  const AlarmAddScreen({super.key});

  @override
  State<AlarmAddScreen> createState() => _AlarmAddScreenState();
}

class _AlarmAddScreenState extends State<AlarmAddScreen> {
  final _titleController = TextEditingController();
  final _contentsController = TextEditingController();

  MessageProfileModel? _selectedUser;

  // 시간 설정
  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  // 요일 선택 상태 (월화수목금토일)
  final List<bool> _selectedDays = [false, false, false, false, false, false, false];
  final List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  final List<int> _dayIndices = [1, 2, 3, 4, 5, 6, 0];

  bool _isSubmitting = false;

  // 앱 주요 색상
  static const Color primaryColor = Color(0xFF258AE4);
  static const Color primaryLightColor = Color(0xFF5BA8F0);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF1A1A2E);
  static const Color textSecondaryColor = Color(0xFF6B7280);

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

  bool _validateInputs() {
    if (_selectedUser == null) {
      _showError('보호 대상 아이디를 선택해주세요.');
      return false;
    }

    if (_titleController.text.trim().isEmpty || _contentsController.text.trim().isEmpty) {
      _showError('알람 이름과 내용은 전부 작성해 주셔야 합니다.');
      return false;
    }

    if (!_hasSelectedDays) {
      _showError('요일을 선택해주세요.');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveAlarm() async {
    if (!_validateInputs()) return;

    setState(() => _isSubmitting = true);

    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    final userId = int.tryParse(GlobalUserInfo.instance.userId ?? '') ?? 0;

    final timeStr = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';

    const int classification = 0;
    final String division = _buildDivisionString();

    final alarm = AlarmModel(
      id: '0',
      title: _titleController.text.trim(),
      contents: _contentsController.text.trim(),
      on: true,
      classification: classification,
      division: division,
      time: timeStr,
      ai: int.tryParse(_selectedUser!.id ?? ''),
      name: _selectedUser!.displayName,
    );

    debugPrint('AlarmAddScreen: 알람 저장 시도');
    debugPrint('  - title: ${alarm.title}');
    debugPrint('  - contents: ${alarm.contents}');
    debugPrint('  - time: ${alarm.time}');
    debugPrint('  - classification: ${alarm.classification}');
    debugPrint('  - division: ${alarm.division}');
    debugPrint('  - ai: ${alarm.ai}');

    final success = await alarmProvider.addAlarm(alarm, userId);

    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('정상적으로 알람이 추가 되었습니다.'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      _showError(alarmProvider.error ?? '알람 추가에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),

            // 스크롤 가능한 콘텐츠
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final users = userProvider.users;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 보호 대상 카드
                        _buildCard(
                          icon: Icons.person_outline,
                          title: '보호 대상',
                          child: _buildDropdown(users),
                        ),
                        const SizedBox(height: 16),

                        // 알람 정보 카드
                        _buildCard(
                          icon: Icons.edit_notifications_outlined,
                          title: '알람 정보',
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _titleController,
                                hint: '알람 이름을 입력하세요',
                                icon: Icons.label_outline,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _contentsController,
                                hint: '알람 내용을 입력하세요',
                                icon: Icons.notes,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 시간 설정 카드
                        _buildCard(
                          icon: Icons.access_time,
                          title: '시간 설정',
                          child: _buildTimePicker(),
                        ),
                        const SizedBox(height: 16),

                        // 요일 설정 카드
                        _buildCard(
                          icon: Icons.calendar_today_outlined,
                          title: '반복 요일',
                          child: _buildDaySelector(),
                        ),
                        const SizedBox(height: 24),

                        // 버튼
                        _buildButtons(),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: textPrimaryColor),
            splashRadius: 24,
          ),
          const Expanded(
            child: Text(
              '알람 추가',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 48), // 균형을 위한 여백
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          // 구분선
          Divider(height: 1, color: Colors.grey.shade200),
          // 카드 내용
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<MessageProfileModel> users) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MessageProfileModel>(
          isExpanded: true,
          hint: Text(
            '보호 대상을 선택해주세요',
            style: TextStyle(color: textSecondaryColor, fontSize: 15),
          ),
          value: _selectedUser,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
          items: users.map((user) {
            return DropdownMenuItem(
              value: user,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0] : '?',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textPrimaryColor,
                        ),
                      ),
                      Text(
                        'ID: ${user.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
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
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      enableIMEPersonalizedLearning: true,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: textPrimaryColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSecondaryColor.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: primaryColor, size: 22),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.05),
            primaryLightColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeSpinner(
            value: _selectedHour,
            maxValue: 23,
            onChanged: (value) => setState(() => _selectedHour = value),
            label: '시간',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 28),
                Text(
                  ':',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          _buildTimeSpinner(
            value: _selectedMinute,
            maxValue: 59,
            onChanged: (value) => setState(() => _selectedMinute = value),
            label: '분',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSpinner({
    required int value,
    required int maxValue,
    required Function(int) onChanged,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: 140,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 46,
            perspective: 0.003,
            diameterRatio: 1.3,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: maxValue + 1,
              builder: (context, index) {
                final isSelected = index == value;
                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                      color: isSelected ? primaryColor : Colors.grey.shade400,
                    ),
                    child: Text(index.toString().padLeft(2, '0')),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = _selectedDays[index];
        final isWeekend = index == 5 || index == 6;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDays[index] = !_selectedDays[index];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isSelected ? 46 : 42,
            height: isSelected ? 46 : 42,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [primaryColor, primaryLightColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : backgroundColor,
              borderRadius: BorderRadius.circular(isSelected ? 14 : 12),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  _dayLabels[index],
                  style: TextStyle(
                    fontSize: isSelected ? 15 : 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isWeekend
                            ? Colors.red.shade400
                            : textPrimaryColor,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 10,
                        color: primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        // 취소 버튼
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textSecondaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 완료 버튼
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _isSubmitting ? null : _saveAlarm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSubmitting
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [primaryColor, primaryLightColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isSubmitting
                    ? null
                    : [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            '알람 추가',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
