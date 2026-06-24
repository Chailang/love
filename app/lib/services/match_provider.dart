import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/recommend_user.dart';
import '../services/api_client.dart';

/// 匹配推荐状态管理
class MatchProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<RecommendUser> _cards = [];
  bool _isLoading = false;
  String? _error;
  bool _matched = false;        // 双向匹配成功
  RecommendUser? _matchedUser;  // 匹配成功的对方

  List<RecommendUser> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get matched => _matched;
  RecommendUser? get matchedUser => _matchedUser;
  bool get isEmpty => _cards.isEmpty;

  /// 加载推荐列表
  Future<void> loadRecommend() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.dio.get('/match/recommend', queryParameters: {'limit': '20'});
      final List data = resp.data is List ? resp.data : [];
      _cards = data.map((json) => RecommendUser.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 滑动卡片：喜欢 (right) 或 跳过 (left)
  Future<bool> swipe(int toUserId, bool isLike) async {
    try {
      final resp = await _api.dio.post('/match/swipe', data: {
        'toUserId': toUserId,
        'direction': isLike ? 'LIKE' : 'PASS',
      });

      // 检查是否双向匹配
      final data = resp.data as Map<String, dynamic>;
      final matched = data['matched'] == true;
      if (matched) {
        // 找到匹配用户
        _matchedUser = _cards.firstWhere(
          (c) => c.userId == toUserId,
          orElse: () => _cards.first,
        );
        _matched = true;
        notifyListeners();
      }
      return matched;
    } on DioException catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  /// 移除顶部卡片（动画完成后调用）
  void removeTopCard() {
    if (_cards.isNotEmpty) {
      _cards.removeAt(0);
      notifyListeners();
    }
  }

  /// 重置匹配弹窗
  void dismissMatch() {
    _matched = false;
    _matchedUser = null;
    notifyListeners();
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['error']?.toString() ?? '请求失败';
    }
    return e.message ?? '网络错误';
  }
}