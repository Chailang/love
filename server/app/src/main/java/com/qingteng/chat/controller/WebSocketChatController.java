package com.qingteng.chat.controller;

import com.qingteng.chat.entity.Message;
import com.qingteng.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class WebSocketChatController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.send")
    public void handleSend(@Payload Map<String, Object> payload, Principal principal) {
        Long senderId = Long.parseLong(principal.getName());
        Long conversationId = Long.valueOf(payload.get("conversationId").toString());
        Long receiverId = Long.valueOf(payload.get("receiverId").toString());
        String content = (String) payload.get("content");

        Message saved = chatService.sendMessage(senderId, conversationId, receiverId, content);

        // 发送到对方: /user/{receiverId}/queue/chat
        messagingTemplate.convertAndSendToUser(
                receiverId.toString(), "/queue/chat", saved);

        // 同时发给发送方确认
        messagingTemplate.convertAndSendToUser(
                senderId.toString(), "/queue/chat", saved);
    }
}