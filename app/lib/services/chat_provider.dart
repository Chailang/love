import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../config/app_config.dart';
import '../models/chat_models.dart';
import 'api_client.dart';
import 'token_storage.dart';

/// 聊天状态管理：会话列表 + 消息历史 + WebSocket 实时推送
class ChatProvider extends ChangeNotifier {
  // ========== 会话列表 ==========
  List<ConversationItem> _conversations = [];
  List<ConversationItem> get conversations => _conversations;
  int _totalUnread = 0;
  int get totalUnread => _totalUnread;
  bool _conversationsLoading = false;
  bool get conversationsLoading => _conversationsLoading;

  // ========== 当前活跃聊天 ==========
  int? _activeConversationId;
  int? _activePartnerId;
  String _activePartnerName = '';
  String? _activePartnerAvatar;
  String get activePartnerName => _activePartnerName;
  String? get activePartnerAvatar => _activePartnerAvatar;
  final Map<int, List<ChatMessage>> _historyByConv = {};
  String? _chatError;
  String? get chatError => _chatError;

  // ========== WebSocket ==========
  StompClient? _stomp;
  bool _wsConnected = false;
  bool get wsConnected => _wsConnected;

  // ========== 自己 userId ==========
  int? _myUserId;
  int? get myUserId => _myUserId;

  // ==============================
  //  初始化
  // ==============================

  Future<void> init() async {
    final token = await TokenStorage.getToken();
    if (token == null) return;

    final uid = await TokenStorage.getUserId();
    if (uid != null) _myUserId = uid;

    await loadConversations();
    _connectWebSocket();
  }

  // ==============================
  //  会话列表
  // ==============================

  Future<void> loadConversations() async {
    _conversationsLoading = true;
    notifyListeners();

    try {
      final resp = await ApiClient().getConversations();
      final data = ConversationListData.fromJson(resp.data);
      _conversations = data.conversations;
      _totalUnread = data.unreadCount;
    } catch (e) {
      debugPrint('加载会话列表失败: $e');
    } finally {
      _conversationsLoading = false;
      notifyListeners();
    }
  }

  /// 从匹配弹窗跳转到聊天 — 先获取/创建会话，然后打开聊天
  Future<int?> openConversationWith(int matchUserId) async {
    try {
      final resp = await ApiClient().getOrCreateConversation(matchUserId);
      final convId = (resp.data['id'] as num).toInt();
      // 从会话列表里找到这条
      final existing = _conversations.where((c) => c.conversationId == convId);
      if (existing.isNotEmpty) {
        openConversation(convId, matchUserId,
            existing.first.partnerNickname, existing.first.partnerAvatar);
      } else {
        openConversation(convId, matchUserId, '对方', null);
        loadConversations(); // 刷新列表
      }
      return convId;
    } catch (e) {
      debugPrint('打开会话失败: $e');
      return null;
    }
  }

  // ==============================
  //  聊天详情
  // ==============================

  void openConversation(int convId, int partnerId, String name, String? avatar) {
    _activeConversationId = convId;
    _activePartnerId = partnerId;
    _activePartnerName = name;
    _activePartnerAvatar = avatar;
    _chatError = null;
    _historyByConv.putIfAbsent(convId, () => []);
    notifyListeners();
    loadHistory();
    markConversationRead(convId);
  }

  void closeConversation() {
    _activeConversationId = null;
    _activePartnerId = null;
    notifyListeners();
  }

  Future<void> loadHistory({int page = 0}) async {
    final convId = _activeConversationId;
    if (convId == null) return;

    try {
      final resp = await ApiClient().getHistory(convId, page: page, size: 50);
      final list = (resp.data as List).map((e) => ChatMessage.fromJson(e)).toList();
      // 后端按时间正序返回，直接赋值
      _historyByConv[convId] = list;
    } catch (e) {
      _chatError = '加载消息失败';
      debugPrint('加载历史消息失败: $e');
    }
    notifyListeners();
  }

  /// 获取当前聊天页的消息列表
  List<ChatMessage> get activeMessages =>
      _activeConversationId != null
          ? _historyByConv[_activeConversationId] ?? []
          : [];

  // ==============================
  //  发送消息
  // ==============================

  Future<void> sendMessage(String content) async {
    final convId = _activeConversationId;
    final partnerId = _activePartnerId;
    if (convId == null || partnerId == null || content.trim().isEmpty) return;

    // 优先 WebSocket
    if (_wsConnected && _stomp != null) {
      _stomp!.send(
        destination: '/app/chat.send',
        body: '{"conversationId":$convId,"receiverId":$partnerId,"content":"${_escape(content)}"}',
      );
    } else {
      // fallback HTTP
      try {
        await ApiClient().sendMessage(convId, partnerId, content.trim());
        // 重新加载历史
        await loadHistory();
      } catch (e) {
        debugPrint('发送消息失败: $e');
      }
    }
  }

  // ==============================
  //  已读
  // ==============================

