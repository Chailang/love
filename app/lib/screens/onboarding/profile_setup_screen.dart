import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/city_picker.dart';
import '../../services/profile_provider.dart';
import '../../services/geo_provider.dart';
import '../../services/app_navigation.dart';

/// 分步资料向导 — 一页一项
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _stepTitles = ['性别', '生日', '居住城市', '居住区域', '工作区域', '故乡'];

  final _pageController = PageController();
  int _step = 0;
  bool _submitting = false;

  String? _gender;
  DateTime? _birthDate;
  String? _residenceProvince;
  String? _residenceCity;
  String? _residenceDistrict;
  String? _workProvince;
  String? _workCity;
  String? _hometownProvince;
  String? _hometownCity;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canNext {
    return switch (_step) {
      0 => _gender != null,
      1 => _birthDate != null,
      2 => _residenceProvince != null && _residenceCity != null,
      3 => true,
      4 => true,
      5 => _hometownProvince != null && _hometownCity != null,
      _ => false,
    };
  }

  void _next() {
    if (!_canNext) return;
    if (_step < _stepTitles.length - 1) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _skipOptional() {
    if (_step == 3 || _step == 4) _next();
  }

  Future<void> _submit() async {
    if (_gender == null || _birthDate == null || _residenceCity == null || _hometownCity == null) {
      _showSnack('请完成必填项');
      return;
    }

    setState(() => _submitting = true);

    final profile = context.read<ProfileProvider>();
    final geo = context.read<GeoProvider>();

    final birthStr =
        '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';

    final profileOk = await profile.updateProfile({
      'gender': _gender,
      'birthDate': birthStr,
      'city': _residenceCity,
    });

    if (!profileOk) {
      if (mounted) {
        setState(() => _submitting = false);
        _showSnack(profile.error ?? '资料保存失败');
      }
      return;
    }

    final geoOk = await geo.updateLocation(
      residenceProvince: _residenceProvince,
      residenceCity: _residenceCity,
      residenceDistrict: _residenceDistrict?.trim().isEmpty == true ? null : _residenceDistrict,
      workProvince: _workProvince,
      workCity: _workCity,
      hometownProvince: _hometownProvince,
      hometownCity: _hometownCity,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!geoOk) {
      _showSnack(geo.error ?? '位置信息保存失败');
      return;
    }

    await navigateAfterAuth(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: '选择生日',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickCity({
    required void Function(String province, String city) onPick,
    String? province,
    String? city,
  }) async {
    final result = await CityPicker.show(
      context,
      initialProvince: province,
      initialCity: city,
    );
    if (result != null) onPick(result.province, result.city);
  }

  @override
  Widget build(BuildContext context) {
    final isOptional = _step == 3 || _step == 4;
    final isLast = _step == _stepTitles.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('完善资料 (${_step + 1}/${_stepTitles.length})'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / _stepTitles.length,
            backgroundColor: AppTheme.divider,
            color: AppTheme.primary,
            minHeight: 3,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _stepShell('你的性别是？', _buildGenderStep()),
                _stepShell('你的生日是？', _buildBirthdayStep()),
                _stepShell('你居住在哪座城市？', _buildResidenceCityStep()),
                _stepShell('居住区域（选填）', _buildResidenceDistrictStep(), subtitle: '填写后可匹配附近的人'),
                _stepShell('工作区域（选填）', _buildWorkAreaStep(), subtitle: '填写后可匹配附近的人'),
                _stepShell('你的故乡是？', _buildHometownStep()),
              ],
            ),
          ),
          if (isOptional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePaddingH),
              child: TextButton(onPressed: _skipOptional, child: const Text('跳过')),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePaddingH,
              AppTheme.spacingSm,
              AppTheme.pagePaddingH,
              AppTheme.spacingXl,
            ),
            child: AppPrimaryButton(
              inset: false,
              onPressed: (!_canNext || _submitting) ? null : _next,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isLast ? '完成' : '下一步'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepShell(String title, Widget body, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTheme.spacingXl),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
          const SizedBox(height: AppTheme.spacingXl),
          body,
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Row(
      children: [
        Expanded(child: _genderCard('MALE', '男', Icons.male)),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(child: _genderCard('FEMALE', '女', Icons.female)),
      ],
    );
  }

  Widget _genderCard(String value, String label, IconData icon) {
    final selected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.08) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: selected ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingSm),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayStep() {
    final text = _birthDate == null
        ? '点击选择生日'
        : '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日';
    return InkWell(
      onTap: _pickBirthday,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('生日', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _birthDate != null ? AppTheme.textPrimary : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceCityStep() {
    return CityPickerTile(
      label: '居住城市',
      province: _residenceProvince,
      city: _residenceCity,
      onTap: () => _pickCity(
        province: _residenceProvince,
        city: _residenceCity,
        onPick: (p, c) => setState(() {
          _residenceProvince = p;
          _residenceCity = c;
        }),
      ),
    );
  }

  Widget _buildResidenceDistrictStep() {
    return TextField(
      decoration: const InputDecoration(
        hintText: '如：朝阳区、浦东新区（可不填）',
        labelText: '区 / 县',
      ),
      onChanged: (v) => _residenceDistrict = v,
    );
  }

  Widget _buildWorkAreaStep() {
    return CityPickerTile(
      label: '工作城市',
      province: _workProvince,
      city: _workCity,
      onTap: () => _pickCity(
        province: _workProvince,
        city: _workCity,
        onPick: (p, c) => setState(() {
          _workProvince = p;
          _workCity = c;
        }),
      ),
    );
  }

  Widget _buildHometownStep() {
    return CityPickerTile(
      label: '故乡',
      province: _hometownProvince,
      city: _hometownCity,
      onTap: () => _pickCity(
        province: _hometownProvince,
        city: _hometownCity,
        onPick: (p, c) => setState(() {
          _hometownProvince = p;
          _hometownCity = c;
        }),
      ),
    );
  }
}
