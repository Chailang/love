import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'token_storage.dart';

/// API 客户端 — 自动附加 JWT Token
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    // 请求拦截器：自动附加 Token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.response?.statusCode} ${error.message}');
        handler.next(error);
      },
    ));
  }

  // ========== 用户认证 ==========

  Future<Response> sendCode(String phone, String type) =>
      dio.post('/user/send-code', data: {'phone': phone, 'type': type});

  Future<Response> register(String phone, String password, String code) =>
      dio.post('/user/register', data: {'phone': phone, 'password': password, 'code': code});

  Future<Response> login(String phone, String code) =>
      dio.post('/user/login', data: {'phone': phone, 'code': code});

  // ========== 个人中心 ==========

  Future<Response> getUserCenter() => dio.get('/user/me/center');

  Future<Response> updateProfile(Map<String, dynamic> data) =>
      dio.put('/user/me/profile', data: data);

  Future<Response> getPrivacy() => dio.get('/user/me/privacy');

  Future<Response> updatePrivacy(Map<String, dynamic> data) =>
      dio.put('/user/me/privacy', data: data);

  // ========== 缘分盲盒 ==========

  Future<Response> getKarmaAccount() => dio.get('/karma/account');

  Future<Response> playBlind() => dio.post('/karma/blind');

  Future<Response> playDice() => dio.post('/karma/dice');

  Future<Response> playGacha(int count) =>
      dio.post('/karma/gacha', data: {'count': count});

  // ========== 同乡近邻 ==========

  Future<Response> getMyGeo() => dio.get('/geo/me');

  Future<Response> updateMyGeo(Map<String, dynamic> data) =>
      dio.put('/geo/me', data: data);

  Future<Response> searchHometown() => dio.get('/geo/hometown');

  Future<Response> searchWork() => dio.get('/geo/work');

  Future<Response> searchResidence() => dio.get('/geo/residence');

  Future<Response> searchAllGeo() => dio.get('/geo/all');

  // ========== 聊天 ==========

  Future<Response> getConversations() => dio.get('/chat/conversations');

  Future<Response> getOrCreateConversation(int matchUserId) =>
      dio.post('/chat/conversation', data: {'matchUserId': matchUserId});

  Future<Response> sendMessage(int conversationId, int receiverId, String content) =>
      dio.post('/chat/send', data: {
        'conversationId': conversationId,
        'receiverId': receiverId,
        'content': content,
      });

  Future<Response> getHistory(int conversationId, {int page = 0, int size = 50}) =>
      dio.get('/chat/history/$conversationId', queryParameters: {'page': page, 'size': size});

  Future<Response> markAsRead(int conversationId) =>
      dio.post('/chat/read/$conversationId');

  // ========== 八字合缘 ==========

  Future<Response> getMyBazi() => dio.get('/bazi/my');

  Future<Response> saveBazi(Map<String, dynamic> data) =>
      dio.post('/bazi/my', data: data);

  Future<Response> matchBazi(int targetUserId) =>
      dio.get('/bazi/match/$targetUserId');
}