import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user_center.dart';
import '../services/api_client.dart';

/// 个人中心状态管理
class ProfileProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  UserCenter? _center;
  bool _isLoading = false;
  String? _error;

  UserCenter? get center => _center;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载个人中心数据
  Future<void> loadCenter() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.getUserCenter();
      _center = UserCenter.fromJson(resp.data);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 编辑资料
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.updateProfile(data);
      await loadCenter(); // 刷新
      return true;
    } on DioException catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 更新隐私
  Future<bool> updatePrivacy(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.updatePrivacy(data);
      await loadCenter();
      return true;
    } on DioException catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['error']?.toString() ?? '请求失败';
    }
    return e.message ?? '网络错误';
  }
}