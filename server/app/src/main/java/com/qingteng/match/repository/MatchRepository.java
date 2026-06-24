package com.qingteng.match.repository;

import com.qingteng.match.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface MatchRepository extends JpaRepository<Match, Long> {

    @Query("SELECT m FROM Match m WHERE (m.userId1 = :uid1 AND m.userId2 = :uid2) OR (m.userId1 = :uid2 AND m.userId2 = :uid1)")
    Optional<Match> findMatch(Long uid1, Long uid2);

    @Query("SELECT m FROM Match m WHERE m.userId1 = :userId OR m.userId2 = :userId ORDER BY m.matchedAt DESC")
    List<Match> findByUserId(Long userId);

    @Query("SELECT COUNT(m) FROM Match m WHERE m.userId1 = :userId OR m.userId2 = :userId")
    long countByUserId(Long userId);
}