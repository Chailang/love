package com.qingteng.geo.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "geo_search_log")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GeoSearchLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    /** 搜索维度：HOMETOWN / WORK / RESIDENCE / ALL */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SearchType searchType;

    /** 搜索条件 JSON */
    @Column(columnDefinition = "TEXT")
    private String conditions;

    /** 结果数量 */
    @Column(name = "result_count")
    private Integer resultCount;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public enum SearchType { HOMETOWN, WORK, RESIDENCE, ALL }
}