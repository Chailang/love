package com.qingteng.bazi.util;

import java.time.LocalDate;
import java.util.*;

/**
 * 八字推算工具：公历 → 天干地支 + 五行统计
 *
 * 天干：甲乙丙丁戊己庚辛壬癸
 * 地支：子丑寅卯辰巳午未申酉戌亥
 * 五行对应：
 *   天干：甲乙→木, 丙丁→火, 戊己→土, 庚辛→金, 壬癸→水
 *   地支：寅卯→木, 巳午→火, 辰戌丑未→土, 申酉→金, 亥子→水
 */
public class BaziCalculator {

    private static final String[] STEMS = {"甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"};
    private static final String[] BRANCHES = {"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"};

    // 五行归属
    private static final Map<String, String> STEM_ELEMENT = new HashMap<>();
    private static final Map<String, String> BRANCH_ELEMENT = new HashMap<>();
    static {
        STEM_ELEMENT.put("甲", "木"); STEM_ELEMENT.put("乙", "木");
        STEM_ELEMENT.put("丙", "火"); STEM_ELEMENT.put("丁", "火");
        STEM_ELEMENT.put("戊", "土"); STEM_ELEMENT.put("己", "土");
        STEM_ELEMENT.put("庚", "金"); STEM_ELEMENT.put("辛", "金");
        STEM_ELEMENT.put("壬", "水"); STEM_ELEMENT.put("癸", "水");

        BRANCH_ELEMENT.put("寅", "木"); BRANCH_ELEMENT.put("卯", "木");
        BRANCH_ELEMENT.put("巳", "火"); BRANCH_ELEMENT.put("午", "火");
        BRANCH_ELEMENT.put("辰", "土"); BRANCH_ELEMENT.put("戌", "土");
        BRANCH_ELEMENT.put("丑", "土"); BRANCH_ELEMENT.put("未", "土");
        BRANCH_ELEMENT.put("申", "金"); BRANCH_ELEMENT.put("酉", "金");
        BRANCH_ELEMENT.put("亥", "水"); BRANCH_ELEMENT.put("子", "水");
    }

    public static BaziResult calculate(int year, int month, int day, int hour) {
        // 年柱：以立春为界，简单估算（2月4日前后）
        int yearIdx = year;
        if (month < 2 || (month == 2 && day < 4)) yearIdx--;

        int yearStemIdx = (yearIdx - 4) % 10;
        int yearBranchIdx = (yearIdx - 4) % 12;

        // 月柱：按节气，简化公式
        int monthStemIdx = (yearStemIdx * 2 + month - 1) % 10;
        int monthBranchIdx = (month + 1) % 12; // 寅月=1

        // 日柱：JDN 公式
        int m = month, y = year;
        if (m <= 2) { m += 12; y--; }
        int C = y / 100, Y = y % 100;
        int jdn = (int)((1729776 + 367 * y) + day + 
                 Math.floor(15.0 * m - 27.0/2.0) +
                 Math.floor(1461.0 * Y / 4.0) +
                 Math.floor(153.0 * (m + 1) / 5.0) -
                 Math.floor(3.0 * C / 4.0) + 1721029.0 + 0.5);

        int baseJdn = (int) Math.floor(2451545.0); // 2000-01-01
        int dayDiff = jdn - baseJdn;
        int dayStemIdx = ((dayDiff % 10) + 10) % 10;
        int dayBranchIdx = ((dayDiff % 12) + 12) % 12;

        // 时柱
        int hourBranchIdx = (hour + 1) / 2 % 12; // 子时=23-1点
        int hourStemIdx = (dayStemIdx * 2 + hourBranchIdx) % 10;

        String yearStem = STEMS[yearStemIdx];
        String yearBranch = BRANCHES[yearBranchIdx];
        String monthStem = STEMS[monthStemIdx];
        String monthBranch = BRANCHES[monthBranchIdx];
        String dayStem = STEMS[dayStemIdx];
        String dayBranch = BRANCHES[dayBranchIdx];
        String hourStem = STEMS[hourStemIdx];
        String hourBranch = BRANCHES[hourBranchIdx];

        // 五行统计
        Map<String, Integer> elements = new HashMap<>();
        elements.put("木", 0); elements.put("火", 0);
        elements.put("土", 0); elements.put("金", 0); elements.put("水", 0);

        countElement(elements, yearStem, true);
        countElement(elements, yearBranch, false);
        countElement(elements, monthStem, true);
        countElement(elements, monthBranch, false);
        countElement(elements, dayStem, true);
        countElement(elements, dayBranch, false);
        countElement(elements, hourStem, true);
        countElement(elements, hourBranch, false);

        return new BaziResult(
            yearStem, yearBranch, monthStem, monthBranch,
            dayStem, dayBranch, hourStem, hourBranch,
            elements.get("木"), elements.get("火"),
            elements.get("土"), elements.get("金"), elements.get("水")
        );
    }

    private static void countElement(Map<String, Integer> map, String s, boolean isStem) {
        String e = isStem ? STEM_ELEMENT.get(s) : BRANCH_ELEMENT.get(s);
        if (e != null) map.merge(e, 1, Integer::sum);
    }

    public static class BaziResult {
        public final String yearStem, yearBranch;
        public final String monthStem, monthBranch;
        public final String dayStem, dayBranch;
        public final String hourStem, hourBranch;
        public final int wood, fire, earth, metal, water;

        public BaziResult(String ys, String yb, String ms, String mb,
                          String ds, String db, String hs, String hb,
                          int w, int f, int e, int m, int wa) {
            this.yearStem = ys; this.yearBranch = yb;
            this.monthStem = ms; this.monthBranch = mb;
            this.dayStem = ds; this.dayBranch = db;
            this.hourStem = hs; this.hourBranch = hb;
            this.wood = w; this.fire = f; this.earth = e;
            this.metal = m; this.water = wa;
        }
    }
}