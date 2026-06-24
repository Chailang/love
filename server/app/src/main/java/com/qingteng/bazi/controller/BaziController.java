package com.qingteng.bazi.controller;

import com.qingteng.bazi.dto.BaziInputRequest;
import com.qingteng.bazi.dto.BaziMatchResponse;
import com.qingteng.bazi.entity.UserBazi;
import com.qingteng.bazi.service.BaziService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/bazi")
@RequiredArgsConstructor
public class BaziController {

    private final BaziService baziService;

    @PostMapping("/my")
    public ResponseEntity<UserBazi> saveMyBazi(@AuthenticationPrincipal Long userId,
                                                @Valid @RequestBody BaziInputRequest request) {
        return ResponseEntity.ok(baziService.saveBazi(userId, request));
    }

    @GetMapping("/my")
    public ResponseEntity<UserBazi> getMyBazi(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(baziService.getBazi(userId));
    }

    @GetMapping("/match/{targetUserId}")
    public ResponseEntity<BaziMatchResponse> matchBazi(@AuthenticationPrincipal Long userId,
                                                        @PathVariable Long targetUserId) {
        return ResponseEntity.ok(baziService.calculateMatch(userId, targetUserId));
    }
}