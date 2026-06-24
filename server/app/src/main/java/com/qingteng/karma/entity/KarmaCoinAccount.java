package com.qingteng.karma.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "karma_coin_account")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KarmaCoinAccount {

    @Id
    @Column(name = "user_id")
    private Long userId;

    /** 缘分币余额 */
    @Builder.Default
    private Integer balance = 0;

    /** 累计获取的缘分币 */
    @Builder.Default
    private Integer totalEarned = 0;

    /** 累计消费的缘分币 */
    @Builder.Default
    private Integer totalSpent = 0;

    /** 扭蛋保底计数器：累计抽数，满 30 保底 SSR */
    @Builder.Default
    @Column(name = "pity_counter")
    private Integer pityCounter = 0;

    /** 每日盲盒已用次数 */
    @Builder.Default
    @Column(name = "daily_blind_used")
    private Integer dailyBlindUsed = 0;

    /** 每日骰子已用次数 */
    @Builder.Default
    @Column(name = "daily_dice_used")
    private Integer dailyDiceUsed = 0;

    /** 每日扭蛋已用次数 */
    @Builder.Default
    @Column(name = "daily_gacha_used")
    private Integer dailyGachaUsed = 0;

    /** 最后重置日期（用于日限判断） */
    @Column(name = "last_reset_date")
    private LocalDate lastResetDate;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}