import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/chat_provider.dart';
import '../../models/chat_models.dart';

/// 聊天详情页 — 单聊消息流 + 发送栏
///
/// 布局：
///   AppBar（对方昵称 + 头像 + 返回箭头）  
///   消息列表（自己右对齐 + 粉底，对方左对齐 + 灰底，时间气泡居中）  
///   底部输入栏（输入框 + 发送按钮）
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _inputCtl.dispose();
    _scrollCtl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {
            chat.closeConversation();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            // 对方头像
            _buildTitleAvatar(chat),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                chat.activePartnerName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _buildMessageList(chat),
          ),
          // 底部输入栏
          _buildInputBar(chat),
        ],
      ),
    );
  }

  Widget _buildTitleAvatar(ChatProvider chat) {
    final avatar = chat.activePartnerAvatar;
    const size = 38.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withValues(alpha: 0.1),
      ),
      child: avatar != null && avatar.isNotEmpty
          ? ClipOval(
              child: Image.network(avatar, width: size, height: size, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsWidget(chat.activePartnerName),
              ),
            )
          : _initialsWidget(chat.activePartnerName),
    );
  }

  Widget _initialsWidget(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
        ),
      );

  // ========== 消息列表 ==========

  Widget _buildMessageList(ChatProvider chat) {
    final messages = chat.activeMessages;
    final myId = chat.myUserId;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64,
                color: AppTheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            const Text('开始聊天吧~', style: TextStyle(fontSize: 16, color: AppTheme.textHint)),
          ],
        ),
      );
    }

    // 自动滚到底部（新消息到达时）
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    return ListView.builder(
      controller: _scrollCtl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = myId != null && msg.senderId == myId;

        // 特殊消息类型
        if (msg.type == 'MATCH_NOTICE') {
          return _buildSystemMsg(msg.content);
        }

        return _buildBubble(msg, isMe);
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollCtl.hasClients) {
      _scrollCtl.animateTo(
        _scrollCtl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // 系统消息（匹配通知等）
  Widget _buildSystemMsg(String content) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: 14, color: AppTheme.primary.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(content,
                    style: TextStyle(fontSize: 12, color: AppTheme.primary.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ),
      );

  // 消息气泡
  Widget _buildBubble(ChatMessage msg, bool isMe) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 对方头像
            if (!isMe) ...[
              _bubbleAvatar(msg),
              const SizedBox(width: 8),
            ],

            // 气泡内容
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primary : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 自己头像
            if (isMe) ...[
              const SizedBox(width: 8),
              _bubbleAvatar(msg),
            ],
          ],
        ),
      );

  Widget _bubbleAvatar(ChatMessage msg) {
    final chat = context.read<ChatProvider>();
    final isMe = msg.senderId == chat.myUserId;
    // 对方用对方头像，自己暂时用默认（后续可扩展）
    final avatar = isMe ? null : chat.activePartnerAvatar;

    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF0F0F0),
      ),
      child: avatar != null && avatar.isNotEmpty
          ? ClipOval(child: Image.network(avatar, fit: BoxFit.cover))
          : Icon(Icons.person, size: 20, color: AppTheme.primary.withValues(alpha: 0.4)),
    );
  }

  // ========== 底部输入栏 ==========

  Widget _buildInputBar(ChatProvider chat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _inputCtl,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: '说点什么...',
                  hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 16),
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 发送按钮
          GestureDetector(
            onTap: () {
              final text = _inputCtl.text.trim();
              if (text.isEmpty) return;
              chat.sendMessage(text);
              _inputCtl.clear();
              _focusNode.requestFocus();
              // 滚动到底部
              Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
            },
            child: Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}