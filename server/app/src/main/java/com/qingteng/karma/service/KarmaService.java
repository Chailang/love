package com.qingteng.karma.service;

import com.qingteng.karma.dto.KarmaAccountResponse;
import com.qingteng.karma.dto.KarmaResultResponse;
import com.qingteng.karma.entity.KarmaActionLog;
import com.qingteng.karma.entity.KarmaCoinAccount;
import com.qingteng.karma.repository.KarmaActionLogRepository;
import com.qingteng.karma.repository.KarmaCoinAccountRepository;
import com.qingteng.karma.util.KarmaLottery;
import com.qingteng.user.entity.User;
import com.qingteng.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class KarmaService {

    private final KarmaCoinAccountRepository accountRepository;
    private final KarmaActionLogRepository logRepository;
    private final UserRepository userRepository;

    // ========== 费用配置 ==========
    private static final int BLIND_COST = 5;
    private static final int DICE_COST = 3;
    private static final int GACHA_COST = 3;
    private static final int NEW_USER_BONUS = 3;      // 新用户赠送
    private static final int MATCH_BONUS = 2;          // 匹配成功奖励

    // ========== 日限 ==========
    private static final int DAILY_BLIND_LIMIT = 3;
    private static final int DAILY_DICE_LIMIT = 5;
    private static final int DAILY_GACHA_LIMIT = 20;

    // ========== 账号管理 ==========

    /** 获取或初始化账户 */
    public KarmaCoinAccount getOrCreateAccount(Long userId) {
        return accountRepository.findById(userId).orElseGet(() -> {
            KarmaCoinAccount account = KarmaCoinAccount.builder()
                    .userId(userId)
                    .balance(NEW_USER_BONUS)
                    .totalEarned(NEW_USER_BONUS)
                    .totalSpent(0)
                    .pityCounter(0)
                    .dailyBlindUsed(0)
                    .dailyDiceUsed(0)
                    .dailyGachaUsed(0)
                    .lastResetDate(LocalDate.now())
                    .build();
            return accountRepository.save(account);
        });
    }

    /** 查看账户状态 */
    public KarmaAccountResponse getAccount(Long userId) {
        KarmaCoinAccount account = getOrCreateAccount(userId);
        resetDailyIfNeeded(account);
        return KarmaAccountResponse.builder()
                .userId(userId)
                .balance(account.getBalance())
                .totalEarned(account.getTotalEarned())
                .totalSpent(account.getTotalSpent())
                .pityCounter(account.getPityCounter())
                .dailyBlindUsed(account.getDailyBlindUsed())
                .dailyDiceUsed(account.getDailyDiceUsed())
                .dailyGachaUsed(account.getDailyGachaUsed())
                .ssrBoostActive(KarmaLottery.isSSRBoostWeek())
                .build();
    }

    /** 匹配成功奖励 */
    @Transactional
    public void awardMatchBonus(Long userId) {
        KarmaCoinAccount account = getOrCreateAccount(userId);
        account.setBalance(account.getBalance() + MATCH_BONUS);
        account.setTotalEarned(account.getTotalEarned() + MATCH_BONUS);
        accountRepository.save(account);
    }

    // ========== 盲盒 🎁 ==========

    @Transactional
    public KarmaResultResponse playBlind(Long userId) {
        KarmaCoinAccount account = getOrCreateAccount(userId);
        resetDailyIfNeeded(account);

        // 校验余额
        if (account.getBalance() < BLIND_COST) {
            throw new RuntimeException("缘分币不足！需要 " + BLIND_COST + " 枚，当前 " + account.getBalance());
        }
        // 校验日限
        if (account.getDailyBlindUsed() >= DAILY_BLIND_LIMIT) {
            throw new RuntimeException("今日盲盒次数已用完（" + DAILY_BLIND_LIMIT + " 次）");
        }

        // 扣费
        deductCoins(account, BLIND_COST);

        // 抽奖
        boolean boost = KarmaLottery.isSSRBoostWeek();
        KarmaActionLog.Rarity rarity = KarmaLottery.rollBlind(boost, account.getPityCounter());

        // 匹配用户（随机选取一个异性用户）
        String matchedNickname = null;
        String matchedAvatar = null;
        Long matchedUserId = null;

        User currentUser = userRepository.findById(userId).orElse(null);
        if (currentUser != null && currentUser.getGender() != null) {
            // 随机找一个异性活跃用户
            Optional<User> match = userRepository.findRandomUserExcluding(
                    userId, currentUser.getGender());
            if (match.isPresent()) {
                matchedUserId = match.get().getId();
                matchedNickname = match.get().getNickname();
                matchedAvatar = match.get().getAvatar();
            }
        }

        // 记录日志
        account.setDailyBlindUsed(account.getDailyBlindUsed() + 1);
        accountRepository.save(account);

        KarmaActionLog log = KarmaActionLog.builder()
                .userId(userId)
                .actionType(KarmaActionLog.ActionType.BLIND)
                .coinCost(BLIND_COST)
                .rarity(rarity)
                .matchedUserId(matchedUserId)
                .build();
        logRepository.save(log);

        return buildResponse(account, rarity, KarmaActionLog.ActionType.BLIND.name(),
                matchedUserId, matchedNickname, matchedAvatar, null);
    }

    // ========== 骰子 🎲 ==========

    @Transactional
    public KarmaResultResponse playDice(Long userId) {
        KarmaCoinAccount account = getOrCreateAccount(userId);
        resetDailyIfNeeded(account);

        if (account.getBalance() < DICE_COST) {
            throw new RuntimeException("缘分币不足！需要 " + DICE_COST + " 枚，当前 " + account.getBalance());
        }
        if (account.getDailyDiceUsed() >= DAILY_DICE_LIMIT) {
            throw new RuntimeException("今日骰子次数已用完（" + DAILY_DICE_LIMIT + " 次）");
        }

        deductCoins(account, DICE_COST);

        int diceValue = KarmaLottery.rollDice();
        boolean boost = KarmaLottery.isSSRBoostWeek();
        KarmaActionLog.Rarity rarity = KarmaLottery.rollDice(diceValue, boost);

        account.setDailyDiceUsed(account.getDailyDiceUsed() + 1);
        accountRepository.save(account);

        KarmaActionLog log = KarmaActionLog.builder()
                .userId(userId)
                .actionType(KarmaActionLog.ActionType.DICE)
                .coinCost(DICE_COST)
                .rarity(rarity)
                .diceValue(diceValue)
                .build();
        logRepository.save(log);

        return buildResponse(account, rarity, KarmaActionLog.ActionType.DICE.name(),
                null, null, null, diceValue);
    }

    // ========== 扭蛋 🥚 ==========

    @Transactional
    public KarmaResultResponse playGacha(Long userId, int count) {
        if (count != 1 && count != 10) {
            throw new RuntimeException("单抽 (1) 或十连 (10)");
        }

        KarmaCoinAccount account = getOrCreateAccount(userId);
        resetDailyIfNeeded(account);

        int totalCost = GACHA_COST * count;
        if (account.getBalance() < totalCost) {
            throw new RuntimeException("缘分币不足！需要 " + totalCost + " 枚，当前 " + account.getBalance());
        }
        if (account.getDailyGachaUsed() + count > DAILY_GACHA_LIMIT) {
            throw new RuntimeException("今日扭蛋次数已用完（剩余 " + (DAILY_GACHA_LIMIT - account.getDailyGachaUsed()) + " 次）");
        }

        deductCoins(account, totalCost);

        boolean boost = KarmaLottery.isSSRBoostWeek();
        KarmaActionLog.Rarity bestRarity = KarmaActionLog.Rarity.N;

        for (int i = 0; i < count; i++) {
            KarmaActionLog.Rarity rarity = KarmaLottery.rollGacha(boost, account.getPityCounter());

            if (rarity == KarmaActionLog.Rarity.SSR) {
                account.setPityCounter(0); // SSR 重置保底
            } else {
                account.setPityCounter(account.getPityCounter() + 1);
            }

            if (rarity.ordinal() > bestRarity.ordinal()) {
                bestRarity = rarity;
            }

            KarmaActionLog log = KarmaActionLog.builder()
                    .userId(userId)
                    .actionType(KarmaActionLog.ActionType.GACHA)
                    .coinCost(GACHA_COST)
                    .rarity(rarity)
                    .build();
            logRepository.save(log);
        }

        // 十连保底：如果全是 N，送一个 SR
        if (count == 10 && bestRarity == KarmaActionLog.Rarity.N) {
            bestRarity = KarmaActionLog.Rarity.SR;
        }

        account.setDailyGachaUsed(account.getDailyGachaUsed() + count);
        accountRepository.save(account);

        // 随机匹配
        String matchedNickname = null;
        String matchedAvatar = null;
        Long matchedUserId = null;

        User currentUser = userRepository.findById(userId).orElse(null);
        if (currentUser != null && currentUser.getGender() != null) {
            Optional<User> match = userRepository.findRandomUserExcluding(
                    userId, currentUser.getGender());
            if (match.isPresent()) {
                matchedUserId = match.get().getId();
                matchedNickname = match.get().getNickname();
                matchedAvatar = match.get().getAvatar();
            }
        }

        return buildResponse(account, bestRarity, KarmaActionLog.ActionType.GACHA.name(),
                matchedUserId, matchedNickname, matchedAvatar, null);
    }

    // ========== 辅助方法 ==========

    private void deductCoins(KarmaCoinAccount account, int amount) {
        account.setBalance(account.getBalance() - amount);
        account.setTotalSpent(account.getTotalSpent() + amount);
    }

    private void resetDailyIfNeeded(KarmaCoinAccount account) {
        if (account.getLastResetDate() == null || !account.getLastResetDate().equals(LocalDate.now())) {
            account.setDailyBlindUsed(0);
            account.setDailyDiceUsed(0);
            account.setDailyGachaUsed(0);
            account.setLastResetDate(LocalDate.now());
        }
    }

    private KarmaResultResponse buildResponse(KarmaCoinAccount account, KarmaActionLog.Rarity rarity,
                                               String actionType, Long matchedUserId,
                                               String matchedNickname, String matchedAvatar,
                                               Integer diceValue) {
        boolean isSSR = rarity == KarmaActionLog.Rarity.SSR;
        return KarmaResultResponse.builder()
                .actionType(actionType)
                .rarity(rarity.name())
                .matchedUserId(matchedUserId)
                .matchedNickname(matchedNickname)
                .matchedAvatar(matchedAvatar)
                .diceValue(diceValue)
                .coinBalance(account.getBalance())
                .pityCounter(account.getPityCounter())
                .isSSR(isSSR)
                .description(buildDescription(rarity, diceValue, account.getPityCounter()))
                .build();
    }

    private String buildDescription(KarmaActionLog.Rarity rarity, Integer diceValue, int pity) {
        if (diceValue != null) {
            return switch (rarity) {
                case SSR -> "🎲 骰子 " + diceValue + " 点！天选之缘降临！";
                case SR -> "🎲 骰子 " + diceValue + " 点！超稀有缘分出现！";
                case R -> "🎲 骰子 " + diceValue + " 点！稀有缘分就在眼前！";
                case N -> "🎲 骰子 " + diceValue + " 点！普通缘分，再接再厉！";
            };
        }
        return switch (rarity) {
            case SSR -> "💫 SSR！天选之缘！命中注定！";
            case SR -> "✨ SR！超稀有缘分！";
            case R -> "🌟 R！稀有缘分！";
            case N -> "💝 N！缘分就在身边~";
        };
    }
}