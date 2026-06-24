package com.qingteng.karma.repository;

import com.qingteng.karma.entity.KarmaActionLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDateTime;
import java.util.Optional;

public interface KarmaActionLogRepository extends JpaRepository<KarmaActionLog, Long> {

    /** 统计用户今日某种玩法的使用次数 */
    @Query("SELECT COUNT(l) FROM KarmaActionLog l WHERE l.userId = :userId AND l.actionType = :type AND l.createdAt >= :since")
    long countTodayByType(Long userId, KarmaActionLog.ActionType type, LocalDateTime since);

    /** 最后一次 SSR 之后的抽数（用于保底计算） */
    @Query("SELECT COUNT(l) FROM KarmaActionLog l WHERE l.userId = :userId AND l.actionType = 'GACHA' AND l.createdAt > COALESCE((SELECT MAX(l2.createdAt) FROM KarmaActionLog l2 WHERE l2.userId = :userId AND l2.actionType = 'GACHA' AND l2.rarity = 'SSR'), '1970-01-01')")
    long countSinceLastSSR(Long userId);
}