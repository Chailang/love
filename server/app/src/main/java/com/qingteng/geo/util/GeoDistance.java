package com.qingteng.geo.util;

/**
 * 地理距离计算工具
 * 
 * Haversine 公式：计算球面两点间最短距离
 * 地球半径取 6371 km
 */
public class GeoDistance {

    private static final double EARTH_RADIUS_KM = 6371.0;

    /**
     * 计算两点距离（km）
     */
    public static double haversine(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_KM * c;
    }

    /**
     * 格式化距离展示（模糊化）
     * <1km → "<1km"
     * 1-3km → "1-3km"
     * 3-5km → "3-5km"
     * 5-10km → "5-10km"
     * >10km → "{N}km"
     */
    public static String formatDistance(double km, boolean exact) {
        if (exact) {
            return String.format("%.1fkm", km);
        }
        if (km < 1) return "<1km";
        if (km < 3) return "1-3km";
        if (km < 5) return "3-5km";
        if (km < 10) return "5-10km";
        return Math.round(km) + "km";
    }

    /**
     * 判断是否在范围内
     */
    public static boolean withinRadius(double km, double radiusKm) {
        return km <= radiusKm;
    }
}