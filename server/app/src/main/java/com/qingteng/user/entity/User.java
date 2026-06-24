package com.qingteng.user.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "`user`")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 20)
    private String phone;

    @Column(nullable = false)
    private String password;

    @Column(length = 50)
    private String nickname;

    @Column(length = 500)
    private String avatar;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Gender gender;

    @Column(name = "birth_date")
    private LocalDateTime birthDate;

    @Column(length = 50)
    private String education;

    @Column(name = "education_verified", nullable = false)
    @Builder.Default
    private Boolean educationVerified = false;

    @Column(name = "real_name")
    private String realName;

    @Column(name = "id_card")
    private String idCard;

    @Column(name = "real_name_verified", nullable = false)
    @Builder.Default
    private Boolean realNameVerified = false;

    @Column(length = 100)
    private String school;

    @Column(length = 50)
    private String occupation;

    @Column(length = 30)
    private String city;

    @Column
    private Integer height;

    @Column(length = 20)
    private String constellation;

    @Column(name = "salary_range", length = 30)
    private String salaryRange;

    @Column(name = "profile_completeness", columnDefinition = "TINYINT DEFAULT 0")
    @Builder.Default
    private Integer profileCompleteness = 0;

    @Column(length = 300)
    private String bio;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private UserStatus status = UserStatus.INCOMPLETE;

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

    public enum Gender { MALE, FEMALE }
    public enum UserStatus { INCOMPLETE, PENDING_VERIFY, ACTIVE, DISABLED }
}