import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/city_picker.dart';
import '../../widgets/birthday_wheel_picker.dart';
import '../../data/china_regions.dart';
import '../../services/profile_provider.dart';
import '../../services/geo_provider.dart';
import '../../services/app_navigation.dart';

/// 分步资料向导
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _stepCount = 4;

  final _pageController = PageController();
  int _step = 0;
  bool _submitting = false;
  bool _regionsReady = false;

  String? _gender;
  DateTime? _birthDate;
  String? _residenceProvince;
  String? _residenceCity;
  String? _residenceDistrict;
  String? _workDistrict;
  String? _hometownProvince;
  String? _hometownCity;

  @override
  void initState() {
    super.initState();
    ChinaRegions.ensureLoaded().then((_) {
      if (mounted) setState(() => _regionsReady = true);
    });
  }

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
      3 => _hometownProvince != null && _hometownCity != null,
      _ => false,
    };
  }

  void _next() {
    if (!_canNext) return;
    if (_step < _stepCount - 1) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit();
    }
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
      residenceDistrict: _residenceDistrict,
      workProvince: _residenceProvince,
      workCity: _residenceCity,
      workDistrict: _workDistrict,
      hometownProvince: _hometownProvince,
      hometownCity: _hometownCity,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!geoOk) {
      _showSnack(geo.error ?? '位置信息保存失败，可稍后在「我的」中补充');
    }

    await navigateToHome(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickBirthday() async {
    final picked = await BirthdayWheelPicker.show(context, initial: _birthDate);
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickResidenceCity() async {
    final result = await CityPicker.show(
      context,
      initialProvince: _residenceProvince,
      initialCity: _residenceCity,
      title: '选择居住城市',
    );
    if (result != null) {
      final n = ChinaRegions.normalize(result.province, result.city);
      setState(() {
        _residenceProvince = n.province;
        _residenceCity = n.city;
        _residenceDistrict = null;
        _workDistrict = null;
      });
    }
  }

  Future<void> _pickResidenceDistrict() async {
    if (_residenceProvince == null || _residenceCity == null) {
      _showSnack('请先选择居住城市');
      return;
    }
    final picked = await DistrictPicker.show(
      context,
      province: _residenceProvince!,
      city: _residenceCity!,
      initialDistrict: _residenceDistrict,
      title: '选择居住区域',
    );
    if (picked != null) setState(() => _residenceDistrict = picked);
  }

  Future<void> _pickWorkDistrict() async {
    if (_residenceProvince == null || _residenceCity == null) {
      _showSnack('请先选择居住城市');
      return;
    }
    final picked = await DistrictPicker.show(
      context,
      province: _residenceProvince!,
      city: _residenceCity!,
      initialDistrict: _workDistrict,
      title: '选择工作区域',
    );
    if (picked != null) setState(() => _workDistrict = picked);
  }

  Future<void> _pickHometown() async {
    final result = await CityPicker.show(
      context,
      initialProvince: _hometownProvince,
      initialCity: _hometownCity,
      title: '选择故乡',
    );
    if (result != null) {
      final n = ChinaRegions.normalize(result.province, result.city);
      setState(() {
        _hometownProvince = n.province;
        _hometownCity = n.city;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _step == _stepCount - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('完善资料 (${_step + 1}/$_stepCount)'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / _stepCount,
            backgroundColor: AppTheme.divider,
            color: AppTheme.primary,
            minHeight: 3,
          ),
          Expanded(
            child: _regionsReady
                ? PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _stepShell('你的性别是？', _buildGenderStep(), hint: '注册后不可更改'),
                      _stepShell('你的生日是？', _buildBirthdayStep(), hint: '注册后不可更改'),
                      _stepShell('你的位置信息', _buildLocationStep(), subtitle: '填写后可匹配附近的人'),
                      _stepShell('你的故乡是？', _buildHometownStep()),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
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
              onPressed: (!_canNext || _submitting || !_regionsReady) ? null : _next,
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

  Widget _stepShell(String title, Widget body, {String? subtitle, String? hint}) {
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
          Expanded(child: SingleChildScrollView(child: body)),
          if (hint != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
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
            const Icon(Icons.date_range_outlined, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    final hasResidenceCity = _residenceProvince != null && _residenceCity != null;
    final districts = hasResidenceCity
        ? ChinaRegions.districtsOfCity(_residenceProvince!, _residenceCity!)
        : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CityPickerTile(
          label: '居住城市 *',
          province: _residenceProvince,
          city: _residenceCity,
          onTap: _pickResidenceCity,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        CityPickerTile(
          label: '居住区域（选填）',
          districtOnly: true,
          district: _residenceDistrict,
          placeholder: hasResidenceCity
              ? (districts.isEmpty ? '该城市暂无区县数据' : '请选择区 / 县')
              : '请先选择居住城市',
          onTap: () {
            if (!hasResidenceCity) {
              _showSnack('请先选择居住城市');
            } else if (districts.isEmpty) {
              _showSnack('该城市暂无区县数据');
            } else {
              _pickResidenceDistrict();
            }
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        CityPickerTile(
          label: '工作区域（选填）',
          districtOnly: true,
          district: _workDistrict,
          placeholder: hasResidenceCity
              ? (districts.isEmpty ? '该城市暂无区县数据' : '请选择区 / 县')
              : '请先选择居住城市',
          onTap: _pickWorkDistrict,
        ),
      ],
    );
  }

  Widget _buildHometownStep() {
    return CityPickerTile(
      label: '故乡',
      province: _hometownProvince,
      city: _hometownCity,
      onTap: _pickHometown,
    );
  }
}
