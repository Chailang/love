package com.qingteng.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class ConversationListResponse {
    private List<ConversationItem> conversations;
    private long unreadCount;

    @Data
    @Builder
    @AllArgsConstructor
    public static class ConversationItem {
        private Long conversationId;
        private Long partnerId;
        private String partnerNickname;
        private String partnerAvatar;
        private String lastMessage;
        private String lastMessageAt;
        private long unreadCount;
    }
}