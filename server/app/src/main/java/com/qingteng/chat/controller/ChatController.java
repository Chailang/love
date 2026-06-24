package com.qingteng.chat.controller;

import com.qingteng.chat.dto.ConversationListResponse;
import com.qingteng.chat.dto.SendMessageRequest;
import com.qingteng.chat.entity.Conversation;
import com.qingteng.chat.entity.Message;
import com.qingteng.chat.service.ChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/conversation")
    public ResponseEntity<Conversation> getOrCreate(@AuthenticationPrincipal Long userId,
                                                    @RequestBody Map<String, Long> body) {
        Long matchUserId = body.get("matchUserId");
        return ResponseEntity.ok(chatService.getOrCreateConversation(userId, matchUserId));
    }

    @PostMapping("/send")
    public ResponseEntity<Message> send(@AuthenticationPrincipal Long userId,
                                        @Valid @RequestBody SendMessageRequest request) {
        return ResponseEntity.ok(
            chatService.sendMessage(userId, request.getConversationId(), request.getReceiverId(), request.getContent())
        );
    }

    @GetMapping("/conversations")
    public ResponseEntity<ConversationListResponse> conversations(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(chatService.getConversations(userId));
    }

    @GetMapping("/history/{conversationId}")
    public ResponseEntity<List<Message>> history(@AuthenticationPrincipal Long userId,
                                                  @PathVariable Long conversationId,
                                                  @RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "50") int size) {
        return ResponseEntity.ok(chatService.getHistory(userId, conversationId, page, size));
    }

    @PostMapping("/read/{conversationId}")
    public ResponseEntity<Map<String, String>> markRead(@AuthenticationPrincipal Long userId,
                                                        @PathVariable Long conversationId) {
        chatService.markAsRead(userId, conversationId);
        return ResponseEntity.ok(Map.of("message", "ok"));
    }
}