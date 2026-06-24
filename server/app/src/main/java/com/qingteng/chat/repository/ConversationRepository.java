package com.qingteng.chat.repository;

import com.qingteng.chat.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    @Query("SELECT c FROM Conversation c WHERE (c.userId1 = :uid1 AND c.userId2 = :uid2) OR (c.userId1 = :uid2 AND c.userId2 = :uid1)")
    Optional<Conversation> findByUserPair(Long uid1, Long uid2);

    @Query("SELECT c FROM Conversation c WHERE c.userId1 = :userId OR c.userId2 = :userId ORDER BY c.lastMessageAt DESC NULLS LAST")
    List<Conversation> findByUserId(Long userId);
}