package com.qingteng.geo.controller;

import com.qingteng.geo.dto.GeoInputRequest;
import com.qingteng.geo.dto.GeoNeighborResponse;
import com.qingteng.geo.entity.UserGeo;
import com.qingteng.geo.service.GeoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/geo")
@RequiredArgsConstructor
public class GeoController {

    private final GeoService geoService;

    /** 查看自己的位置档案 */
    @GetMapping("/me")
    public ResponseEntity<UserGeo> myGeo(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(geoService.getOrCreateGeo(userId));
    }

    /** 更新位置档案 */
    @PutMapping("/me")
    public ResponseEntity<UserGeo> updateGeo(@AuthenticationPrincipal Long userId,
                                             @RequestBody GeoInputRequest request) {
        return ResponseEntity.ok(geoService.updateGeo(userId, request));
    }

    /** 搜索同乡（按家乡维度） */
    @GetMapping("/hometown")
    public ResponseEntity<List<GeoNeighborResponse>> searchHometown(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(geoService.searchHometown(userId));
    }

    /** 搜索工作圈（按工作维度） */
    @GetMapping("/work")
    public ResponseEntity<List<GeoNeighborResponse>> searchWork(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(geoService.searchWork(userId));
    }

    /** 搜索近邻（按居住地距离） */
    @GetMapping("/residence")
    public ResponseEntity<List<GeoNeighborResponse>> searchResidence(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(geoService.searchResidence(userId));
    }

    /** 综合搜索（同乡+工作+近邻） */
    @GetMapping("/all")
    public ResponseEntity<List<GeoNeighborResponse>> searchAll(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(geoService.searchAll(userId));
    }
}