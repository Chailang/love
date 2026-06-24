/// 聊天模块数据模型

/// 会话列表响应（对应后端 ConversationListResponse）
class ConversationListData {
  final List<ConversationItem> conversations;
  final int unreadCount;

  ConversationListData({required this.conversations, required this.unreadCount});

  factory ConversationListData.fromJson(Map<String, dynamic> json) {
    return ConversationListData(
      conversations: (json['conversations'] as List? ?? [])
          .map((e) => ConversationItem.fromJson(e))
          .toList(),
      unreadCount: (json['unreadCount'] ?? 0).toInt(),
    );
  }
}

/// 单条会话（对应后端 ConversationItem）
class ConversationItem {
  final int conversationId;
  final int partnerId;
  final String partnerNickname;
  final String? partnerAvatar;
  final String? lastMessage;
  final String? lastMessageAt;
  final int unreadCount;

  ConversationItem({
    required this.conversationId,
    required this.partnerId,
    required this.partnerNickname,
    this.partnerAvatar,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      conversationId: (json['conversationId'] ?? 0).toInt(),
      partnerId: (json['partnerId'] ?? 0).toInt(),
      partnerNickname: json['partnerNickname'] ?? '',
      partnerAvatar: json['partnerAvatar'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'],
      unreadCount: (json['unreadCount'] ?? 0).toInt(),
    );
  }
}

/// 单条消息（对应后端 Message entity）
class ChatMessage {
  final int? id;
  final int conversationId;
  final int senderId;
  final int receiverId;
  final String content;
  final String type; // TEXT / IMAGE / MATCH_NOTICE
  final bool isRead;
  final String? createdAt;

  ChatMessage({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = 'TEXT',
    required this.isRead,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toInt(),
      conversationId: (json['conversationId'] ?? 0).toInt(),
      senderId: (json['senderId'] ?? 0).toInt(),
      receiverId: (json['receiverId'] ?? 0).toInt(),
      content: json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}