package com.qingteng.karma.controller;

import com.qingteng.karma.dto.KarmaAccountResponse;
import com.qingteng.karma.dto.KarmaResultResponse;
import com.qingteng.karma.service.KarmaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/karma")
@RequiredArgsConstructor
public class KarmaController {

    private final KarmaService karmaService;

    /** 查看缘分币账户 */
    @GetMapping("/account")
    public ResponseEntity<KarmaAccountResponse> account(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(karmaService.getAccount(userId));
    }

    /** 盲盒抽一次 */
    @PostMapping("/blind")
    public ResponseEntity<KarmaResultResponse> blind(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(karmaService.playBlind(userId));
    }

    /** 骰子摇一次 */
    @PostMapping("/dice")
    public ResponseEntity<KarmaResultResponse> dice(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(karmaService.playDice(userId));
    }

    /** 扭蛋抽奖（单抽 1 或十连 10） */
    @PostMapping("/gacha")
    public ResponseEntity<KarmaResultResponse> gacha(@AuthenticationPrincipal Long userId,
                                                     @RequestBody Map<String, Integer> body) {
        int count = body.getOrDefault("count", 1);
        return ResponseEntity.ok(karmaService.playGacha(userId, count));
    }
}