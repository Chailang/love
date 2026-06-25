/// 小镇之恋 — 全局配置
class AppConfig {
  /// API 服务器地址（开发环境 — 手机连电脑用局域网 IP）
  static const String apiBaseUrl = 'http://192.168.1.7:8080/api/v1';

  /// WebSocket STOMP 地址（原生 WebSocket，不走 SockJS）
  static const String wsUrl = 'ws://192.168.1.7:8080/ws/chat';

  /// 应用名称
  static const String appName = '小镇之恋';

  /// 应用 Slogan
  static const String slogan = '在小镇之恋，遇见和你一样优秀的TA';

  /// 用户协议 URL（占位，后续替换为正式 H5）
  static const String userAgreementUrl = 'https://www.baidu.com';

  /// 隐私政策 URL（占位，后续替换为正式 H5）
  static const String privacyPolicyUrl = 'https://www.baidu.com';
}