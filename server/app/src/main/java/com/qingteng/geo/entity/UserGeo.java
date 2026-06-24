package com.qingteng.geo.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_geo")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserGeo {

    @Id
    @Column(name = "user_id")
    private Long userId;

    // ======== 家乡（三维定位第一维）========

    /** 家乡省份 */
    @Column(name = "hometown_province", length = 30)
    private String hometownProvince;

    /** 家乡城市 */
    @Column(name = "hometown_city", length = 30)
    private String hometownCity;

    /** 家乡区县 */
    @Column(name = "hometown_district", length = 30)
    private String hometownDistrict;

    // ======== 工作区域（第二维）========

    /** 工作省份 */
    @Column(name = "work_province", length = 30)
    private String workProvince;

    /** 工作城市 */
    @Column(name = "work_city", length = 30)
    private String workCity;

    /** 工作区县 */
    @Column(name = "work_district", length = 30)
    private String workDistrict;

    // ======== 居住位置（第三维）========

    /** 居住纬度 */
    @Column(precision = 10, scale = 7)
    private BigDecimal residenceLat;

    /** 居住经度 */
    @Column(precision = 10, scale = 7)
    private BigDecimal residenceLng;

    // ======== 隐私开关 ========

    /** 家乡是否可见 */
    @Builder.Default
    @Column(name = "hometown_visible")
    private Boolean hometownVisible = true;

    /** 工作区域是否可见 */
    @Builder.Default
    @Column(name = "work_visible")
    private Boolean workVisible = true;

    /** 居住地是否可见 */
    @Builder.Default
    @Column(name = "residence_visible")
    private Boolean residenceVisible = false;

    /** 精确距离是否可见（VIP 权益） */
    @Builder.Default
    @Column(name = "exact_distance_visible")
    private Boolean exactDistanceVisible = false;

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

    // ======== 距离展示层级 ========
    public enum DistanceLevel {
        /** 同省（≤ 本省） */
        SAME_PROVINCE("老乡", 10),
        /** 同城（≤ 50km） */
        SAME_CITY("同城", 5),
        /** 同区（≤ 5km） */
        SAME_DISTRICT("近邻", 1),
        /** 其他 */
        OTHER("远方", 0);

        private final String label;
        private final int weight;

        DistanceLevel(String label, int weight) {
            this.label = label;
            this.weight = weight;
        }

        public String getLabel() { return label; }
        public int getWeight() { return weight; }
    }
}