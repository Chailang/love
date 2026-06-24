package com.qingteng.bazi.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "bazi_match_result")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BaziMatchResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id_1", nullable = false)
    private Long userId1;

    @Column(name = "user_id_2", nullable = false)
    private Long userId2;

    @Column(nullable = false)
    private Integer score;  // 0-100

    @Column(name = "year_score")
    private Integer yearScore;

    @Column(name = "month_score")
    private Integer monthScore;

    @Column(name = "day_score")
    private Integer dayScore;

    @Column(name = "hour_score")
    private Integer hourScore;

    @Column(name = "element_bonus")
    private Integer elementBonus;

    @Column(length = 500)
    private String summary;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}