  Future<void> markConversationRead(int convId) async {
    try {
      await ApiClient().markAsRead(convId);
      // 本地减掉未读数
      final idx = _conversations.indexWhere((c) => c.conversationId == convId);
      if (idx >= 0) {
        _conversations[idx] = ConversationItem(
          conversationId: convId,
          partnerId: _conversations[idx].partnerId,
          partnerNickname: _conversations[idx].partnerNickname,
          partnerAvatar: _conversations[idx].partnerAvatar,
          lastMessage: _conversations[idx].lastMessage,
          lastMessageAt: _conversations[idx].lastMessageAt,
          unreadCount: 0,
        );
        _totalUnread = _conversations.fold(0, (sum, c) => sum + c.unreadCount);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('标记已读失败: $e');
    }
  }

  // ==============================
  //  WebSocket (STOMP over SockJS)
  // ==============================

  Future<void> _connectWebSocket() async {
    final token = await TokenStorage.getToken();
    if (token == null) return;

    _stomp = StompClient(
      config: StompConfig(
        url: AppConfig.wsUrl,
        onConnect: _onWsConnect,
        onWebSocketError: (e) => debugPrint('WS Error: $e'),
        onStompError: (frame) => debugPrint('STOMP Error: ${frame.body}'),
        onDisconnect: (_) {
          _wsConnected = false;
          notifyListeners();
        },
        stompConnectHeaders: {'token': 'Bearer $token'},
        // heartbeat: 每10秒发ping
        heartbeatOutgoing: Duration(seconds: 10),
        heartbeatIncoming: Duration(seconds: 10),
      ),
    );
    _stomp!.activate();
    notifyListeners();
  }

  void _onWsConnect(StompFrame frame) {
    _wsConnected = true;
    debugPrint('WebSocket 已连接');

    // 订阅个人消息队列 (后端推送到 /user/{userId}/queue/chat)
    _stomp!.subscribe(
      destination: '/user/queue/chat',
      callback: (StompFrame frame) {
        _onWsMessage(frame);
      },
    );

    notifyListeners();
  }

  void _onWsMessage(StompFrame frame) {
    if (frame.body == null) return;

    try {
      // frame.body 格式: MESSAGE\n...\n\n{json}
      // stomp_dart_client 已经在 StompFrame.body 中提供了解析后的 body
      final msg = ChatMessage.fromJson(_parseJson(frame.body!));
      final convId = msg.conversationId;

      // 加到对应会话的历史里
      _historyByConv.putIfAbsent(convId, () => []);
      _historyByConv[convId]!.add(msg);

      // 更新会话列表的 lastMessage
      final idx = _conversations.indexWhere((c) => c.conversationId == convId);
      if (idx >= 0) {
        _conversations[idx] = ConversationItem(
          conversationId: convId,
          partnerId: _conversations[idx].partnerId,
          partnerNickname: _conversations[idx].partnerNickname,
          partnerAvatar: _conversations[idx].partnerAvatar,
          lastMessage: msg.content.length > 30
              ? '${msg.content.substring(0, 30)}...'
              : msg.content,
          lastMessageAt: msg.createdAt,
          unreadCount: _conversations[idx].unreadCount +
              (convId == _activeConversationId ? 0 : 1),
        );
        _totalUnread = _conversations.fold(0, (sum, c) => sum + c.unreadCount);
      } else {
        // 新会话 — 刷新列表
        loadConversations();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('WS 消息解析失败: $e');
    }
  }

  /// 简单的 JSON 解析（从 STOMP body 提取，可能有 MIME 头）
  Map<String, dynamic> _parseJson(String body) {
    // 尝试找到 JSON 部分
    final start = body.indexOf('{');
    final end = body.lastIndexOf('}');
    if (start == -1 || end == -1) throw FormatException('不是 JSON');
    // 简单手写解析（无需 import dart:convert 的复杂依赖）
    return _simpleJsonParse(body.substring(start, end + 1));
  }

  /// 极简 JSON 解析（STOMP 消息体格式固定，用简单方式）
  Map<String, dynamic> _simpleJsonParse(String json) {
    final map = <String, dynamic>{};
    final pairs = json
        .replaceAll(RegExp(r'[{}]'), '')
        .split(',');
    for (final pair in pairs) {
      final colon = pair.indexOf(':');
      if (colon == -1) continue;
      final key = pair.substring(0, colon).trim().replaceAll('"', '');
      final value = pair.substring(colon + 1).trim();
      // 判断类型
      if (value == 'null') {
        map[key] = null;
      } else if (value == 'true') {
        map[key] = true;
      } else if (value == 'false') {
        map[key] = false;
      } else if (value.startsWith('"')) {
        map[key] = value.substring(1, value.length - 1);
      } else if (value.contains('.')) {
        map[key] = double.tryParse(value);
      } else {
        map[key] = int.tryParse(value);
      }
    }
    return map;
  }

  String _escape(String s) => s
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n');

  // ==============================
  //  生命周期
  // ==============================

  @override
  void dispose() {
    _stomp?.deactivate();
    super.dispose();
  }
}