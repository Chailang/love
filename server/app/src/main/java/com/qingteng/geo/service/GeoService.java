package com.qingteng.geo.service;

import com.qingteng.geo.dto.GeoInputRequest;
import com.qingteng.geo.dto.GeoNeighborResponse;
import com.qingteng.geo.entity.UserGeo;
import com.qingteng.geo.repository.UserGeoRepository;
import com.qingteng.geo.util.GeoDistance;
import com.qingteng.user.entity.User;
import com.qingteng.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Period;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GeoService {

    private final UserGeoRepository geoRepository;
    private final UserRepository userRepository;

    // ========== 位置档案管理 ==========

    /** 获取或初始化位置档案 */
    public UserGeo getOrCreateGeo(Long userId) {
        return geoRepository.findById(userId).orElseGet(() ->
                geoRepository.save(UserGeo.builder()
                        .userId(userId)
                        .hometownVisible(true)
                        .workVisible(true)
                        .residenceVisible(false)
                        .exactDistanceVisible(false)
                        .build()));
    }

    /** 更新位置档案 */
    @Transactional
    public UserGeo updateGeo(Long userId, GeoInputRequest request) {
        UserGeo geo = getOrCreateGeo(userId);

        // 家乡
        if (request.getHometownProvince() != null) {
            geo.setHometownProvince(request.getHometownProvince());
            geo.setHometownCity(request.getHometownCity());
            geo.setHometownDistrict(request.getHometownDistrict());
        }
        // 工作
        if (request.getWorkProvince() != null) {
            geo.setWorkProvince(request.getWorkProvince());
            geo.setWorkCity(request.getWorkCity());
            geo.setWorkDistrict(request.getWorkDistrict());
        }
        // 居住
        if (request.getResidenceProvince() != null) {
            geo.setResidenceProvince(request.getResidenceProvince());
            geo.setResidenceCity(request.getResidenceCity());
            geo.setResidenceDistrict(request.getResidenceDistrict());
        }
        if (request.getResidenceLat() != null && request.getResidenceLng() != null) {
            geo.setResidenceLat(BigDecimal.valueOf(request.getResidenceLat()).setScale(7, RoundingMode.HALF_UP));
            geo.setResidenceLng(BigDecimal.valueOf(request.getResidenceLng()).setScale(7, RoundingMode.HALF_UP));
        }
        // 隐私开关
        if (request.getHometownVisible() != null) geo.setHometownVisible(request.getHometownVisible());
        if (request.getWorkVisible() != null) geo.setWorkVisible(request.getWorkVisible());
        if (request.getResidenceVisible() != null) geo.setResidenceVisible(request.getResidenceVisible());
        if (request.getExactDistanceVisible() != null) geo.setExactDistanceVisible(request.getExactDistanceVisible());

        return geoRepository.save(geo);
    }

    // ========== 同乡搜索 ==========

    /** 同乡搜索（按家乡维度） */
    public List<GeoNeighborResponse> searchHometown(Long userId) {
        UserGeo myGeo = getOrCreateGeo(userId);
        if (myGeo.getHometownProvince() == null) {
            return Collections.emptyList();
        }

        List<UserGeo> matches = geoRepository.findHometownMatches(
                userId, myGeo.getHometownProvince(), myGeo.getHometownCity(), myGeo.getHometownDistrict());

        return matches.stream()
                .map(m -> buildResponse(m, myGeo, "hometown"))
                .filter(Objects::nonNull)
                .sorted(Comparator.comparingInt(GeoNeighborResponse::getScore).reversed())
                .limit(20)
                .collect(Collectors.toList());
    }

    /** 工作区域搜索 */
    public List<GeoNeighborResponse> searchWork(Long userId) {
        UserGeo myGeo = getOrCreateGeo(userId);
        if (myGeo.getWorkProvince() == null) {
            return Collections.emptyList();
        }

        List<UserGeo> matches = geoRepository.findWorkMatches(
                userId, myGeo.getWorkProvince(), myGeo.getWorkCity(), myGeo.getWorkDistrict());

        return matches.stream()
                .map(m -> buildResponse(m, myGeo, "work"))
                .filter(Objects::nonNull)
                .sorted(Comparator.comparingInt(GeoNeighborResponse::getScore).reversed())
                .limit(20)
                .collect(Collectors.toList());
    }

    /** 居住近邻搜索（距离排序） */
    public List<GeoNeighborResponse> searchResidence(Long userId) {
        UserGeo myGeo = getOrCreateGeo(userId);
        if (!myGeo.getResidenceVisible() || myGeo.getResidenceLat() == null || myGeo.getResidenceLng() == null) {
            return Collections.emptyList();
        }

        List<UserGeo> candidates = geoRepository.findResidenceCandidates(userId);

        // 计算距离并排序
        return candidates.stream()
                .filter(c -> c.getResidenceLat() != null && c.getResidenceLng() != null)
                .map(c -> {
                    double km = GeoDistance.haversine(
                            myGeo.getResidenceLat().doubleValue(),
                            myGeo.getResidenceLng().doubleValue(),
                            c.getResidenceLat().doubleValue(),
                            c.getResidenceLng().doubleValue());

                    User user = userRepository.findById(c.getUserId()).orElse(null);
                    if (user == null) return null;

                    return GeoNeighborResponse.builder()
                            .userId(user.getId())
                            .nickname(user.getNickname())
                            .avatar(user.getAvatar())
                            .age(calcAge(user))
                            .education(user.getEducation())
                            .residenceMatch(GeoDistance.formatDistance(km, false))
                            .distance(GeoDistance.formatDistance(km, false))
                            .score((int) Math.max(0, 100 - km * 10)) // 越近分数越高
                            .build();
                })
                .filter(Objects::nonNull)
                .sorted(Comparator.comparingInt(GeoNeighborResponse::getScore).reversed())
                .limit(20)
                .collect(Collectors.toList());
    }

    /** 综合搜索（同乡+工作+近邻） */
    public List<GeoNeighborResponse> searchAll(Long userId) {
        UserGeo myGeo = getOrCreateGeo(userId);

        Set<Long> seen = new HashSet<>();
        List<GeoNeighborResponse> results = new ArrayList<>();

        // 1. 同乡
        if (myGeo.getHometownProvince() != null) {
            List<UserGeo> hometown = geoRepository.findHometownMatches(
                    userId, myGeo.getHometownProvince(), myGeo.getHometownCity(), myGeo.getHometownDistrict());
            for (UserGeo m : hometown) {
                if (seen.add(m.getUserId())) {
                    GeoNeighborResponse r = buildResponse(m, myGeo, "hometown");
                    if (r != null) results.add(r);
                }
            }
        }

        // 2. 工作
        if (myGeo.getWorkProvince() != null) {
            List<UserGeo> work = geoRepository.findWorkMatches(
                    userId, myGeo.getWorkProvince(), myGeo.getWorkCity(), myGeo.getWorkDistrict());
            for (UserGeo m : work) {
                if (seen.add(m.getUserId())) {
                    GeoNeighborResponse r = buildResponse(m, myGeo, "work");
                    if (r != null) results.add(r);
                }
            }
        }

        // 3. 近邻
        if (myGeo.getResidenceVisible() && myGeo.getResidenceLat() != null) {
            List<GeoNeighborResponse> res = searchResidence(userId);
            for (GeoNeighborResponse r : res) {
                if (seen.add(r.getUserId())) {
                    results.add(r);
                }
            }
        }

        return results.stream()
                .sorted(Comparator.comparingInt(GeoNeighborResponse::getScore).reversed())
                .limit(30)
                .collect(Collectors.toList());
    }

    // ========== 辅助方法 ==========

    private GeoNeighborResponse buildResponse(UserGeo matched, UserGeo myGeo, String dimension) {
        User user = userRepository.findById(matched.getUserId()).orElse(null);
        if (user == null) return null;

        int score = 0;
        String hometownMatch = null;
        String workMatch = null;
        List<String> labels = new ArrayList<>();

        if ("hometown".equals(dimension) && myGeo.getHometownProvince() != null && matched.getHometownProvince() != null) {
            if (myGeo.getHometownDistrict() != null && myGeo.getHometownDistrict().equals(matched.getHometownDistrict())) {
                hometownMatch = "同区";
                score += 30;
            } else if (myGeo.getHometownCity() != null && myGeo.getHometownCity().equals(matched.getHometownCity())) {
                hometownMatch = "同城";
                score += 20;
            } else {
                hometownMatch = "同省";
                score += 10;
            }
            labels.add("老乡");
        }

        if ("work".equals(dimension) && myGeo.getWorkProvince() != null && matched.getWorkProvince() != null) {
            if (myGeo.getWorkDistrict() != null && myGeo.getWorkDistrict().equals(matched.getWorkDistrict())) {
                workMatch = "同区-工作";
                score += 25;
            } else if (myGeo.getWorkCity() != null && myGeo.getWorkCity().equals(matched.getWorkCity())) {
                workMatch = "同城-工作";
                score += 15;
            } else {
                workMatch = "同省-工作";
                score += 5;
            }
            labels.add("同事圈");
        }

        String matchLabel = labels.isEmpty() ? null : String.join("+", labels);

        return GeoNeighborResponse.builder()
                .userId(user.getId())
                .nickname(user.getNickname())
                .avatar(user.getAvatar())
                .age(calcAge(user))
                .education(user.getEducation())
                .hometownMatch(hometownMatch)
                .workMatch(workMatch)
                .matchLabel(matchLabel)
                .score(score)
                .build();
    }

    private Integer calcAge(User user) {
        if (user.getBirthDate() == null) return null;
        return Period.between(user.getBirthDate().toLocalDate(), LocalDate.now()).getYears();
    }
}