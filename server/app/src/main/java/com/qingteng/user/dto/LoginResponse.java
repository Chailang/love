package com.qingteng.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {
    private String token;
    private Long userId;
    private String phone;
    private String nickname;
    private String avatar;
    private Boolean educationVerified;
    private Boolean realNameVerified;
    private String status;
    private Integer profileCompleteness;
}