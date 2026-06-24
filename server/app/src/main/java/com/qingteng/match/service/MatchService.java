package com.qingteng.match.service;

import com.qingteng.match.entity.Match;
import com.qingteng.match.entity.Swipe;
import com.qingteng.match.repository.MatchRepository;
import com.qingteng.match.repository.SwipeRepository;
import com.qingteng.user.entity.User;
import com.qingteng.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final UserRepository userRepository;
    private final SwipeRepository swipeRepository;
    private final MatchRepository matchRepository;

    /**
     * 推荐列表：排除自己、已操作过的用户。按匹配度排序。
     */
    public List<User> recommend(Long userId, int limit) {
        User me = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("用户不存在"));

        Set<Long> excludeIds = new HashSet<>();
        excludeIds.add(userId);
        excludeIds.addAll(swipeRepository.findLikedUserIds(userId));
        excludeIds.addAll(swipeRepository.findPassedUserIds(userId));

        List<User> candidates;
        if (me.getGender() == null) {
            candidates = userRepository.findByIdNotIn(excludeIds);
        } else {
            User.Gender targetGender = me.getGender() == User.Gender.MALE ? User.Gender.FEMALE : User.Gender.MALE;
            candidates = userRepository.findByGenderAndIdNotIn(targetGender, excludeIds);
        }

        String myCity = me.getCity();
        candidates.sort((a, b) -> {
            int scoreA = score(me, a, myCity);
            int scoreB = score(me, b, myCity);
            return Integer.compare(scoreB, scoreA);
        });

        return candidates.stream().limit(limit).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> swipe(Long userId, Long toUserId, String direction) {
        if (userId.equals(toUserId)) throw new RuntimeException("不能操作自己");

        if (swipeRepository.existsByFromUserIdAndToUserId(userId, toUserId)) {
            throw new RuntimeException("已操作过该用户");
        }

        Swipe.Direction dir = Swipe.Direction.valueOf(direction.toUpperCase());
        swipeRepository.save(Swipe.builder()
                .fromUserId(userId).toUserId(toUserId).direction(dir).build());

        Map<String, Object> result = new HashMap<>();
        result.put("matched", false);

        if (dir == Swipe.Direction.LIKE) {
            Optional<Swipe> reverse = swipeRepository.findByFromUserIdAndToUserId(toUserId, userId);
            if (reverse.isPresent() && reverse.get().getDirection() == Swipe.Direction.LIKE) {
                long uid1 = Math.min(userId, toUserId);
                long uid2 = Math.max(userId, toUserId);
                matchRepository.save(Match.builder()
                        .userId1(uid1).userId2(uid2).build());
                result.put("matched", true);
            }
        }

        return result;
    }

    public List<Match> getMatches(Long userId) {
        return matchRepository.findByUserId(userId);
    }

    private int score(User me, User other, String myCity) {
        int s = 0;
        s += (other.getProfileCompleteness() != null ? other.getProfileCompleteness() * 30 / 100 : 0);
        if (myCity != null && other.getCity() != null) {
            if (myCity.equals(other.getCity())) s += 20;
            else if (myCity.length() >= 2 && other.getCity().length() >= 2
                    && myCity.substring(0, 2).equals(other.getCity().substring(0, 2))) s += 10;
        }
        if (me.getEducation() != null && me.getEducation().equals(other.getEducation())) s += 10;
        if (me.getBirthDate() != null && other.getBirthDate() != null) {
            int ageDiff = Math.abs(me.getBirthDate().getYear() - other.getBirthDate().getYear());
            if (ageDiff <= 3) s += 10;
        }
        if (Boolean.TRUE.equals(me.getRealNameVerified()) && Boolean.TRUE.equals(other.getRealNameVerified())) s += 20;
        s += ThreadLocalRandom.current().nextInt(-5, 6);
        return Math.max(0, Math.min(100, s));
    }
}