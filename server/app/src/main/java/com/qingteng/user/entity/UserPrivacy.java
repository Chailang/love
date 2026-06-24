package com.qingteng.user.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_privacy")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserPrivacy {

    @Id
    private Long userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    /** 已读回执：对方知道我已读 */
    @Builder.Default
    private Boolean readReceipt = true;

    /** 位置可见：别人能看到我的距离 */
    @Builder.Default
    private Boolean locationVisible = true;

    /** 在线状态可见 */
    @Builder.Default
    private Boolean onlineVisible = true;

    /** 允许陌生人私聊 */
    @Builder.Default
    private Boolean allowStrangerChat = false;

    /** 上线提醒：上线时通知匹配对象 */
    @Builder.Default
    private Boolean onlineAlert = false;

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