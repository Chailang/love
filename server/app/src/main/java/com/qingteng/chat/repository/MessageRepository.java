package com.qingteng.chat.repository;

import com.qingteng.chat.entity.Message;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query("SELECT m FROM Message m WHERE m.conversationId = :convId ORDER BY m.createdAt DESC")
    List<Message> findRecentMessages(Long convId, Pageable pageable);

    @Query("SELECT m FROM Message m WHERE m.conversationId = :convId AND m.id > :afterId ORDER BY m.createdAt ASC")
    List<Message> findMessagesAfter(Long convId, Long afterId);

    @Modifying
    @Transactional
    @Query("UPDATE Message m SET m.isRead = true WHERE m.conversationId = :convId AND m.receiverId = :userId AND m.isRead = false")
    void markAsRead(Long convId, Long userId);

    @Query("SELECT COUNT(m) FROM Message m WHERE m.receiverId = :userId AND m.isRead = false")
    long countUnread(Long userId);
}