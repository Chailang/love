package com.qingteng.bazi.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_bazi")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserBazi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    @Column(name = "birth_year", nullable = false)
    private Integer birthYear;

    @Column(name = "birth_month", nullable = false)
    private Integer birthMonth;

    @Column(name = "birth_day", nullable = false)
    private Integer birthDay;

    @Column(nullable = false)
    private Integer hour;  // 0-23

    // 年柱
    @Column(name = "year_stem", length = 4)
    private String yearStem;

    @Column(name = "year_branch", length = 4)
    private String yearBranch;

    // 月柱
    @Column(name = "month_stem", length = 4)
    private String monthStem;

    @Column(name = "month_branch", length = 4)
    private String monthBranch;

    // 日柱
    @Column(name = "day_stem", length = 4)
    private String dayStem;

    @Column(name = "day_branch", length = 4)
    private String dayBranch;

    // 时柱
    @Column(name = "hour_stem", length = 4)
    private String hourStem;

    @Column(name = "hour_branch", length = 4)
    private String hourBranch;

    // 五行统计
    @Column(name = "wood_count", nullable = false)
    @Builder.Default
    private Integer woodCount = 0;

    @Column(name = "fire_count", nullable = false)
    @Builder.Default
    private Integer fireCount = 0;

    @Column(name = "earth_count", nullable = false)
    @Builder.Default
    private Integer earthCount = 0;

    @Column(name = "metal_count", nullable = false)
    @Builder.Default
    private Integer metalCount = 0;

    @Column(name = "water_count", nullable = false)
    @Builder.Default
    private Integer waterCount = 0;

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