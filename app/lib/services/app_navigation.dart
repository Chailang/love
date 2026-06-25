import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';
import 'profile_provider.dart';
import 'onboarding_helper.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/home_screen.dart';

/// 进入 App 首页
Future<void> navigateToHome(BuildContext context) async {
  await context.read<ChatProvider>().init();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (_) => false,
  );
}

/// 登录 / 引导后的统一跳转
Future<void> navigateAfterAuth(BuildContext context) async {
  final profile = context.read<ProfileProvider>();
  await profile.loadCenter();
  if (!context.mounted) return;

  if (OnboardingHelper.needsProfileSetup(profile.center)) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      (_) => false,
    );
    return;
  }

  await navigateToHome(context);
}

/// 已登录用户的启动路由
Future<void> navigateForLoggedInUser(BuildContext context) async {
  await navigateAfterAuth(context);
}
