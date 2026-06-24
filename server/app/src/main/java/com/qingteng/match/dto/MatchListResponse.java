package com.qingteng.match.dto;

import com.qingteng.user.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class MatchListResponse {
    private List<MatchItem> matches;
    private long total;

    @Data
    @Builder
    @AllArgsConstructor
    public static class MatchItem {
        private Long matchId;
        private User user;
        private String matchedAt;
    }
}