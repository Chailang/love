package com.qingteng.karma.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "karma_action_log")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KarmaActionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    /** 玩法类型：BLIND（盲盒）/ DICE（骰子）/ GACHA（扭蛋） */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ActionType actionType;

    /** 消耗的缘分币 */
    @Column(name = "coin_cost")
    private Integer coinCost;

    /** 抽取到的稀有度 */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Rarity rarity;

    /** 匹配到的用户 ID（盲盒/扭蛋时填充） */
    @Column(name = "matched_user_id")
    private Long matchedUserId;

    /** 骰子点数（骰子玩法时填充） */
    @Column(name = "dice_value")
    private Integer diceValue;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public enum ActionType { BLIND, DICE, GACHA }
    public enum Rarity { N, R, SR, SSR }
}