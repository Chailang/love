import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/profile_provider.dart';

/// 资料编辑页
class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _nickname = TextEditingController();
  final _school = TextEditingController();
  final _education = TextEditingController();
  final _occupation = TextEditingController();
  final _city = TextEditingController();
  final _height = TextEditingController();
  final _salary = TextEditingController();
  final _bio = TextEditingController();

  String? _gender;
  String? _birthDate;

  @override
  void initState() {
    super.initState();
    final c = context.read<ProfileProvider>().center;
    if (c != null) {
      _nickname.text = c.nickname ?? '';
      _school.text = c.school ?? '';
      _education.text = c.education ?? '';
      _occupation.text = c.occupation ?? '';
      _city.text = c.city ?? '';
      _height.text = c.height?.toString() ?? '';
      _salary.text = c.salaryRange ?? '';
      _bio.text = c.bio ?? '';
      _gender = c.gender;
    }
  }

  @override
  void dispose() {
    _nickname.dispose();
    _school.dispose();
    _education.dispose();
    _occupation.dispose();
    _city.dispose();
    _height.dispose();
    _salary.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<ProfileProvider>();
    final data = <String, dynamic>{
      'nickname': _nickname.text,
      'school': _school.text,
      'education': _education.text,
      'occupation': _occupation.text,
      'city': _city.text,
      'height': int.tryParse(_height.text),
      'salaryRange': _salary.text,
      'bio': _bio.text,
    };
    if (_gender != null) data['gender'] = _gender;
    if (_birthDate != null) data['birthDate'] = _birthDate;

    final ok = await provider.updateProfile(data);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('资料已保存 ✅')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18),
      helpText: '选择出生日期',
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: provider.isLoading ? null : _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 性别选择
            _sectionTitle('性别'),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: _genderCard('男', Icons.male, _gender == '男'),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _genderCard('女', Icons.female, _gender == '女'),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // 出生日期
            _sectionTitle('出生日期'),
            const SizedBox(height: AppTheme.spacingSm),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  _birthDate ?? '选择出生日期',
                  style: TextStyle(
                    color: _birthDate != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // 各字段
            _sectionTitle('基本信息'),
            const SizedBox(height: AppTheme.spacingSm),
            _input('昵称', _nickname),
            _input('所在城市', _city),
            _input('身高 (cm)', _height, keyboardType: TextInputType.number),
            _input('薪资范围', _salary, hint: '如 20-30万'),

            const SizedBox(height: AppTheme.spacingLg),
            _sectionTitle('教育 & 职业'),
            const SizedBox(height: AppTheme.spacingSm),
            _input('学校', _school),
            _input('学历', _education, hint: '如 硕士/博士/本科'),
            _input('职业', _occupation),

            const SizedBox(height: AppTheme.spacingLg),
            _sectionTitle('个人简介'),
            const SizedBox(height: AppTheme.spacingSm),
            TextField(
              controller: _bio,
              maxLines: 4,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: '介绍一下自己，让更多人认识你...',
                counterText: '',
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary));
  }

  Widget _input(String label, TextEditingController ctrl, {String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _genderCard(String label, IconData icon, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : AppTheme.textSecondary, size: 28),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}