import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_response.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

/// 认证状态管理
class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  AuthResponse? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthResponse? get user => _user;

  /// 检查本地 Token
  Future<void> checkLoginStatus() async {
    final token = await TokenStorage.getToken();
    _isLoggedIn = token != null;
    notifyListeners();
  }

  /// 注册
  Future<bool> register(String phone, String password, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.register(phone, password, code);
      _user = AuthResponse.fromJson(resp.data);
      await TokenStorage.save(_user!.token, _user!.userId);
      _isLoggedIn = true;
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

  /// 登录
  Future<bool> login(String phone, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.login(phone, code);
      _user = AuthResponse.fromJson(resp.data);
      await TokenStorage.save(_user!.token, _user!.userId);
      _isLoggedIn = true;
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

  /// 发送验证码
  Future<bool> sendCode(String phone, String type) async {
    try {
      await _api.sendCode(phone, type);
      return true;
    } on DioException catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await TokenStorage.clear();
    _isLoggedIn = false;
    _user = null;
    _error = null;
    notifyListeners();
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      final msg = e.response?.data['error'] ?? e.response?.data['message'];
      return msg?.toString() ?? '请求失败';
    }
    return e.message ?? '网络错误';
  }
}