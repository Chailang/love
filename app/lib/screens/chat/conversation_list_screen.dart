import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/chat_provider.dart';
import '../../models/chat_models.dart';
import 'chat_screen.dart';

/// 消息 Tab — 会话列表页
///
/// 结构：
///   AppBar（标题 + 未读角标）
///   列表（头像 + 昵称 + 最后一条消息 + 时间 + 未读红点 + 分隔线）
///   空状态（暂无消息）
class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    // 每次进入 Tab 刷新
    Future.microtask(() => context.read<ChatProvider>().loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        final convs = chat.conversations;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text('消息', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                if (chat.totalUnread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Text(
                      '${chat.totalUnread}',
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          body: chat.conversationsLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : convs.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: () => chat.loadConversations(),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: convs.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, index) =>
                            _buildConversationTile(convs[index], chat),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80,
                color: AppTheme.primary.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            const Text('暂无消息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            const Text('去「寻觅」Tab 匹配更多好友吧~', style: TextStyle(fontSize: 14, color: AppTheme.textHint)),
          ],
        ),
      );

  Widget _buildConversationTile(ConversationItem item, ChatProvider chat) {
    final avatar = item.partnerAvatar;
    final initial = item.partnerNickname.isNotEmpty
        ? item.partnerNickname[0]
        : '?';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          chat.openConversation(
            item.conversationId,
            item.partnerId,
            item.partnerNickname,
            item.partnerAvatar,
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 头像
              _buildAvatar(avatar, initial, item.unreadCount > 0),
              const SizedBox(width: 12),
              // 中间信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.partnerNickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: item.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (item.lastMessageAt != null)
                          Text(
                            _formatTime(item.lastMessageAt!),
                            style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.lastMessage ?? '开始聊天吧~',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: item.unreadCount > 0
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        if (item.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${item.unreadCount > 99 ? '99+' : item.unreadCount}',
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? url, String initial, bool hasUnread) {
    const size = 52.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withValues(alpha: 0.1),
        border: hasUnread
            ? Border.all(color: AppTheme.primary, width: 2)
            : null,
      ),
      child: url != null && url.isNotEmpty
          ? ClipOval(
              child: Image.network(url, width: size, height: size, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsWidget(initial),
              ),
            )
          : _initialsWidget(initial),
    );
  }

  Widget _initialsWidget(String initial) => Center(
        child: Text(initial,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                color: AppTheme.primary)),
      );

  /// 格式化时间戳为相对时间
  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return '刚刚';
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      if (diff.inDays < 7) return '${diff.inDays}天前';

      // 超过7天显示日期
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }
}