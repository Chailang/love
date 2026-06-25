import 'dart:convert';
import 'package:flutter/services.dart';

/// 中国省 / 市 / 区三级数据（来源：modood/Administrative-divisions-of-China）
class ChinaRegions {
  ChinaRegions._();

  static const municipalities = {'北京市', '天津市', '上海市', '重庆市'};

  static Map<String, Map<String, List<String>>>? _data;
  static Future<void>? _loading;

  static Future<void> ensureLoaded() {
    _loading ??= _load();
    return _loading!;
  }

  static Future<void> _load() async {
    if (_data != null) return;
    final raw = await rootBundle.loadString('assets/data/pca-code.json');
    final list = jsonDecode(raw) as List<dynamic>;
    final map = <String, Map<String, List<String>>>{};
    for (final p in list) {
      final province = p['name'] as String;
      final cities = <String, List<String>>{};
      for (final c in (p['children'] as List<dynamic>? ?? [])) {
        final city = c['name'] as String;
        final districts = (c['children'] as List<dynamic>? ?? [])
            .map((d) => d['name'] as String)
            .toList();
        cities[city] = districts;
      }
      map[province] = cities;
    }
    _data = map;
  }

  static void _assertLoaded() {
    if (_data == null) {
      throw StateError('ChinaRegions 尚未加载，请先调用 ensureLoaded()');
    }
  }

  static bool isMunicipality(String province) => municipalities.contains(province);

  /// 直辖市的城市名与省名相同（如 北京市），普通省份返回下属地级市列表
  static List<String> citiesOf(String province) {
    _assertLoaded();
    return List.unmodifiable(_data![province]?.keys.toList() ?? const []);
  }

  static List<String> districtsOf(String province, String city) {
    _assertLoaded();
    if (isMunicipality(province)) {
      return List.unmodifiable(_data![province]?[province] ?? const []);
    }
    return List.unmodifiable(_data![province]?[city] ?? const []);
  }

  /// 获取某省下的全部区县（直辖市 / 普通城市均可用）
  static List<String> districtsOfCity(String province, String city) {
    _assertLoaded();
    if (isMunicipality(province)) {
      return districtsOf(province, province);
    }
    return districtsOf(province, city);
  }

  static String defaultProvince() {
    _assertLoaded();
    return provinces.first;
  }

  static String defaultCity(String province) {
    if (isMunicipality(province)) return province;
    final cities = citiesOf(province);
    return cities.isNotEmpty ? cities.first : '';
  }

  static String? defaultDistrict(String province, String city) {
    final districts = districtsOfCity(province, city);
    return districts.isNotEmpty ? districts.first : null;
  }

  /// 规范化选择结果（直辖市 city 统一为省名）
  static ({String province, String city}) normalize(String province, String city) {
    if (isMunicipality(province)) {
      return (province: province, city: province);
    }
    return (province: province, city: city);
  }

  /// UI 展示用地址文本
  static String formatAddress({
    required String? province,
    required String? city,
    String? district,
  }) {
    if (province == null) return '';
    if (isMunicipality(province)) {
      return district != null && district.isNotEmpty ? '$province $district' : province;
    }
    if (city == null) return province;
    if (district != null && district.isNotEmpty) {
      return '$province $city $district';
    }
    return '$province $city';
  }

  static List<String> get provinces {
    _assertLoaded();
    return _data!.keys.toList();
  }
}
