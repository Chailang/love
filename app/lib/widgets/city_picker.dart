import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../data/china_regions.dart';

/// 省 / 市双列选择器（全局通用）
class CityPicker extends StatefulWidget {
  final String? initialProvince;
  final String? initialCity;
  final ValueChanged<({String province, String city})>? onChanged;

  const CityPicker({
    super.key,
    this.initialProvince,
    this.initialCity,
    this.onChanged,
  });

  /// 底部弹层选择，返回 null 表示取消
  static Future<({String province, String city})?> show(
    BuildContext context, {
    String? initialProvince,
    String? initialCity,
  }) {
    return showModalBottomSheet<({String province, String city})>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) => _CityPickerSheet(
        initialProvince: initialProvince,
        initialCity: initialCity,
      ),
    );
  }

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  late String _province;
  late String _city;

  @override
  void initState() {
    super.initState();
    _province = widget.initialProvince ?? ChinaRegions.defaultProvince();
    final cities = ChinaRegions.citiesOf(_province);
    _city = widget.initialCity != null && cities.contains(widget.initialCity!)
        ? widget.initialCity!
        : ChinaRegions.defaultCity(_province);
  }

  void _selectProvince(String province) {
    setState(() {
      _province = province;
      _city = ChinaRegions.defaultCity(province);
    });
    widget.onChanged?.call((province: _province, city: _city));
  }

  void _selectCity(String city) {
    setState(() => _city = city);
    widget.onChanged?.call((province: _province, city: _city));
  }

  @override
  Widget build(BuildContext context) {
    final cities = ChinaRegions.citiesOf(_province);
    return SizedBox(
      height: 280,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ChinaRegions.provinces.length,
              itemBuilder: (_, i) {
                final p = ChinaRegions.provinces[i];
                final selected = p == _province;
                return ListTile(
                  dense: true,
                  title: Text(
                    p,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? AppTheme.primary : AppTheme.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: selected,
                  onTap: () => _selectProvince(p),
                );
              },
            ),
          ),
          Container(width: 1, color: AppTheme.divider),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (_, i) {
                final c = cities[i];
                final selected = c == _city;
                return ListTile(
                  dense: true,
                  title: Text(
                    c,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? AppTheme.primary : AppTheme.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: selected,
                  onTap: () => _selectCity(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  final String? initialProvince;
  final String? initialCity;

  const _CityPickerSheet({this.initialProvince, this.initialCity});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  late String _province;
  late String _city;

  @override
  void initState() {
    super.initState();
    _province = widget.initialProvince ?? ChinaRegions.defaultProvince();
    final cities = ChinaRegions.citiesOf(_province);
    _city = widget.initialCity != null && cities.contains(widget.initialCity!)
        ? widget.initialCity!
        : ChinaRegions.defaultCity(_province);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
        top: AppTheme.spacingMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              const Text('选择城市', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => Navigator.pop(context, (province: _province, city: _city)),
                child: const Text('确定'),
              ),
            ],
          ),
          CityPicker(
            initialProvince: _province,
            initialCity: _city,
            onChanged: (v) {
              setState(() {
                _province = v.province;
                _city = v.city;
              });
            },
          ),
        ],
      ),
    );
  }
}

/// 可点击的城市选择行
class CityPickerTile extends StatelessWidget {
  final String label;
  final String? province;
  final String? city;
  final VoidCallback onTap;

  const CityPickerTile({
    super.key,
    required this.label,
    this.province,
    this.city,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = (province != null && city != null) ? '$province $city' : '请选择';
    return InkWell(
      onTap: onTap,
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
                  Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    display,
                    style: TextStyle(
                      fontSize: 16,
                      color: province != null ? AppTheme.textPrimary : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
