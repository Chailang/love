import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/geo_neighbor.dart';
import '../services/api_client.dart';

/// 同乡近邻状态管理
class GeoProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  // 我的位置档案
  Map<String, dynamic>? _myGeo;
  bool _hasLocation = false;
  bool _isLoading = false;
  String? _error;

  // 搜索相关
  String _activeTab = 'all';      // hometown / work / residence / all
  List<GeoNeighbor> _results = [];
  bool _isSearching = false;

  Map<String, dynamic>? get myGeo => _myGeo;
  bool get hasLocation => _hasLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get activeTab => _activeTab;
  List<GeoNeighbor> get results => _results;
  bool get isSearching => _isSearching;
  bool get isEmpty => _results.isEmpty && !_isSearching;

  /// 加载我的位置档案
  Future<void> loadMyGeo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.getMyGeo();
      _myGeo = resp.data as Map<String, dynamic>?;
      _hasLocation = _myGeo != null && _myGeo!['id'] != null;
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      // 404 = 未设置位置，不报错
      if (e.response?.statusCode != 404) {
        _error = _extractError(e);
      }
      _hasLocation = false;
      notifyListeners();
    }
  }

  /// 更新位置档案
  Future<bool> updateLocation({
    String? hometownProvince,
    String? hometownCity,
    String? hometownDistrict,
    String? workProvince,
    String? workCity,
    String? workDistrict,
    String? residenceProvince,
    String? residenceCity,
    String? residenceDistrict,
    double? residenceLat,
    double? residenceLng,
    bool? showHometown,
    bool? showWork,
    bool? showResidence,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (hometownProvince != null) data['hometownProvince'] = hometownProvince;
      if (hometownCity != null) data['hometownCity'] = hometownCity;
      if (hometownDistrict != null) data['hometownDistrict'] = hometownDistrict;
      if (workProvince != null) data['workProvince'] = workProvince;
      if (workCity != null) data['workCity'] = workCity;
      if (workDistrict != null) data['workDistrict'] = workDistrict;
      if (residenceProvince != null) data['residenceProvince'] = residenceProvince;
      if (residenceCity != null) data['residenceCity'] = residenceCity;
      if (residenceDistrict != null) data['residenceDistrict'] = residenceDistrict;
      if (residenceLat != null) data['residenceLat'] = residenceLat;
      if (residenceLng != null) data['residenceLng'] = residenceLng;
      if (showHometown != null) data['showHometown'] = showHometown;
      if (showWork != null) data['showWork'] = showWork;
      if (showResidence != null) data['showResidence'] = showResidence;

      await _api.updateMyGeo(data);
      _hasLocation = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 切换标签并搜索
  Future<void> switchTab(String tab) async {
    _activeTab = tab;
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      final resp = switch (tab) {
        'hometown' => await _api.searchHometown(),
        'work' => await _api.searchWork(),
        'residence' => await _api.searchResidence(),
        _ => await _api.searchAllGeo(),
      };

      final List data = resp.data is List ? resp.data : [];
      _results = data.map((json) => GeoNeighbor.fromJson(json)).toList();
      _isSearching = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = _extractError(e);
      _isSearching = false;
      notifyListeners();
    }
  }

  /// 初始化：加载位置 + 默认搜索
  Future<void> init() async {
    await loadMyGeo();
    if (_hasLocation) {
      await switchTab('all');
    }
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['error']?.toString() ?? '请求失败';
    }
    return e.message ?? '网络错误';
  }
}