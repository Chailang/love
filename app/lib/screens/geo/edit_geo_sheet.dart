import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/geo_provider.dart';

/// 位置档案编辑页面
class EditGeoSheet extends StatefulWidget {
  const EditGeoSheet({super.key});

  @override
  State<EditGeoSheet> createState() => _EditGeoSheetState();
}

class _EditGeoSheetState extends State<EditGeoSheet> {
  final _hometownProvince = TextEditingController();
  final _hometownCity = TextEditingController();
  final _hometownDistrict = TextEditingController();
  final _workProvince = TextEditingController();
  final _workCity = TextEditingController();
  final _workDistrict = TextEditingController();
  final _residenceProvince = TextEditingController();
  final _residenceCity = TextEditingController();
  final _residenceDistrict = TextEditingController();

  bool _showHometown = true;
  bool _showWork = true;
  bool _showResidence = true;

  @override
  void initState() {
    super.initState();
    final geo = context.read<GeoProvider>().myGeo;
    if (geo != null) {
      _hometownProvince.text = geo['hometownProvince'] as String? ?? '';
      _hometownCity.text = geo['hometownCity'] as String? ?? '';
      _hometownDistrict.text = geo['hometownDistrict'] as String? ?? '';
      _workProvince.text = geo['workProvince'] as String? ?? '';
      _workCity.text = geo['workCity'] as String? ?? '';
      _workDistrict.text = geo['workDistrict'] as String? ?? '';
      _residenceProvince.text = geo['residenceProvince'] as String? ?? '';
      _residenceCity.text = geo['residenceCity'] as String? ?? '';
      _residenceDistrict.text = geo['residenceDistrict'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _hometownProvince.dispose();
    _hometownCity.dispose();
    _hometownDistrict.dispose();
    _workProvince.dispose();
    _workCity.dispose();
    _workDistrict.dispose();
    _residenceProvince.dispose();
    _residenceCity.dispose();
    _residenceDistrict.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<GeoProvider>();
    final ok = await provider.updateLocation(
      hometownProvince: _hometownProvince.text,
      hometownCity: _hometownCity.text,
      hometownDistrict: _hometownDistrict.text,
      workProvince: _workProvince.text,
      workCity: _workCity.text,
      workDistrict: _workDistrict.text,
      residenceProvince: _residenceProvince.text,
      residenceCity: _residenceCity.text,
      residenceDistrict: _residenceDistrict.text,
      showHometown: _showHometown,
      showWork: _showWork,
      showResidence: _showResidence,
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置信息已保存 ✅')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? '保存失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GeoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('位置档案'),
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
            _sectionTitle('🏠 家乡（同乡匹配）'),
            const SizedBox(height: AppTheme.spacingSm),
            _buildInputRow('省', _hometownProvince, '市', _hometownCity, '区', _hometownDistrict),
            _privacySwitch('允许同乡搜索', _showHometown, (v) => setState(() => _showHometown = v)),

            const SizedBox(height: AppTheme.spacingXl),
            _sectionTitle('💼 工作（同行匹配）'),
            const SizedBox(height: AppTheme.spacingSm),
            _buildInputRow('省', _workProvince, '市', _workCity, '区', _workDistrict),
            _privacySwitch('允许工作搜索', _showWork, (v) => setState(() => _showWork = v)),

            const SizedBox(height: AppTheme.spacingXl),
            _sectionTitle('📍 居住（近邻匹配）'),
            const SizedBox(height: AppTheme.spacingSm),
            _buildInputRow('省', _residenceProvince, '市', _residenceCity, '区', _residenceDistrict),
            _privacySwitch('允许近邻搜索', _showResidence, (v) => setState(() => _showResidence = v)),

            const SizedBox(height: AppTheme.spacingXl),
            Text(
              '⚠️ 为保护隐私，搜索时仅显示省/市/区级别，不暴露精确位置',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildInputRow(
    String label1, TextEditingController ctrl1,
    String label2, TextEditingController ctrl2,
    String label3, TextEditingController ctrl3,
  ) {
    return Row(
      children: [
        Expanded(child: _inputField(label1, ctrl1)),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(child: _inputField(label2, ctrl2)),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(child: _inputField(label3, ctrl3)),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _privacySwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const Spacer(),
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary),
      ],
    );
  }
}