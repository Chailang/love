package com.qingteng.karma.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KarmaResultResponse {
    private String actionType;        // BLIND / DICE / GACHA
    private String rarity;            // N / R / SR / SSR
    private Long matchedUserId;       // 盲盒/扭蛋匹配到的用户（可选）
    private String matchedNickname;   // 匹配用户昵称
    private String matchedAvatar;     // 匹配用户头像
    private Integer diceValue;        // 骰子点数（骰子玩法时填充）
    private Integer coinBalance;      // 剩余缘分币
    private Integer pityCounter;      // 当前保底计数
    private Boolean isSSR;            // 是否 SSR
    private String description;       // 结果描述文案
}