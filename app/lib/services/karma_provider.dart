import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/karma_models.dart';
import '../services/api_client.dart';

/// 缘分盲盒状态管理
class KarmaProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  KarmaAccount? _account;
  KarmaResult? _lastResult;
  List<KarmaResult>? _multiResults; // 十连抽结果
  bool _isLoading = false;
  bool _isDrawing = false; // 抽奖动画中
  String? _error;

  KarmaAccount? get account => _account;
  KarmaResult? get lastResult => _lastResult;
  List<KarmaResult>? get multiResults => _multiResults;
  bool get isLoading => _isLoading;
  bool get isDrawing => _isDrawing;
  String? get error => _error;

  /// 加载账户信息
  Future<void> loadAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.getKarmaAccount();
      _account = KarmaAccount.fromJson(resp.data);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 盲盒抽一次
  Future<bool> playBlind() async {
    _isDrawing = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.playBlind();
      final result = KarmaResult.fromJson(resp.data);
      _lastResult = result;
      _multiResults = null;
      _isDrawing = false;
      // 刷新账户
      _account = KarmaAccount(
        userId: _account?.userId ?? 0,
        balance: result.coinBalance,
        totalEarned: _account?.totalEarned ?? 0,
        totalSpent: (_account?.totalSpent ?? 0) + 5,
        pityCounter: result.pityCounter,
        dailyBlindUsed: (_account?.dailyBlindUsed ?? 0) + 1,
        dailyDiceUsed: _account?.dailyDiceUsed ?? 0,
        dailyGachaUsed: _account?.dailyGachaUsed ?? 0,
      );
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = _extractError(e);
      _isDrawing = false;
      notifyListeners();
      return false;
    }
  }

  /// 骰子
  Future<bool> playDice() async {
    _isDrawing = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.playDice();
      final result = KarmaResult.fromJson(resp.data);
      _lastResult = result;
      _multiResults = null;
      _isDrawing = false;
      _account = KarmaAccount(
        userId: _account?.userId ?? 0,
        balance: result.coinBalance,
        totalEarned: _account?.totalEarned ?? 0,
        totalSpent: (_account?.totalSpent ?? 0) + 3,
        pityCounter: result.pityCounter,
        dailyBlindUsed: _account?.dailyBlindUsed ?? 0,
        dailyDiceUsed: (_account?.dailyDiceUsed ?? 0) + 1,
        dailyGachaUsed: _account?.dailyGachaUsed ?? 0,
      );
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = _extractError(e);
      _isDrawing = false;
      notifyListeners();
      return false;
    }
  }

  /// 扭蛋
  Future<bool> playGacha(int count) async {
    _isDrawing = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.playGacha(count);
      final data = resp.data;

      if (count > 1) {
        // 十连抽 — 返回数组
        final list = (data as List).map((j) => KarmaResult.fromJson(j)).toList();
        _multiResults = list;
        _lastResult = list.where((r) => r.isSSR).isNotEmpty
            ? list.firstWhere((r) => r.isSSR)
            : list.first;
      } else {
        _lastResult = KarmaResult.fromJson(data);
        _multiResults = null;
      }

      _isDrawing = false;
      final cost = count == 10 ? 25 : 3;
      _account = KarmaAccount(
        userId: _account?.userId ?? 0,
        balance: _lastResult!.coinBalance,
        totalEarned: _account?.totalEarned ?? 0,
        totalSpent: (_account?.totalSpent ?? 0) + cost,
        pityCounter: _lastResult!.pityCounter,
        dailyBlindUsed: _account?.dailyBlindUsed ?? 0,
        dailyDiceUsed: _account?.dailyDiceUsed ?? 0,
        dailyGachaUsed: (_account?.dailyGachaUsed ?? 0) + count,
      );
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = _extractError(e);
      _isDrawing = false;
      notifyListeners();
      return false;
    }
  }

  /// 关闭结果弹窗
  void dismissResult() {
    _lastResult = null;
    _multiResults = null;
    notifyListeners();
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['error']?.toString() ?? '请求失败';
    }
    return e.message ?? '网络错误';
  }
}