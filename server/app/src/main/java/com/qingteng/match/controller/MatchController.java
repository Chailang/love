package com.qingteng.match.controller;

import com.qingteng.match.entity.Match;
import com.qingteng.match.dto.MatchListResponse;
import com.qingteng.match.dto.SwipeRequest;
import com.qingteng.match.service.MatchService;
import com.qingteng.user.entity.User;
import com.qingteng.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/match")
@RequiredArgsConstructor
public class MatchController {

    private final MatchService matchService;
    private final UserService userService;

    @GetMapping("/recommend")
    public ResponseEntity<List<User>> recommend(@AuthenticationPrincipal Long userId,
                                                @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(matchService.recommend(userId, limit));
    }

    @PostMapping("/swipe")
    public ResponseEntity<Map<String, Object>> swipe(@AuthenticationPrincipal Long userId,
                                                     @RequestBody SwipeRequest request) {
        return ResponseEntity.ok(matchService.swipe(userId, request.getToUserId(), request.getDirection()));
    }

    @GetMapping("/list")
    public ResponseEntity<MatchListResponse> list(@AuthenticationPrincipal Long userId) {
        List<Match> matches = matchService.getMatches(userId);
        List<MatchListResponse.MatchItem> items = matches.stream().map(m -> {
            Long partnerId = m.getUserId1().equals(userId) ? m.getUserId2() : m.getUserId1();
            User partner = userService.getUser(partnerId);
            return MatchListResponse.MatchItem.builder()
                    .matchId(m.getId())
                    .user(partner)
                    .matchedAt(m.getMatchedAt().toString())
                    .build();
        }).collect(Collectors.toList());

        return ResponseEntity.ok(MatchListResponse.builder()
                .matches(items)
                .total(items.size())
                .build());
    }
}