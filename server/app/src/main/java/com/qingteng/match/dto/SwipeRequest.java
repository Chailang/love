package com.qingteng.match.dto;

import lombok.Data;

@Data
public class SwipeRequest {
    private Long toUserId;
    private String direction;  // LIKE / PASS
}