package com.qingteng.bazi.util;

import java.util.*;

/**
 * 八字合缘算法
 *
 * 参考传统八字合婚规则：
 *   - 天干五合 (100%)
 *   - 地支六合 (100%) / 三合 (90%)
 *   - 地支六冲 (负面影响 -40 到 -60)
 *   - 五行相生相克
 *
 * 权重：年柱 20% / 月柱 25% / 日柱 35% / 时柱 20% + 五行额外 ±10
 */
public class BaziMatchCalculator {

    // 天干五合 — 改用 Map 避免 Set.of() 重复元素报错
    private static final Map<String, String> HEAVENLY_COMBINE = new HashMap<>();
    static {
        HEAVENLY_COMBINE.put("甲", "己"); HEAVENLY_COMBINE.put("己", "甲");
        HEAVENLY_COMBINE.put("乙", "庚"); HEAVENLY_COMBINE.put("庚", "乙");
        HEAVENLY_COMBINE.put("丙", "辛"); HEAVENLY_COMBINE.put("辛", "丙");
        HEAVENLY_COMBINE.put("丁", "壬"); HEAVENLY_COMBINE.put("壬", "丁");
        HEAVENLY_COMBINE.put("戊", "癸"); HEAVENLY_COMBINE.put("癸", "戊");
    }

    // 地支六合
    private static final Map<String, String> EARTHLY_SIX_COMBINE = new HashMap<>();
    static {
        EARTHLY_SIX_COMBINE.put("子", "丑"); EARTHLY_SIX_COMBINE.put("丑", "子");
        EARTHLY_SIX_COMBINE.put("寅", "亥"); EARTHLY_SIX_COMBINE.put("亥", "寅");
        EARTHLY_SIX_COMBINE.put("卯", "戌"); EARTHLY_SIX_COMBINE.put("戌", "卯");
        EARTHLY_SIX_COMBINE.put("辰", "酉"); EARTHLY_SIX_COMBINE.put("酉", "辰");
        EARTHLY_SIX_COMBINE.put("巳", "申"); EARTHLY_SIX_COMBINE.put("申", "巳");
        EARTHLY_SIX_COMBINE.put("午", "未"); EARTHLY_SIX_COMBINE.put("未", "午");
    }

    // 地支三合
    private static final List<Set<String>> EARTHLY_TRIPLE = List.of(
        Set.of("申", "子", "辰"), Set.of("巳", "酉", "丑"),
        Set.of("寅", "午", "戌"), Set.of("亥", "卯", "未")
    );

    // 地支六冲
    private static final Map<String, String> EARTHLY_CLASH = new HashMap<>();
    static {
        EARTHLY_CLASH.put("子", "午"); EARTHLY_CLASH.put("午", "子");
        EARTHLY_CLASH.put("丑", "未"); EARTHLY_CLASH.put("未", "丑");
        EARTHLY_CLASH.put("寅", "申"); EARTHLY_CLASH.put("申", "寅");
        EARTHLY_CLASH.put("卯", "酉"); EARTHLY_CLASH.put("酉", "卯");
        EARTHLY_CLASH.put("辰", "戌"); EARTHLY_CLASH.put("戌", "辰");
        EARTHLY_CLASH.put("巳", "亥"); EARTHLY_CLASH.put("亥", "巳");
    }

    // 五行相生
    private static final Map<String, String> ELEMENT_GENERATE = new HashMap<>();
    static {
        ELEMENT_GENERATE.put("木", "火");
        ELEMENT_GENERATE.put("火", "土");
        ELEMENT_GENERATE.put("土", "金");
        ELEMENT_GENERATE.put("金", "水");
        ELEMENT_GENERATE.put("水", "木");
    }

    // 五行相克
    private static final Map<String, String> ELEMENT_OVERCOME = new HashMap<>();
    static {
        ELEMENT_OVERCOME.put("木", "土");
        ELEMENT_OVERCOME.put("土", "水");
        ELEMENT_OVERCOME.put("水", "火");
        ELEMENT_OVERCOME.put("火", "金");
        ELEMENT_OVERCOME.put("金", "木");
    }

