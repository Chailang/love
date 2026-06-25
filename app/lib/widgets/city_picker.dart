import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../data/china_regions.dart';

typedef RegionSelection = ({String province, String city, String? district});

/// 省 / 市 / 区选择器（直辖市自动隐藏「市辖区」，仅显示省 + 区）
class CityPicker extends StatefulWidget {
  final String? initialProvince;
  final String? initialCity;
  final String? initialDistrict;
  final bool showDistrict;
  final ValueChanged<RegionSelection>? onChanged;

  const CityPicker({
    super.key,
    this.initialProvince,
    this.initialCity,
    this.initialDistrict,
    this.showDistrict = false,
    this.onChanged,
  });

  static Future<RegionSelection?> show(
    BuildContext context, {
    String? initialProvince,
    String? initialCity,
    String? initialDistrict,
    bool showDistrict = false,
    String title = '选择城市',
  }) async {
    await ChinaRegions.ensureLoaded();
    if (!context.mounted) return null;
    return showModalBottomSheet<RegionSelection>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) => _CityPickerSheet(
        initialProvince: initialProvince,
        initialCity: initialCity,
        initialDistrict: initialDistrict,
        showDistrict: showDistrict,
        title: title,
      ),
    );
  }

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  late String _province;
  late String _city;
  String? _district;

  @override
  void initState() {
    super.initState();
    _initSelection();
  }

  void _initSelection() {
    _province = widget.initialProvince ?? ChinaRegions.defaultProvince();
    _city = _resolveCity(_province, widget.initialCity);
    final districts = ChinaRegions.districtsOfCity(_province, _city);
    _district = widget.initialDistrict != null && districts.contains(widget.initialDistrict!)
        ? widget.initialDistrict
        : (widget.showDistrict && districts.isNotEmpty ? districts.first : null);
  }

  String _resolveCity(String province, String? city) {
    final cities = ChinaRegions.citiesOf(province);
    if (city != null && cities.contains(city)) return city;
    return ChinaRegions.defaultCity(province);
  }

  void _notify() {
    final n = ChinaRegions.normalize(_province, _city);
    widget.onChanged?.call((province: n.province, city: n.city, district: _district));
  }

  void _selectProvince(String province) {
    setState(() {
      _province = province;
      _city = ChinaRegions.defaultCity(province);
      final districts = ChinaRegions.districtsOfCity(_province, _city);
      _district = widget.showDistrict && districts.isNotEmpty ? districts.first : null;
    });
    _notify();
  }

  void _selectCity(String city) {
    setState(() {
      _city = city;
      final districts = ChinaRegions.districtsOfCity(_province, _city);
      _district = widget.showDistrict && districts.isNotEmpty ? districts.first : null;
    });
    _notify();
  }

  void _selectDistrict(String district) {
    setState(() => _district = district);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final cities = ChinaRegions.citiesOf(_province);
    final districts = ChinaRegions.districtsOfCity(_province, _city);

    return SizedBox(
      height: 280,
      child: Row(
        children: [
          Expanded(child: _buildList(ChinaRegions.provinces, _province, _selectProvince)),
          _divider,
          Expanded(child: _buildList(cities, _city, _selectCity)),
          if (widget.showDistrict) ...[
            _divider,
            Expanded(
              child: districts.isEmpty
                  ? const Center(child: Text('暂无区县', style: TextStyle(color: AppTheme.textHint, fontSize: 13)))
                  : _buildList(districts, _district ?? '', _selectDistrict),
            ),
          ],
        ],
      ),
    );
  }

  Widget get _divider => Container(width: 1, color: AppTheme.divider);

  Widget _buildList(List<String> items, String selected, ValueChanged<String> onTap) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final isSelected = item == selected;
        return ListTile(
          dense: true,
          title: Text(
            item,
            style: TextStyle(
              fontSize: widget.showDistrict ? 13 : 14,
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onTap: () => onTap(item),
        );
      },
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  final String? initialProvince;
  final String? initialCity;
  final String? initialDistrict;
  final bool showDistrict;
  final String title;

  const _CityPickerSheet({
    this.initialProvince,
    this.initialCity,
    this.initialDistrict,
    this.showDistrict = false,
    this.title = '选择城市',
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  late String _province;
  late String _city;
  String? _district;

  @override
  void initState() {
    super.initState();
    _province = widget.initialProvince ?? ChinaRegions.defaultProvince();
    final cities = ChinaRegions.citiesOf(_province);
    _city = widget.initialCity != null && cities.contains(widget.initialCity!)
        ? widget.initialCity!
        : ChinaRegions.defaultCity(_province);
    final districts = ChinaRegions.districtsOfCity(_province, _city);
    _district = widget.initialDistrict != null && districts.contains(widget.initialDistrict!)
        ? widget.initialDistrict
        : (widget.showDistrict && districts.isNotEmpty ? districts.first : null);
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
              Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () {
                  final n = ChinaRegions.normalize(_province, _city);
                  Navigator.pop(context, (province: n.province, city: n.city, district: _district));
                },
                child: const Text('确定'),
              ),
            ],
          ),
          CityPicker(
            initialProvince: _province,
            initialCity: _city,
            initialDistrict: _district,
            showDistrict: widget.showDistrict,
            onChanged: (v) {
              setState(() {
                _province = v.province;
                _city = v.city;
                _district = v.district;
              });
            },
          ),
        ],
      ),
    );
  }
}

/// 区县选择（基于已选省 / 市，直辖市同样适用）
class DistrictPicker {
  static Future<String?> show(
    BuildContext context, {
    required String province,
    required String city,
    String? initialDistrict,
    String title = '选择区域',
  }) async {
    await ChinaRegions.ensureLoaded();
    final normalized = ChinaRegions.normalize(province, city);
    final districts = ChinaRegions.districtsOfCity(normalized.province, normalized.city);
    if (districts.isEmpty) return null;
    if (!context.mounted) return null;

    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(width: 48),
              ],
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                itemCount: districts.length,
                itemBuilder: (_, i) {
                  final d = districts[i];
                  final isSelected = d == initialDistrict;
                  return ListTile(
                    title: Text(
                      d,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary, size: 20) : null,
                    onTap: () => Navigator.pop(ctx, d),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 可点击的城市 / 区域选择行
class CityPickerTile extends StatelessWidget {
  final String label;
  final String? province;
  final String? city;
  final String? district;
  final String placeholder;
  final bool districtOnly;
  final VoidCallback onTap;

  const CityPickerTile({
    super.key,
    required this.label,
    this.province,
    this.city,
    this.district,
    this.placeholder = '请选择',
    this.districtOnly = false,
    required this.onTap,
  });

  String get _display {
    if (districtOnly) {
      return district != null && district!.isNotEmpty ? district! : placeholder;
    }
    if (province == null) return placeholder;
    final text = ChinaRegions.formatAddress(province: province, city: city, district: district);
    return text.isEmpty ? placeholder : text;
  }

  bool get _hasValue {
    if (districtOnly) return district != null && district!.isNotEmpty;
    return province != null && (ChinaRegions.isMunicipality(province!) || city != null);
  }

  @override
  Widget build(BuildContext context) {
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
                    _display,
                    style: TextStyle(
                      fontSize: 16,
                      color: _hasValue ? AppTheme.textPrimary : AppTheme.textHint,
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
