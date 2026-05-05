import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_profile_model.dart';
import '../../providers/user_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  final MessageProfileModel user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _protectedPersonController;
  late final TextEditingController _protectedPhoneController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _agencyController;
  bool? _male;
  bool? _initialMale;
  bool _isSaving = false;
  bool _hasChanges = false;

  // 초기값 저장
  late final String _initialName;
  late final String _initialProtectedPerson;
  late final String _initialProtectedPhone;
  late final String _initialPhone;
  late final String _initialAddress;
  late final String _initialAgency;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.profile;
    debugPrint('=== 프로필 수정 화면 ===');
    debugPrint('user.id: ${widget.user.id}');
    debugPrint('user.name: ${widget.user.name}');
    debugPrint('user.displayName: ${widget.user.displayName}');
    debugPrint('profile: $profile');
    debugPrint('profile.id: ${profile?.id}');
    debugPrint('profile.name: ${profile?.name}');
    debugPrint('profile.protectedPerson: ${profile?.protectedPerson}');
    debugPrint('profile.protectedPhone: ${profile?.protectedPhone}');
    debugPrint('profile.phone: ${profile?.phone}');
    debugPrint('profile.address: ${profile?.address}');
    debugPrint('profile.agency: ${profile?.agency}');
    debugPrint('profile.male: ${profile?.male}');
    debugPrint('========================');

    _initialName = (profile?.name ?? widget.user.displayName).trim();
    _initialProtectedPerson = (profile?.protectedPerson ?? '').trim();
    _initialProtectedPhone = (profile?.protectedPhone ?? '').trim();
    _initialPhone = (profile?.phone ?? '').trim();
    _initialAddress = (profile?.address ?? '').trim();
    _initialAgency = (profile?.agency ?? '').trim();
    _initialMale = profile?.male;

    _nameController = TextEditingController(text: _initialName);
    _protectedPersonController = TextEditingController(text: _initialProtectedPerson);
    _protectedPhoneController = TextEditingController(text: _initialProtectedPhone);
    _phoneController = TextEditingController(text: _initialPhone);
    _addressController = TextEditingController(text: _initialAddress);
    _agencyController = TextEditingController(text: _initialAgency);
    _male = _initialMale;

    _nameController.addListener(_checkChanges);
    _protectedPersonController.addListener(_checkChanges);
    _protectedPhoneController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
    _agencyController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed = _nameController.text != _initialName ||
        _protectedPersonController.text != _initialProtectedPerson ||
        _protectedPhoneController.text != _initialProtectedPhone ||
        _phoneController.text != _initialPhone ||
        _addressController.text != _initialAddress ||
        _agencyController.text != _initialAgency ||
        _male != _initialMale;

    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _protectedPersonController.dispose();
    _protectedPhoneController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _agencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final profileData = <String, dynamic>{
      'id': widget.user.profile?.id,
      'name': _nameController.text.trim(),
      'protectedPerson': _protectedPersonController.text.trim(),
      'protectedPhone': _protectedPhoneController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'agency': _agencyController.text.trim(),
      'male': _male,
    };

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateUserProfile(profileData);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('프로필 수정'),
        backgroundColor: const Color(0xFF258AE4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          children: [
            // 인형 이미지 + 인형번호
            Center(
              child: Column(
                children: [
                  ClipOval(
                    child: Image.asset(
                      widget.user.botImagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.user.id ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField('보호자 이름', _protectedPersonController),
            _buildTextField('보호자 연락처', _phoneController,
                keyboardType: TextInputType.phone),
            _buildTextField('보호대상자 이름', _nameController),
            _buildTextField('보호대상자 연락처', _protectedPhoneController,
                keyboardType: TextInputType.phone),
            _buildTextField('주소', _addressController),
            _buildTextField('기관', _agencyController),

            // 성별
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '성별',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 20),
                ChoiceChip(
                  label: const Text('남성'),
                  selected: _male == true,
                  selectedColor: const Color(0xFF258AE4).withValues(alpha: 0.2),
                  onSelected: (v) {
                    setState(() => _male = true);
                    _checkChanges();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('여성'),
                  selected: _male == false,
                  selectedColor: const Color(0xFF258AE4).withValues(alpha: 0.2),
                  onSelected: (v) {
                    setState(() => _male = false);
                    _checkChanges();
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 취소하기 / 저장하기 버튼
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '취소하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_hasChanges && !_isSaving) ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF258AE4),
                        disabledBackgroundColor: const Color(0xFF258AE4).withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              '설정하기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF258AE4), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
