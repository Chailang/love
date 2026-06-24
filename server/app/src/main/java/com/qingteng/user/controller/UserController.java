package com.qingteng.user.controller;

import com.qingteng.common.service.FileService;
import com.qingteng.user.dto.*;
import com.qingteng.user.entity.User;
import com.qingteng.user.entity.UserPrivacy;
import com.qingteng.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final FileService fileService;

    // ============ 认证相关 ============

    @PostMapping("/send-code")
    public ResponseEntity<Map<String, String>> sendCode(@Valid @RequestBody SendCodeRequest request) {
        userService.sendCode(request);
        return ResponseEntity.ok(Map.of("message", "验证码已发送"));
    }

    @PostMapping("/register")
    public ResponseEntity<LoginResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(userService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(userService.login(request));
    }

    @PostMapping("/verify")
    public ResponseEntity<User> verify(@Valid @RequestBody VerifyRequest request,
                                       @AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(userService.verifyProfile(userId, request));
    }

    // ============ 个人中心 ============

    /** 个人中心聚合数据（我的 Tab 首页数据） */
    @GetMapping("/me/center")
    public ResponseEntity<UserCenterResponse> center(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(userService.getUserCenter(userId));
    }

    /** 查看自己基本资料 */
    @GetMapping("/me")
    public ResponseEntity<User> me(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(userService.getUser(userId));
    }

    /** 编辑资料 */
    @PutMapping("/me/profile")
    public ResponseEntity<User> updateProfile(@RequestBody ProfileRequest request,
                                              @AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(userService.updateProfile(userId, request));
    }

    /** 上传头像 */
    @PostMapping("/me/avatar")
    public ResponseEntity<UploadResponse> uploadAvatar(@RequestParam("file") MultipartFile file,
                                                       @AuthenticationPrincipal Long userId) {
        String url = fileService.upload(file);
        ProfileRequest avatarReq = new ProfileRequest();
        avatarReq.setAvatar(url);
        userService.updateProfile(userId, avatarReq);
        return ResponseEntity.ok(new UploadResponse(url));
    }

    /** 互动数据统计 */
    @GetMapping("/me/stats")
    public ResponseEntity<UserStatsResponse> stats(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(userService.getStats(userId));
    }

    // ============ 隐私设置 ============

    /** 查看隐私设置 */
    @GetMapping("/me/privacy")
    public ResponseEntity<Map<String, Object>> getPrivacy(@AuthenticationPrincipal Long userId) {
        UserPrivacy p = userService.getPrivacy(userId);
        return ResponseEntity.ok(Map.of(
                "readReceipt", p.getReadReceipt(),
                "locationVisible", p.getLocationVisible(),
                "onlineVisible", p.getOnlineVisible(),
                "allowStrangerChat", p.getAllowStrangerChat(),
                "onlineAlert", p.getOnlineAlert()
        ));
    }

    /** 更新隐私设置 */
    @PutMapping("/me/privacy")
    public ResponseEntity<Map<String, Object>> updatePrivacy(@RequestBody PrivacyRequest request,
                                                             @AuthenticationPrincipal Long userId) {
        UserPrivacy p = userService.updatePrivacy(userId, request);
        return ResponseEntity.ok(Map.of(
                "readReceipt", p.getReadReceipt(),
                "locationVisible", p.getLocationVisible(),
                "onlineVisible", p.getOnlineVisible(),
                "allowStrangerChat", p.getAllowStrangerChat(),
                "onlineAlert", p.getOnlineAlert()
        ));
    }
}