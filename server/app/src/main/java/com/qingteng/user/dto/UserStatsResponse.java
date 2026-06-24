package com.qingteng.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStatsResponse {
    private long likedCount;       // 多少人喜欢了我
    private long likedByCount;     // 我喜欢了多少人
    private long matchCount;       // 已匹配数
    private long viewCount;        // 资料被浏览次数
    private long todayRecommend;   // 今日推荐剩余次数
}