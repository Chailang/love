package com.qingteng.geo.repository;

import com.qingteng.geo.entity.UserGeo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface UserGeoRepository extends JpaRepository<UserGeo, Long> {

    /** 按同乡匹配：先同区 → 同城 → 同省 */
    @Query("SELECT g FROM UserGeo g WHERE g.hometownVisible = true AND g.userId <> :userId " +
           "AND (g.hometownProvince = :province) " +
           "ORDER BY CASE WHEN g.hometownDistrict = :district THEN 0 ELSE 1 END, " +
           "CASE WHEN g.hometownCity = :city THEN 0 ELSE 1 END")
    List<UserGeo> findHometownMatches(Long userId, String province, String city, String district);

    /** 按工作区域匹配 */
    @Query("SELECT g FROM UserGeo g WHERE g.workVisible = true AND g.userId <> :userId " +
           "AND (g.workProvince = :province OR g.workCity = :city) " +
           "ORDER BY CASE WHEN g.workDistrict = :district THEN 0 ELSE 1 END, " +
           "CASE WHEN g.workCity = :city THEN 0 ELSE 1 END")
    List<UserGeo> findWorkMatches(Long userId, String province, String city, String district);

    /** 按居住位置匹配（精确排序由 Service 层 Haversine 处理） */
    @Query("SELECT g FROM UserGeo g WHERE g.residenceVisible = true AND g.userId <> :userId " +
           "AND g.residenceLat IS NOT NULL AND g.residenceLng IS NOT NULL")
    List<UserGeo> findResidenceCandidates(Long userId);

    /** 多维综合匹配（家乡或工作重叠的用户） */
    @Query("SELECT g FROM UserGeo g WHERE g.userId <> :userId " +
           "AND ((g.hometownVisible = true AND g.hometownProvince = :province) " +
           "OR (g.workVisible = true AND (g.workProvince = :province OR g.workCity = :city))) " +
           "ORDER BY g.userId")
    List<UserGeo> findAllMatches(Long userId, String province, String city);
}