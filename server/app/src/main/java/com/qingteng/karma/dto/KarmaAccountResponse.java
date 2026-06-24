package com.qingteng.karma.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KarmaAccountResponse {
    private Long userId;
    private Integer balance;          // 当前余额
    private Integer totalEarned;      // 累计获取
    private Integer totalSpent;       // 累计消费
    private Integer pityCounter;      // 扭蛋保底计数
    private Integer dailyBlindUsed;   // 今日盲盒次数
    private Integer dailyDiceUsed;    // 今日骰子次数
    private Integer dailyGachaUsed;   // 今日扭蛋次数
    private boolean ssrBoostActive;   // SSR 暴击周是否激活（每月第三周）
}