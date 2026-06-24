package com.qingteng.chat.service;

import com.qingteng.chat.dto.ConversationListResponse;
import com.qingteng.chat.entity.Conversation;
import com.qingteng.chat.entity.Message;
import com.qingteng.chat.repository.ConversationRepository;
import com.qingteng.chat.repository.MessageRepository;
import com.qingteng.match.repository.MatchRepository;
import com.qingteng.user.entity.User;
import com.qingteng.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final MessageRepository messageRepository;
    private final ConversationRepository conversationRepository;
    private final MatchRepository matchRepository;
    private final UserRepository userRepository;

    @Transactional
    public Message sendMessage(Long senderId, Long conversationId, Long receiverId, String content) {
        Conversation conv = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("会话不存在"));

        // 验证 sender 是会话的参与方
        if (!conv.getUserId1().equals(senderId) && !conv.getUserId2().equals(senderId)) {
            throw new RuntimeException("无权在该会话中发消息");
        }

        Message msg = Message.builder()
                .conversationId(conversationId)
                .senderId(senderId)
                .receiverId(receiverId)
                .content(content)
                .build();
        msg = messageRepository.save(msg);

        // 更新会话最后消息
        conv.setLastMessage(content.length() > 50 ? content.substring(0, 50) + "..." : content);
        conv.setLastMessageAt(msg.getCreatedAt());
        conversationRepository.save(conv);

        return msg;
    }

    @Transactional
    public Conversation getOrCreateConversation(Long userId, Long matchUserId) {
        // 检验是否已匹配
        boolean matched = matchRepository.findMatch(userId, matchUserId).isPresent();
        if (!matched) throw new RuntimeException("尚未匹配，无法聊天");

        long uid1 = Math.min(userId, matchUserId);
        long uid2 = Math.max(userId, matchUserId);

        Optional<Conversation> existing = conversationRepository.findByUserPair(uid1, uid2);
        if (existing.isPresent()) return existing.get();

        return conversationRepository.save(Conversation.builder()
                .userId1(uid1).userId2(uid2).build());
    }

    public ConversationListResponse getConversations(Long userId) {
        List<Conversation> convs = conversationRepository.findByUserId(userId);

        List<ConversationListResponse.ConversationItem> items = convs.stream().map(c -> {
            Long partnerId = c.getUserId1().equals(userId) ? c.getUserId2() : c.getUserId1();
            User partner = userRepository.findById(partnerId).orElse(null);

            long unread = messageRepository.findRecentMessages(c.getId(), PageRequest.of(0, 100))
                    .stream().filter(m -> m.getReceiverId().equals(userId) && !m.getIsRead()).count();

            return ConversationListResponse.ConversationItem.builder()
                    .conversationId(c.getId())
                    .partnerId(partnerId)
                    .partnerNickname(partner != null ? partner.getNickname() : "用户" + partnerId)
                    .partnerAvatar(partner != null ? partner.getAvatar() : null)
                    .lastMessage(c.getLastMessage())
                    .lastMessageAt(c.getLastMessageAt() != null ? c.getLastMessageAt().toString() : null)
                    .unreadCount(unread)
                    .build();
        }).collect(Collectors.toList());

        long totalUnread = messageRepository.countUnread(userId);

        return ConversationListResponse.builder()
                .conversations(items)
                .unreadCount(totalUnread)
                .build();
    }

    public List<Message> getHistory(Long userId, Long conversationId, int page, int size) {
        Conversation conv = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("会话不存在"));

        if (!conv.getUserId1().equals(userId) && !conv.getUserId2().equals(userId)) {
            throw new RuntimeException("无权查看该会话");
        }

        return messageRepository.findRecentMessages(conversationId, PageRequest.of(page, size));
    }

    @Transactional
    public void markAsRead(Long userId, Long conversationId) {
        messageRepository.markAsRead(conversationId, userId);
    }
}