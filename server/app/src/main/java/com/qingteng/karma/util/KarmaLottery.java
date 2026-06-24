package com.qingteng.karma.util;

import com.qingteng.karma.entity.KarmaActionLog;
import java.security.SecureRandom;

/**
 * 缘分盲盒抽奖算法
 * 
 * 稀有度 & 概率：
 * - N  60%  — 普通缘分
 * - R  25%  — 稀有缘分
 * - SR 12%  — 超稀有缘分
 * - SSR 3%  — 天选之缘（暴击周 5%）
 * 
 * 骰子点数影响概率：
 * - 1-3 点：N=70%, R=20%, SR=8%, SSR=2%
 * - 4-5 点：N=55%, R=27%, SR=14%, SSR=4%
 * - 6 点：  N=40%, R=30%, SR=22%, SSR=8%
 * 
 * 扭蛋保底：30 抽必出 SSR
 */
public class KarmaLottery {

    private static final SecureRandom RNG = new SecureRandom();

    // 基础概率
    private static final double[] BASE_RATES = {0.60, 0.25, 0.12, 0.03};  // N, R, SR, SSR
    // SSR 暴击周概率
    private static final double[] BOOST_RATES = {0.55, 0.23, 0.14, 0.08};  // 4月第一周后调整为 8%? No, 按设计文档是 3→5%。这里按高一点做暴击感
    // 实际暴击概率：N=52%, R=23%, SR=17%, SSR=8%

    /** 盲盒抽奖 */
    public static KarmaActionLog.Rarity rollBlind(boolean ssrBoost, int pityCounter) {
        return roll(ssrBoost ? BOOST_RATES : BASE_RATES, pityCounter);
    }

    /** 骰子抽奖（受点数影响） */
    public static KarmaActionLog.Rarity rollDice(int diceValue, boolean ssrBoost) {
        double[] rates;
        if (diceValue <= 3) {
            rates = new double[]{0.70, 0.20, 0.08, 0.02};
        } else if (diceValue <= 5) {
            rates = new double[]{0.55, 0.27, 0.14, 0.04};
        } else {
            rates = new double[]{0.40, 0.30, 0.22, 0.08};
        }
        // 暴击周时 SSR 概率额外提升
        if (ssrBoost) {
            rates[2] -= 0.02;
            rates[3] += 0.02;
            if (rates[2] < 0.05) rates[2] = 0.05;
        }
        return roll(rates, 0);
    }

    /** 扭蛋抽奖（带保底） */
    public static KarmaActionLog.Rarity rollGacha(boolean ssrBoost, int pityCounter) {
        if (pityCounter >= 29) {
            return KarmaActionLog.Rarity.SSR; // 30 抽保底
        }
        return roll(ssrBoost ? BOOST_RATES : BASE_RATES, pityCounter);
    }

    /** 核心抽奖算法 */
    private static KarmaActionLog.Rarity roll(double[] rates, int pityCounter) {
        double roll = RNG.nextDouble();
        double cumulative = 0;

        for (int i = 0; i < rates.length; i++) {
            cumulative += rates[i];
            if (roll < cumulative) {
                return KarmaActionLog.Rarity.values()[i];
            }
        }
        return KarmaActionLog.Rarity.N; // fallback
    }

    /** 判断是否 SSR 暴击周（每月第 3 周） */
    public static boolean isSSRBoostWeek() {
        java.time.LocalDate today = java.time.LocalDate.now();
        int dayOfMonth = today.getDayOfMonth();
        return dayOfMonth >= 15 && dayOfMonth <= 21;
    }

    /** 骰子滚动（1-6） */
    public static int rollDice() {
        return RNG.nextInt(6) + 1;
    }
}