package com.qingteng.bazi.repository;

import com.qingteng.bazi.entity.BaziMatchResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface BaziMatchResultRepository extends JpaRepository<BaziMatchResult, Long> {

    @Query("SELECT b FROM BaziMatchResult b WHERE b.userId1 = :uid1 AND b.userId2 = :uid2")
    Optional<BaziMatchResult> findByUserPair(Long uid1, Long uid2);
}