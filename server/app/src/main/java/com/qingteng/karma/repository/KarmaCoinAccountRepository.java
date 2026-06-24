package com.qingteng.karma.repository;

import com.qingteng.karma.entity.KarmaCoinAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

public interface KarmaCoinAccountRepository extends JpaRepository<KarmaCoinAccount, Long> {

    @Modifying
    @Query("UPDATE KarmaCoinAccount a SET a.dailyBlindUsed = 0, a.dailyDiceUsed = 0, a.dailyGachaUsed = 0, a.lastResetDate = CURRENT_DATE WHERE a.userId = :userId")
    void resetDaily(Long userId);
}