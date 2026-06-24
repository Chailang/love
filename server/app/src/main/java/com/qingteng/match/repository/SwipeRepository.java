package com.qingteng.match.repository;

import com.qingteng.match.entity.Swipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface SwipeRepository extends JpaRepository<Swipe, Long> {
    Optional<Swipe> findByFromUserIdAndToUserId(Long from, Long to);
    boolean existsByFromUserIdAndToUserId(Long from, Long to);

    @Query("SELECT s.toUserId FROM Swipe s WHERE s.fromUserId = :userId AND s.direction = 'LIKE'")
    List<Long> findLikedUserIds(Long userId);

    @Query("SELECT s.toUserId FROM Swipe s WHERE s.fromUserId = :userId AND s.direction = 'PASS'")
    List<Long> findPassedUserIds(Long userId);

    @Query("SELECT COUNT(s) FROM Swipe s WHERE s.fromUserId = :userId AND s.direction = :direction")
    long countByFromUserIdAndDirection(Long userId, Swipe.Direction direction);

    @Query("SELECT COUNT(s) FROM Swipe s WHERE s.toUserId = :userId AND s.direction = :direction")
    long countByToUserIdAndDirection(Long userId, Swipe.Direction direction);
}