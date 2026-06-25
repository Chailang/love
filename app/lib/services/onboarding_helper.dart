import '../models/user_center.dart';

/// 新用户引导 / 资料完整性判断
class OnboardingHelper {
  OnboardingHelper._();

  /// 登录后是否还需走分步资料向导
  static bool needsProfileSetup(UserCenter? center) {
    if (center == null) return true;
    if (center.status == 'INCOMPLETE') return true;
    if (center.gender == null || center.gender!.isEmpty) return true;
    if (center.age == null) return true;
    if (center.city == null || center.city!.isEmpty) return true;
    return false;
  }
}
