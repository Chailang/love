package com.qingteng.geo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GeoNeighborResponse {

    private Long userId;
    private String nickname;
    private String avatar;
    private Integer age;
    private String education;

    // ======== 匹配维度 ========

    /** 同乡维度：是否同一省份/城市/区县 */
    private String hometownMatch;        // "同省" / "同城" / "同区" / null
    /** 工作维度 */
    private String workMatch;            // "同省-工作" / "同城-工作" / "同区-工作" / null
    /** 居住维度 */
    private String residenceMatch;       // "同城" / "近邻 (<1km)" / "附近 (3-5km)" / null

    /** 综合匹配度标签 */
    private String matchLabel;           // "老乡+同事" / "同城近邻" / "同乡"

    /** 距离（仅 VIP 且双方开关打开时展示精确值） */
    private String distance;             // "<1km" / "3.2km" / null

    /** 搜索维度加权得分（用于排序） */
    private Integer score;
}