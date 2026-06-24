package com.qingteng.match.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "`match`", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id_1", "user_id_2"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Match {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id_1", nullable = false)
    private Long userId1;

    @Column(name = "user_id_2", nullable = false)
    private Long userId2;

    @Column(name = "matched_at", updatable = false)
    private LocalDateTime matchedAt;

    @Column(name = "user1_notified", nullable = false)
    @Builder.Default
    private Boolean user1Notified = false;

    @Column(name = "user2_notified", nullable = false)
    @Builder.Default
    private Boolean user2Notified = false;

    @PrePersist
    protected void onCreate() {
        matchedAt = LocalDateTime.now();
    }
}