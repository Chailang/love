package com.qingteng.user.service;

import com.qingteng.common.security.JwtUtil;
import com.qingteng.match.repository.MatchRepository;
import com.qingteng.match.repository.SwipeRepository;
import com.qingteng.user.dto.*;
import com.qingteng.user.entity.User;
import com.qingteng.user.entity.UserPrivacy;
import com.qingteng.user.entity.VerificationCode;
import com.qingteng.user.repository.UserPrivacyRepository;
import com.qingteng.user.repository.UserRepository;
import com.qingteng.user.repository.VerificationCodeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Period;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final VerificationCodeRepository codeRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final SwipeRepository swipeRepository;
    private final MatchRepository matchRepository;
    private final UserPrivacyRepository privacyRepository;

    public User getUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
    }

    @Transactional
    public User updateProfile(Long userId, ProfileRequest request) {
        User user = getUser(userId);

        if (request.getNickname() != null) user.setNickname(request.getNickname());
        if (request.getAvatar() != null) user.setAvatar(request.getAvatar());
        if (request.getGender() != null) user.setGender(User.Gender.valueOf(request.getGender()));
        if (request.getBirthDate() != null) {
            user.setBirthDate(java.time.LocalDateTime.parse(request.getBirthDate() + "T00:00:00"));
        }
        if (request.getCity() != null) user.setCity(request.getCity());
        if (request.getOccupation() != null) user.setOccupation(request.getOccupation());
        if (request.getHeight() != null) user.setHeight(request.getHeight());
        if (request.getSalaryRange() != null) user.setSalaryRange(request.getSalaryRange());
        if (request.getBio() != null) user.setBio(request.getBio());

        recalcCompleteness(user);
        return userRepository.save(user);
    }

    private void recalcCompleteness(User user) {
        int score = 20; // 手机号注册基础分
        if (user.getNickname() != null && !user.getNickname().isBlank()) score += 10;
        if (user.getAvatar() != null && !user.getAvatar().isBlank()) score += 10;
        if (user.getGender() != null) score += 10;
        if (user.getBirthDate() != null) score += 10;
        if (user.getSchool() != null && !user.getSchool().isBlank()) score += 10;
        if (user.getRealName() != null && !user.getRealName().isBlank()) score += 10;
        if (user.getOccupation() != null && !user.getOccupation().isBlank()) score += 10;
        if (user.getCity() != null && !user.getCity().isBlank()) score += 10;
        user.setProfileCompleteness(score);
    }

    @Transactional
    public User verifyProfile(Long userId, VerifyRequest request) {
        User user = getUser(userId);
        user.setRealName(request.getRealName());
        user.setIdCard(request.getIdCard());
        user.setSchool(request.getSchool());
        user.setEducation(request.getEducation());
        user.setRealNameVerified(true);
        user.setEducationVerified(true);

        recalcCompleteness(user);

        if (user.getStatus() == User.UserStatus.INCOMPLETE) {
            user.setStatus(User.UserStatus.ACTIVE);
        }
        return userRepository.save(user);
    }

    public void sendCode(SendCodeRequest request) {
        VerificationCode.CodeType type = VerificationCode.CodeType.valueOf(request.getType());
        if (type == VerificationCode.CodeType.REGISTER && userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("该手机号已注册");
        }
        if (type == VerificationCode.CodeType.LOGIN && !userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("该手机号未注册");
        }
        // 生成6位验证码（本地开发固定123456方便调试）
        String code = "123456";
        /*
        String code = String.format("%06d", new java.util.Random().nextInt(999999));
        // 发送短信...
        */

        VerificationCode vc = VerificationCode.builder()
                .phone(request.getPhone())
                .code(code)
                .type(type)
                .expiresAt(java.time.LocalDateTime.now().plusMinutes(5))
                .build();
        codeRepository.save(vc);
    }

    @Transactional
    public LoginResponse register(RegisterRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("该手机号已注册");
        }

        VerificationCode vc = codeRepository.findTopByPhoneAndTypeAndUsedFalseOrderByCreatedAtDesc(
                request.getPhone(), VerificationCode.CodeType.REGISTER)
                .orElseThrow(() -> new RuntimeException("请先获取验证码"));
        if (vc.isExpired()) throw new RuntimeException("验证码已过期");
        if (!vc.getCode().equals(request.getCode())) throw new RuntimeException("验证码错误");

        codeRepository.markUsed(request.getPhone(), VerificationCode.CodeType.REGISTER);

        User user = User.builder()
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .status(User.UserStatus.INCOMPLETE)
                .educationVerified(false)
                .realNameVerified(false)
                .profileCompleteness(0)
                .build();
        user = userRepository.save(user);

        return buildLoginResponse(user);
    }

    @Transactional
    public LoginResponse login(LoginRequest request) {
        VerificationCode vc = codeRepository.findTopByPhoneAndTypeAndUsedFalseOrderByCreatedAtDesc(
                request.getPhone(), VerificationCode.CodeType.LOGIN)
                .orElseThrow(() -> new RuntimeException("请先获取验证码"));
        if (vc.isExpired()) throw new RuntimeException("验证码已过期");
        if (!vc.getCode().equals(request.getCode())) throw new RuntimeException("验证码错误");

        codeRepository.markUsed(request.getPhone(), VerificationCode.CodeType.LOGIN);

        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        return buildLoginResponse(user);
    }

    private LoginResponse buildLoginResponse(User user) {
        String token = jwtUtil.generateToken(user.getId(), user.getPhone());
        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .phone(user.getPhone())
                .nickname(user.getNickname())
                .avatar(user.getAvatar())
                .educationVerified(user.getEducationVerified())
                .realNameVerified(user.getRealNameVerified())
                .status(user.getStatus().name())
                .profileCompleteness(user.getProfileCompleteness())
                .build();
    }

    // ========================
    // 个人中心相关方法
    // ========================

    /** 个人中心聚合数据 */
    public UserCenterResponse getUserCenter(Long userId) {
        User user = getUser(userId);

        // 计算年龄
        Integer age = null;
        if (user.getBirthDate() != null) {
            LocalDate birth = user.getBirthDate().toLocalDate();
            age = Period.between(birth, LocalDate.now()).getYears();
        }

        // 缘分数据
        long likedCount = swipeRepository.countByToUserIdAndDirection(userId, com.qingteng.match.entity.Swipe.Direction.LIKE);
        long likedByCount = swipeRepository.countByFromUserIdAndDirection(userId, com.qingteng.match.entity.Swipe.Direction.LIKE);
        long matchCount = matchRepository.countByUserId(userId);

        // 隐私设置
        UserPrivacy privacy = privacyRepository.findById(userId)
                .orElseGet(() -> {
                    UserPrivacy p = UserPrivacy.builder()
                            .user(user)
                            .readReceipt(true)
                            .locationVisible(true)
                            .onlineVisible(true)
                            .allowStrangerChat(false)
                            .onlineAlert(false)
                            .build();
                    return privacyRepository.save(p);
                });

        return UserCenterResponse.builder()
                .userId(user.getId())
                .nickname(user.getNickname())
                .avatar(user.getAvatar())
                .gender(user.getGender() != null ? user.getGender().name() : null)
                .age(age)
                .city(user.getCity())
                .school(user.getSchool())
                .education(user.getEducation())
                .occupation(user.getOccupation())
                .height(user.getHeight())
                .salaryRange(user.getSalaryRange())
                .bio(user.getBio())
                .realNameVerified(user.getRealNameVerified())
                .educationVerified(user.getEducationVerified())
                .profileCompleteness(user.getProfileCompleteness())
                .status(user.getStatus().name())
                .likedCount(likedCount)
                .likedByCount(likedByCount)
                .matchCount(matchCount)
                .readReceipt(privacy.getReadReceipt())
                .locationVisible(privacy.getLocationVisible())
                .onlineVisible(privacy.getOnlineVisible())
                .allowStrangerChat(privacy.getAllowStrangerChat())
                .onlineAlert(privacy.getOnlineAlert())
                .build();
    }

    /** 用户互动数据统计 */
    public UserStatsResponse getStats(Long userId) {
        long likedCount = swipeRepository.countByFromUserIdAndDirection(userId, com.qingteng.match.entity.Swipe.Direction.LIKE);
        long likedByCount = swipeRepository.countByToUserIdAndDirection(userId, com.qingteng.match.entity.Swipe.Direction.LIKE);
        long matchCount = matchRepository.countByUserId(userId);

        return UserStatsResponse.builder()
                .likedCount(likedCount)
                .likedByCount(likedByCount)
                .matchCount(matchCount)
                .viewCount(0L) // TODO: 浏览计数后续迭代
                .todayRecommend(10L) // TODO: 今日推荐剩余次数后续迭代
                .build();
    }

    /** 读取隐私设置 */
    public UserPrivacy getPrivacy(Long userId) {
        return privacyRepository.findById(userId)
                .orElseGet(() -> privacyRepository.save(UserPrivacy.builder()
                        .user(getUser(userId))
                        .readReceipt(true)
                        .locationVisible(true)
                        .onlineVisible(true)
                        .allowStrangerChat(false)
                        .onlineAlert(false)
                        .build()));
    }

    /** 更新隐私设置 */
    @Transactional
    public UserPrivacy updatePrivacy(Long userId, PrivacyRequest request) {
        UserPrivacy privacy = getPrivacy(userId);

        if (request.getReadReceipt() != null) privacy.setReadReceipt(request.getReadReceipt());
        if (request.getLocationVisible() != null) privacy.setLocationVisible(request.getLocationVisible());
        if (request.getOnlineVisible() != null) privacy.setOnlineVisible(request.getOnlineVisible());
        if (request.getAllowStrangerChat() != null) privacy.setAllowStrangerChat(request.getAllowStrangerChat());
        if (request.getOnlineAlert() != null) privacy.setOnlineAlert(request.getOnlineAlert());

        return privacyRepository.save(privacy);
    }
}