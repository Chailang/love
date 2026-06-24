package com.qingteng.bazi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class BaziMatchResponse {
    private Long userId1;
    private Long userId2;
    private int score;
    private int yearScore;
    private int monthScore;
    private int dayScore;
    private int hourScore;
    private int elementBonus;
    private String summary;

    // 双方八字
    private String bazi1;
    private String bazi2;
}