    public static MatchResult calculate(BaziCalculator.BaziResult a, BaziCalculator.BaziResult b) {
        int year = pillarScore(a.yearStem, a.yearBranch, b.yearStem, b.yearBranch);
        int month = pillarScore(a.monthStem, a.monthBranch, b.monthStem, b.monthBranch);
        int day = pillarScore(a.dayStem, a.dayBranch, b.dayStem, b.dayBranch);
        int hour = pillarScore(a.hourStem, a.hourBranch, b.hourStem, b.hourBranch);

        int elem = elementBonus(
            new int[]{a.wood, a.fire, a.earth, a.metal, a.water},
            new int[]{b.wood, b.fire, b.earth, b.metal, b.water}
        );

        int total = (int)(year * 0.20 + month * 0.25 + day * 0.35 + hour * 0.20 + elem);
        total = Math.max(0, Math.min(100, total));

        // 生成评语
        String summary = buildSummary(total, year, month, day, hour, elem);

        return new MatchResult(total, year, month, day, hour, elem, summary);
    }

    private static int pillarScore(String stemA, String branchA, String stemB, String branchB) {
        int score = 50; // 中性基准

        // 天干五合 = 100
        if (isHeavenlyCombine(stemA, stemB)) score += 50;

        // 地支六合 = 100
        if (isEarthlySixCombine(branchA, branchB)) score += 50;

        // 地支三合 = 90
        if (isEarthlyTriple(branchA, branchB)) score += 40;

        // 地支六冲
        if (isEarthlyClash(branchA, branchB)) score -= 60;

        return Math.max(0, Math.min(100, score));
    }

    private static int elementBonus(int[] a, int[] b) {
        // 计算主导五行
        String domA = dominantElement(a);
        String domB = dominantElement(b);

        if (domA == null || domB == null) return 0;

        // 相生：A生B 或 B生A
        if (ELEMENT_GENERATE.getOrDefault(domA, "").equals(domB) ||
            ELEMENT_GENERATE.getOrDefault(domB, "").equals(domA)) {
            return 10;
        }

        // 相克：减分
        if (ELEMENT_OVERCOME.getOrDefault(domA, "").equals(domB) ||
            ELEMENT_OVERCOME.getOrDefault(domB, "").equals(domA)) {
            return -10;
        }

        return 0;
    }

    private static String dominantElement(int[] counts) {
        String[] names = {"木", "火", "土", "金", "水"};
        int max = -1, idx = -1;
        for (int i = 0; i < 5; i++) {
            if (counts[i] > max) { max = counts[i]; idx = i; }
        }
        return idx >= 0 ? names[idx] : null;
    }

    private static boolean isHeavenlyCombine(String a, String b) {
        return b.equals(HEAVENLY_COMBINE.get(a));
    }

    private static boolean isEarthlySixCombine(String a, String b) {
        return b.equals(EARTHLY_SIX_COMBINE.get(a));
    }

    private static boolean isEarthlyTriple(String a, String b) {
        for (Set<String> s : EARTHLY_TRIPLE) {
            if (s.contains(a) && s.contains(b)) return true;
        }
        return false;
    }

    private static boolean isEarthlyClash(String a, String b) {
        return b.equals(EARTHLY_CLASH.get(a));
    }

    private static String buildSummary(int total, int y, int m, int d, int h, int e) {
        StringBuilder sb = new StringBuilder();
        if (total >= 85) sb.append("天作之合！");
        else if (total >= 70) sb.append("缘分颇深，值得了解。");
        else if (total >= 50) sb.append("中规中矩，顺其自然。");
        else sb.append("缘分尚浅，随缘即可。");

        sb.append(" 年柱").append(describePillar(y))
          .append("，月柱").append(describePillar(m))
          .append("，日柱").append(describePillar(d))
          .append("，时柱").append(describePillar(h))
          .append("。");

        if (e > 0) sb.append(" 五行互补，相得益彰。");
        else if (e < 0) sb.append(" 五行略有冲突。");

        sb.append(" ⚠️以上内容仅供娱乐参考。");
        return sb.toString();
    }

    private static String describePillar(int score) {
        if (score >= 90) return "大吉";
        if (score >= 70) return "吉";
        if (score >= 40) return "平";
        return "凶";
    }

    public static class MatchResult {
        public final int total, year, month, day, hour, elementBonus;
        public final String summary;

        public MatchResult(int total, int year, int month, int day, int hour, int elem, String summary) {
            this.total = total; this.year = year; this.month = month;
            this.day = day; this.hour = hour; this.elementBonus = elem;
            this.summary = summary;
        }
    }
}