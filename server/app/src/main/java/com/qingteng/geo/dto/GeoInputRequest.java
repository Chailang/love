package com.qingteng.geo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GeoInputRequest {
    // 家乡
    private String hometownProvince;
    private String hometownCity;
    private String hometownDistrict;

    // 工作
    private String workProvince;
    private String workCity;
    private String workDistrict;

    // 居住
    private String residenceProvince;
    private String residenceCity;
    private String residenceDistrict;
    private Double residenceLat;
    private Double residenceLng;

    // 隐私开关
    private Boolean hometownVisible;
    private Boolean workVisible;
    private Boolean residenceVisible;
    private Boolean exactDistanceVisible;
}