package com.qingteng.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserCenterResponse {

    // ========== 基本资料 ==========
    private Long userId;
    private String nickname;
    private String avatar;
    private String gender;
    private Integer age;
    private String city;
    private String school;
    private String education;
    private String occupation;
    private Integer height;
    private String salaryRange;
    private String bio;

    // ========== 认证与状态 ==========
    private boolean realNameVerified;
    private boolean educationVerified;
    private int profileCompleteness;
    private String status;

    // ========== 缘分数据 ==========
    private long likedCount;        // 多少人喜欢我
    private long likedByCount;      // 我喜欢了多少人
    private long matchCount;        // 已匹配数

    // ========== 隐私设置 ==========
    private boolean readReceipt;
    private boolean locationVisible;
    private boolean onlineVisible;
    private boolean allowStrangerChat;
    private boolean onlineAlert;
}