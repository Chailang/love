package com.qingteng.bazi.service;

import com.qingteng.bazi.dto.BaziInputRequest;
import com.qingteng.bazi.dto.BaziMatchResponse;
import com.qingteng.bazi.entity.BaziMatchResult;
import com.qingteng.bazi.entity.UserBazi;
import com.qingteng.bazi.repository.BaziMatchResultRepository;
import com.qingteng.bazi.repository.UserBaziRepository;
import com.qingteng.bazi.util.BaziCalculator;
import com.qingteng.bazi.util.BaziMatchCalculator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BaziService {

    private final UserBaziRepository baziRepository;
    private final BaziMatchResultRepository matchResultRepository;

    @Transactional
    public UserBazi saveBazi(Long userId, BaziInputRequest request) {
        BaziCalculator.BaziResult r = BaziCalculator.calculate(
            request.getBirthYear(), request.getBirthMonth(), request.getBirthDay(), request.getHour()
        );

        UserBazi bazi = baziRepository.findByUserId(userId)
            .orElse(UserBazi.builder().userId(userId).build());

        bazi.setBirthYear(request.getBirthYear());
        bazi.setBirthMonth(request.getBirthMonth());
        bazi.setBirthDay(request.getBirthDay());
        bazi.setHour(request.getHour());
        bazi.setYearStem(r.yearStem);  bazi.setYearBranch(r.yearBranch);
        bazi.setMonthStem(r.monthStem); bazi.setMonthBranch(r.monthBranch);
        bazi.setDayStem(r.dayStem);    bazi.setDayBranch(r.dayBranch);
        bazi.setHourStem(r.hourStem);  bazi.setHourBranch(r.hourBranch);
        bazi.setWoodCount(r.wood);     bazi.setFireCount(r.fire);
        bazi.setEarthCount(r.earth);   bazi.setMetalCount(r.metal);
        bazi.setWaterCount(r.water);

        return baziRepository.save(bazi);
    }

    public UserBazi getBazi(Long userId) {
        return baziRepository.findByUserId(userId)
            .orElseThrow(() -> new RuntimeException("请先录入出生时辰"));
    }

    public BaziMatchResponse calculateMatch(Long userId1, Long userId2) {
        UserBazi a = baziRepository.findByUserId(userId1)
            .orElseThrow(() -> new RuntimeException("请先录入出生时辰"));
        UserBazi b = baziRepository.findByUserId(userId2)
            .orElseThrow(() -> new RuntimeException("对方尚未录入出生时辰"));

        BaziCalculator.BaziResult r1 = buildResult(a);
        BaziCalculator.BaziResult r2 = buildResult(b);

        BaziMatchCalculator.MatchResult match = BaziMatchCalculator.calculate(r1, r2);

        // 保存/更新结果
        long uid1 = Math.min(userId1, userId2);
        long uid2 = Math.max(userId1, userId2);
        BaziMatchResult result = matchResultRepository.findByUserPair(uid1, uid2)
            .orElse(BaziMatchResult.builder().userId1(uid1).userId2(uid2).build());
        result.setScore(match.total);
        result.setYearScore(match.year);
        result.setMonthScore(match.month);
        result.setDayScore(match.day);
        result.setHourScore(match.hour);
        result.setElementBonus(match.elementBonus);
        result.setSummary(match.summary);
        matchResultRepository.save(result);

        return BaziMatchResponse.builder()
            .userId1(userId1).userId2(userId2)
            .score(match.total)
            .yearScore(match.year).monthScore(match.month)
            .dayScore(match.day).hourScore(match.hour)
            .elementBonus(match.elementBonus).summary(match.summary)
            .bazi1(formatBazi(a)).bazi2(formatBazi(b))
            .build();
    }

    private BaziCalculator.BaziResult buildResult(UserBazi b) {
        return BaziCalculator.calculate(
            b.getBirthYear(), b.getBirthMonth(), b.getBirthDay(), b.getHour()
        );
    }

    private String formatBazi(UserBazi b) {
        return String.format("%s%s %s%s %s%s %s%s",
            b.getYearStem(), b.getYearBranch(),
            b.getMonthStem(), b.getMonthBranch(),
            b.getDayStem(), b.getDayBranch(),
            b.getHourStem(), b.getHourBranch()
        );
    }
}