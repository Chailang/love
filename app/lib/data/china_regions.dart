import 'dart:convert';
import 'package:flutter/services.dart';

/// 中国省 / 市 / 区三级数据（来源：modood/Administrative-divisions-of-China）
class ChinaRegions {
  ChinaRegions._();

  static Map<String, Map<String, List<String>>>? _data;
  static Future<void>? _loading;

  /// 懒加载 assets/data/pca-code.json
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

  static List<String> get provinces {
    _assertLoaded();
    return _data!.keys.toList();
  }

  static List<String> citiesOf(String province) {
    _assertLoaded();
    return List.unmodifiable(_data![province]?.keys.toList() ?? const []);
  }

  static List<String> districtsOf(String province, String city) {
    _assertLoaded();
    return List.unmodifiable(_data![province]?[city] ?? const []);
  }

  static String defaultProvince() {
    _assertLoaded();
    return provinces.first;
  }

  static String defaultCity(String province) {
    final cities = citiesOf(province);
    return cities.isNotEmpty ? cities.first : '';
  }

  static String? defaultDistrict(String province, String city) {
    final districts = districtsOf(province, city);
    return districts.isNotEmpty ? districts.first : null;
  }
}
